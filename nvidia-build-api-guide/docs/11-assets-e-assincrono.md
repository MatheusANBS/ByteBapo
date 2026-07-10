# 11. NVCF Assets e execução assíncrona

## 11.1 Quando usar

Assets são úteis para:

- mídia grande;
- arquivos binários;
- inputs que ultrapassam limite inline;
- resultados grandes;
- funções NVCF que exigem referência.

## 11.2 Criar asset

Endpoint:

```text
POST https://api.nvcf.nvidia.com/v2/nvcf/assets
```

Exemplo conceitual:

```bash
curl "https://api.nvcf.nvidia.com/v2/nvcf/assets" \
  -H "Authorization: Bearer $NVIDIA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contentType": "video/mp4",
    "description": "Vídeo de entrada"
  }'
```

A resposta contém um identificador do asset e uma URL pré-assinada de upload. Os nomes exatos dos campos devem ser lidos na resposta/documentação vigente.

## 11.3 Fazer upload

Use `PUT` diretamente na URL pré-assinada:

```bash
curl --request PUT \
  --upload-file "./entrada.mp4" \
  --header "Content-Type: video/mp4" \
  "$UPLOAD_URL"
```

Normalmente o upload para a URL pré-assinada não usa o header de autorização NVIDIA.

## 11.4 Referenciar asset

Algumas funções usam:

```http
NVCF-INPUT-ASSET-REFERENCES: asset-id-1,asset-id-2
```

Outras também exigem o ID no JSON. Siga o exemplo do modelo.

## 11.5 Execução NVCF

Endpoint moderno:

```text
POST https://api.nvcf.nvidia.com/v2/nvcf/pexec/functions/{functionId}
```

Também pode existir variante com versão da função.

Headers frequentes:

```http
Authorization: Bearer <key>
Content-Type: application/json
Accept: application/json
NVCF-INPUT-ASSET-REFERENCES: <ids>
NVCF-POLL-SECONDS: 30
```

`NVCF-POLL-SECONDS` solicita que a chamada aguarde por um período antes de devolver `202`; respeite o máximo documentado.

## 11.6 Resposta assíncrona

Fluxo típico:

```text
POST função
  |
  +-- 200 -> resultado pronto
  |
  +-- 202 -> request ID
               |
               v
GET /v2/nvcf/pexec/status/{requestId}
  |
  +-- 202 -> ainda processando
  +-- 200 -> resultado
  +-- 302 -> resultado grande em Location
  +-- erro -> falha
```

## 11.7 Polling

```python
import random
import time
import requests

def poll_result(api_key: str, request_id: str, timeout_s: int = 900):
    deadline = time.monotonic() + timeout_s
    delay = 1.0

    while time.monotonic() < deadline:
        response = requests.get(
            f"https://api.nvcf.nvidia.com/v2/nvcf/pexec/status/{request_id}",
            headers={"Authorization": f"Bearer {api_key}"},
            timeout=30,
            allow_redirects=False,
        )

        if response.status_code == 200:
            return response.json()

        if response.status_code == 302:
            location = response.headers["Location"]
            result = requests.get(location, timeout=120)
            result.raise_for_status()
            return result.content

        if response.status_code != 202:
            response.raise_for_status()

        retry_after = response.headers.get("Retry-After")
        if retry_after:
            sleep_s = min(float(retry_after), 30.0)
        else:
            sleep_s = min(delay, 30.0) + random.uniform(0, 0.25)

        time.sleep(sleep_s)
        delay *= 1.7

    raise TimeoutError("Tempo máximo de polling excedido")
```

## 11.8 Persistência de jobs

Tabela recomendada:

```sql
CREATE TABLE nvidia_jobs (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    provider_request_id TEXT,
    function_id TEXT NOT NULL,
    model_id TEXT,
    status TEXT NOT NULL,
    input_asset_ids JSONB,
    output_uri TEXT,
    error_code TEXT,
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ
);
```

Estados internos:

```text
CREATED
UPLOADING
SUBMITTED
PENDING
SUCCEEDED
FAILED
CANCELLED
EXPIRED
```

## 11.9 Limpeza

Depois do processamento:

- remova assets quando permitido;
- apague URLs pré-assinadas de logs;
- aplique retenção;
- remova arquivos temporários;
- mantenha apenas hash e metadados necessários.

## 11.10 Endpoints antigos

Documentações ou exemplos antigos podem mencionar `/exec`. Prefira a família `/pexec` quando a documentação atual indicar que `/exec` está depreciado.
