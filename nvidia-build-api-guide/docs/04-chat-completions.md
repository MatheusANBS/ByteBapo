# 4. Chat Completions

## 4.1 Endpoint hospedado comum

```text
POST https://integrate.api.nvidia.com/v1/chat/completions
```

Nem todo modelo usa essa rota. Copie o exemplo da página do modelo.

## 4.2 Requisição mínima

```bash
curl "https://integrate.api.nvidia.com/v1/chat/completions" \
  -H "Authorization: Bearer $NVIDIA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "'"$NVIDIA_MODEL"'",
    "messages": [
      {"role": "user", "content": "Explique inversão de dependência."}
    ]
  }'
```

## 4.3 Python com SDK OpenAI

```python
import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["NVIDIA_API_KEY"],
    base_url=os.getenv(
        "NVIDIA_BASE_URL",
        "https://integrate.api.nvidia.com/v1",
    ),
    timeout=60.0,
    max_retries=0,
)

response = client.chat.completions.create(
    model=os.environ["NVIDIA_MODEL"],
    messages=[
        {"role": "system", "content": "Responda tecnicamente em português."},
        {"role": "user", "content": "Explique Clean Architecture."},
    ],
    temperature=0.2,
    top_p=0.9,
    max_tokens=1200,
)

print(response.choices[0].message.content)
```

## 4.4 TypeScript com SDK OpenAI

```typescript
import OpenAI from "openai";

const client = new OpenAI({
  apiKey: process.env.NVIDIA_API_KEY,
  baseURL:
    process.env.NVIDIA_BASE_URL ??
    "https://integrate.api.nvidia.com/v1",
  timeout: 60_000,
  maxRetries: 0,
});

const response = await client.chat.completions.create({
  model: process.env.NVIDIA_MODEL!,
  messages: [
    { role: "system", content: "Responda tecnicamente em português." },
    { role: "user", content: "Explique Clean Architecture." },
  ],
  temperature: 0.2,
  top_p: 0.9,
  max_tokens: 1200,
});

console.log(response.choices[0]?.message.content);
```

## 4.5 Campos comuns

| Campo | Finalidade | Observação |
|---|---|---|
| `model` | Identificador do modelo | Copie da página API |
| `messages` | Histórico | Regras de ordem podem variar |
| `temperature` | Aleatoriedade | Use valores baixos para tarefas determinísticas |
| `top_p` | Nucleus sampling | Evite ajustar agressivamente junto com temperature |
| `max_tokens` | Limite da geração | Pode incluir reasoning, conforme o modelo |
| `stream` | Habilita SSE | Ver capítulo de streaming |
| `stop` | Sequências de parada | String ou lista, conforme contrato |
| `seed` | Reprodutibilidade aproximada | Nem todo backend garante determinismo |
| `frequency_penalty` | Penaliza repetição por frequência | Pode não ser suportado |
| `presence_penalty` | Penaliza termos já presentes | Pode não ser suportado |
| `tools` | Funções disponíveis | Somente em modelos compatíveis |
| `tool_choice` | Seleção de tool | Pode variar |
| `response_format` | JSON/structured output | Depende do modelo |
| `extra_body` | Campos específicos | Recurso do SDK, não do HTTP em si |

Não envie campos não documentados esperando que sejam ignorados. Alguns endpoints retornam `422`.

## 4.6 Mensagens

Papéis típicos:

```json
[
  {"role": "system", "content": "Instruções globais"},
  {"role": "user", "content": "Pergunta"},
  {"role": "assistant", "content": "Resposta anterior"},
  {"role": "user", "content": "Continuação"}
]
```

Alguns modelos exigem alternância estrita entre `user` e `assistant`, `system` apenas na primeira posição e última mensagem como `user`.

## 4.7 Resposta típica

```json
{
  "id": "chatcmpl-...",
  "object": "chat.completion",
  "created": 0,
  "model": "modelo",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "..."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 100,
    "completion_tokens": 250,
    "total_tokens": 350
  }
}
```

Campos podem variar. Trate campos opcionais defensivamente.

## 4.8 Finish reasons

Valores comuns:

- `stop`: término normal;
- `length`: atingiu limite;
- `tool_calls`: solicitou execução de ferramenta;
- `content_filter`: bloqueio ou moderação, quando suportado;
- valor específico do backend.

Ao receber `length`, não concatene automaticamente outra geração sem preservar contexto e verificar se houve corte em JSON ou código.

## 4.9 Completions legadas

NIM self-hosted pode expor:

```text
POST /v1/completions
```

Prefira Chat Completions para modelos instrucionais, salvo orientação contrária do model card.
