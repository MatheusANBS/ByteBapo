# 13. Erros, limites e resiliência

## 13.1 Não há uma quota universal

Endpoints do catálogo são compartilhados e cada serviço pode ter:

- limite de requisições;
- limite de tokens;
- limite de concorrência;
- limite do worker;
- fila;
- tamanho máximo;
- timeout;
- créditos;
- restrição por função.

Não existe uma única tabela aplicável a todos os modelos. Leia a página do endpoint e trate o comportamento observado.

## 13.2 Códigos comuns

| Código | Interpretação provável | Ação |
|---:|---|---|
| 200 | Sucesso | processar |
| 202 | Processamento pendente | polling |
| 302 | Resultado grande em outra URL | ler `Location` |
| 400 | JSON ou parâmetro inválido | corrigir, não fazer retry cego |
| 401 | Chave ausente/inválida | corrigir secret |
| 402 | Créditos/entitlement | verificar conta |
| 403 | Permissão/escopo | verificar acesso |
| 404 | Endpoint, função ou modelo | revisar configuração |
| 408 | Timeout | retry condicionado |
| 409 | Conflito | verificar idempotência |
| 413 | Payload grande | asset ou compressão aceita |
| 422 | Validação semântica | corrigir payload |
| 429 | Rate limit/ResourceExhausted | backoff e reduzir concorrência |
| 500 | Falha interna | retry limitado |
| 502/503/504 | indisponibilidade | retry limitado/fallback |

O corpo da resposta é a fonte principal.

## 13.3 `ResourceExhausted`

Mensagens como:

```text
ResourceExhausted: Worker local total request limit reached
```

normalmente indicam saturação ou limite de concorrência do worker/serviço. Não há garantia de uma data fixa de reset.

Ações:

1. reduza concorrência;
2. adicione fila;
3. backoff exponencial com jitter;
4. respeite `Retry-After`;
5. tente modelo alternativo aprovado;
6. faça self-host quando precisar de capacidade previsível;
7. não crie tempestade de retries.

## 13.4 Retry policy

Faça retry apenas para falhas transitórias:

```python
RETRYABLE = {408, 429, 500, 502, 503, 504}
```

Alguns `409` e `202` têm fluxo próprio.

```python
import random
import time
import requests

def post_with_retry(url, headers, payload, attempts=5):
    for attempt in range(attempts):
        try:
            response = requests.post(
                url,
                headers=headers,
                json=payload,
                timeout=(10, 120),
            )
        except (requests.Timeout, requests.ConnectionError):
            response = None

        if response is not None and response.status_code not in RETRYABLE:
            response.raise_for_status()
            return response

        if attempt == attempts - 1:
            if response is not None:
                response.raise_for_status()
            raise TimeoutError("Falha de rede após retries")

        retry_after = (
            response.headers.get("Retry-After")
            if response is not None
            else None
        )
        delay = float(retry_after) if retry_after else min(2 ** attempt, 30)
        time.sleep(delay + random.uniform(0, 0.5))
```

## 13.5 Concorrência limitada

```python
import asyncio

semaphore = asyncio.Semaphore(4)

async def invoke_bounded(call):
    async with semaphore:
        return await call()
```

Ajuste por endpoint e ambiente.

## 13.6 Circuit breaker

Abra o circuito quando ocorrer:

- sequência de 5xx;
- taxa alta de 429;
- latência extrema;
- timeout repetido.

Estados:

```text
CLOSED -> OPEN -> HALF_OPEN -> CLOSED
```

Não conte `400/422` como falha do provedor.

## 13.7 Idempotência

Para operações que geram assets, jobs ou efeitos:

- atribua `operation_id` interno;
- salve request ID;
- não reenvie ao perder a conexão sem verificar estado;
- deduplique por hash de entrada quando apropriado.

## 13.8 Fallback

Política explícita:

```text
modelo primário
 -> mesmo modelo self-hosted
 -> modelo alternativo compatível
 -> resposta degradada
 -> fila
 -> erro claro
```

Não troque silenciosamente para um modelo com licença, contexto ou segurança diferente.

## 13.9 Limites locais

Aplique antes de chamar a NVIDIA:

- tamanho do prompt;
- quantidade de mensagens;
- bytes de base64;
- número de imagens;
- duração de vídeo;
- tokens máximos;
- tools por requisição;
- profundidade de agente;
- requisições por usuário.

## 13.10 Diagnóstico mínimo

Registre:

- endpoint lógico, sem secret;
- model ID;
- status code;
- request ID;
- duração;
- tentativa;
- tamanho de entrada;
- tokens;
- `finish_reason`;
- erro sanitizado;
- concorrência atual.
