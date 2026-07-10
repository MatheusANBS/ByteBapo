"""Exemplo de Chat Completions com NVIDIA API Catalog."""

from __future__ import annotations

import os
import sys

from openai import APIConnectionError, APIStatusError, OpenAI


def require_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"Defina a variável {name}.")
    return value


def main() -> int:
    client = OpenAI(
        api_key=require_env("NVIDIA_API_KEY"),
        base_url=os.getenv(
            "NVIDIA_BASE_URL",
            "https://integrate.api.nvidia.com/v1",
        ),
        timeout=60.0,
        max_retries=0,
    )

    try:
        response = client.chat.completions.create(
            model=require_env("NVIDIA_MODEL"),
            messages=[
                {
                    "role": "system",
                    "content": "Responda tecnicamente em português.",
                },
                {
                    "role": "user",
                    "content": "Explique inversão de dependência em 5 linhas.",
                },
            ],
            temperature=0.2,
            max_tokens=600,
        )
    except APIStatusError as exc:
        print(
            f"Erro HTTP {exc.status_code}: {exc.response.text[:1000]}",
            file=sys.stderr,
        )
        return 2
    except APIConnectionError as exc:
        print(f"Erro de conexão: {exc}", file=sys.stderr)
        return 3

    message = response.choices[0].message.content
    print(message or "")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
