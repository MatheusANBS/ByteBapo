# 5. Streaming SSE

## 5.1 Ativação

No payload:

```json
{
  "stream": true
}
```

A resposta é `text/event-stream`.

## 5.2 cURL

```bash
curl -N "https://integrate.api.nvidia.com/v1/chat/completions" \
  -H "Authorization: Bearer $NVIDIA_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{
    "model": "'"$NVIDIA_MODEL"'",
    "messages": [{"role": "user", "content": "Escreva um resumo."}],
    "stream": true,
    "max_tokens": 500
  }'
```

`-N` desabilita o buffer do cURL.

## 5.3 Python

```python
stream = client.chat.completions.create(
    model=os.environ["NVIDIA_MODEL"],
    messages=[{"role": "user", "content": "Explique RAG."}],
    stream=True,
)

for chunk in stream:
    delta = chunk.choices[0].delta
    if delta.content:
        print(delta.content, end="", flush=True)
```

## 5.4 TypeScript

```typescript
const stream = await client.chat.completions.create({
  model: process.env.NVIDIA_MODEL!,
  messages: [{ role: "user", content: "Explique RAG." }],
  stream: true,
});

for await (const chunk of stream) {
  const text = chunk.choices[0]?.delta?.content;
  if (text) process.stdout.write(text);
}
```

## 5.5 Parser SSE manual

Não faça `split("\n")` em cada pacote de rede presumindo que um evento chegou inteiro. TCP pode:

- dividir uma linha;
- juntar vários eventos;
- quebrar UTF-8;
- entregar comentários e linhas vazias.

Mantenha buffer incremental e processe eventos completos.

```python
import json

def iter_sse(response):
    event_lines = []
    for raw_line in response.iter_lines(decode_unicode=True):
        if raw_line == "":
            if event_lines:
                data = "\n".join(
                    line[5:].lstrip()
                    for line in event_lines
                    if line.startswith("data:")
                )
                event_lines.clear()
                if data == "[DONE]":
                    return
                if data:
                    yield json.loads(data)
            continue
        event_lines.append(raw_line)
```

## 5.6 Cancelamento

Ao usuário cancelar:

- feche a conexão HTTP;
- cancele a task/AbortController;
- não reutilize o corpo parcial como resposta concluída;
- registre `cancelled_by_client`;
- evite retry automático.

## 5.7 Streaming de tools

Uma chamada de tool pode chegar fragmentada:

- nome em um delta;
- argumentos em vários deltas;
- múltiplos índices.

Acumule por `tool_call.index` ou `id`, concatene a string de argumentos e só faça `JSON.parse` após o término da chamada.

## 5.8 Timeouts

Separe:

- timeout de conexão;
- timeout até o primeiro token;
- timeout de inatividade entre eventos;
- duração total máxima.

Streaming ativo não deve ser encerrado apenas porque ultrapassou o timeout usado em requisições síncronas.
