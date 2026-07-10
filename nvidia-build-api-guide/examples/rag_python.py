"""Esqueleto de RAG usando embeddings, reranking e chat NVIDIA."""

from __future__ import annotations

import os
from typing import Any

import requests
from openai import OpenAI


client = OpenAI(
    api_key=os.environ["NVIDIA_API_KEY"],
    base_url=os.getenv(
        "NVIDIA_BASE_URL",
        "https://integrate.api.nvidia.com/v1",
    ),
    timeout=60,
    max_retries=0,
)


def embed(texts: list[str], input_type: str) -> list[list[float]]:
    response = client.embeddings.create(
        model=os.environ["NVIDIA_EMBEDDING_MODEL"],
        input=texts,
        encoding_format="float",
        extra_body={
            "input_type": input_type,
            "truncate": "END",
        },
    )
    return [item.embedding for item in response.data]


def rerank(
    query: str,
    passages: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    response = requests.post(
        os.environ["NVIDIA_RERANK_URL"],
        headers={
            "Authorization": f"Bearer {os.environ['NVIDIA_API_KEY']}",
            "Content-Type": "application/json",
        },
        json={
            "model": os.getenv("NVIDIA_RERANK_MODEL", ""),
            "query": {"text": query},
            "passages": [{"text": item["text"]} for item in passages],
            "truncate": "END",
        },
        timeout=90,
    )
    response.raise_for_status()
    raw = response.json()

    # Adapte o mapeamento ao schema exato da página do reranker.
    rankings = raw.get("rankings", raw.get("data", []))
    output: list[dict[str, Any]] = []
    for rank in rankings:
        index = rank.get("index")
        if isinstance(index, int) and 0 <= index < len(passages):
            output.append(
                {
                    **passages[index],
                    "rerank_score": rank.get(
                        "logit",
                        rank.get("score"),
                    ),
                }
            )
    return output


def answer(question: str, selected: list[dict[str, Any]]) -> str:
    context = "\n\n".join(
        f"[{item['source']}]\n{item['text']}"
        for item in selected
    )
    response = client.chat.completions.create(
        model=os.environ["NVIDIA_CHAT_MODEL"],
        messages=[
            {
                "role": "system",
                "content": (
                    "Use somente o contexto. Cite [fonte]. "
                    "Quando não houver evidência, informe isso."
                ),
            },
            {
                "role": "user",
                "content": (
                    f"CONTEXTO:\n{context}\n\n"
                    f"PERGUNTA:\n{question}"
                ),
            },
        ],
        temperature=0.1,
        max_tokens=1000,
    )
    return response.choices[0].message.content or ""
