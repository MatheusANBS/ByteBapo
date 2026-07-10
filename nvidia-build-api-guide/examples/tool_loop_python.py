"""Loop de tools com validação simples e limite de passos."""

from __future__ import annotations

import json
import os
from typing import Any, Callable

from openai import OpenAI
from pydantic import BaseModel, ConfigDict


class SumArgs(BaseModel):
    model_config = ConfigDict(extra="forbid")
    a: float
    b: float


def sum_numbers(raw: dict[str, Any]) -> dict[str, float]:
    args = SumArgs.model_validate(raw)
    return {"result": args.a + args.b}


TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "sum_numbers",
            "description": "Soma dois números.",
            "parameters": {
                "type": "object",
                "properties": {
                    "a": {"type": "number"},
                    "b": {"type": "number"},
                },
                "required": ["a", "b"],
                "additionalProperties": False,
            },
        },
    }
]

HANDLERS: dict[str, Callable[[dict[str, Any]], dict[str, Any]]] = {
    "sum_numbers": sum_numbers
}


def main() -> None:
    client = OpenAI(
        api_key=os.environ["NVIDIA_API_KEY"],
        base_url=os.getenv(
            "NVIDIA_BASE_URL",
            "https://integrate.api.nvidia.com/v1",
        ),
        timeout=60,
        max_retries=0,
    )

    messages: list[dict[str, Any]] = [
        {"role": "user", "content": "Calcule 19,5 + 7."}
    ]

    for _ in range(8):
        response = client.chat.completions.create(
            model=os.environ["NVIDIA_MODEL"],
            messages=messages,
            tools=TOOLS,
            tool_choice="auto",
            temperature=0,
        )

        msg = response.choices[0].message
        messages.append(msg.model_dump(exclude_none=True))

        if not msg.tool_calls:
            print(msg.content or "")
            return

        for call in msg.tool_calls:
            name = call.function.name
            try:
                args = json.loads(call.function.arguments)
                handler = HANDLERS[name]
                result = handler(args)
            except Exception as exc:
                result = {
                    "error": type(exc).__name__,
                    "message": "Falha ao executar a tool.",
                }

            messages.append(
                {
                    "role": "tool",
                    "tool_call_id": call.id,
                    "content": json.dumps(
                        result,
                        ensure_ascii=False,
                    ),
                }
            )

    raise RuntimeError("Limite de passos atingido.")


if __name__ == "__main__":
    main()
