# 14. NVIDIA NIM self-hosted

## 14.1 O que muda

No self-hosted:

- você executa o contêiner NIM;
- escolhe GPU e capacidade;
- controla rede e observabilidade;
- recebe endpoint local;
- continua sujeito a licença, matriz de suporte e requisitos do modelo.

## 14.2 Fluxo conceitual

```text
NVIDIA NGC / registry
  -> autenticar
  -> docker pull
  -> cache de modelos
  -> docker run com GPU
  -> /v1/health/ready
  -> /v1/models
  -> inferência
```

Use o comando exato apresentado em **Run Anywhere** para o modelo.

## 14.3 Porta

A porta externa comum é `8000`:

```text
http://localhost:8000
```

Exemplo:

```python
client = OpenAI(
    api_key="not-required-or-local-value",
    base_url="http://localhost:8000/v1",
)
```

A exigência de chave local depende de seu proxy e configuração.

## 14.4 Endpoints comuns

```text
POST /v1/chat/completions
POST /v1/completions
POST /v1/responses
POST /v1/embeddings
GET  /v1/models

GET  /v1/health/live
GET  /v1/health/ready
GET  /v1/metrics
GET  /v1/version
GET  /v1/metadata
GET  /v1/manifest
GET  /v1/license
```

A disponibilidade varia por família e versão.

## 14.5 Health probes

Kubernetes:

```yaml
livenessProbe:
  httpGet:
    path: /v1/health/live
    port: 8000
  initialDelaySeconds: 60
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /v1/health/ready
    port: 8000
  initialDelaySeconds: 60
  periodSeconds: 5
```

Modelos grandes podem demorar para carregar. Ajuste startup probe e limites.

## 14.6 Variáveis de configuração

Dependendo do NIM:

```text
NGC_API_KEY
NIM_CACHE_PATH
NIM_MAX_MODEL_LEN
NIM_SERVER_PORT
NIM_HEALTH_PORT
NIM_LOG_LEVEL
NIM_JSONL_LOGGING
NIM_MAX_IMAGES_PER_PROMPT
NIM_MAX_VIDEOS_PER_PROMPT
NIM_TENSOR_PARALLEL_SIZE
NIM_PIPELINE_PARALLEL_SIZE
```

Nem todas existem em todas as imagens.

## 14.7 GPU e paralelismo

Conceitos:

- tensor parallelism divide camadas/operações entre GPUs;
- pipeline parallelism divide estágios;
- context length maior aumenta memória;
- concorrência e KV cache competem por VRAM;
- quantização e engine dependem do perfil suportado.

Use o perfil recomendado pelo NIM. Não force parâmetros sem validar a matriz de suporte.

## 14.8 Cache

Monte volume persistente:

```bash
-v "$HOME/.cache/nim:/opt/nim/.cache"
```

O caminho real deve seguir o comando do modelo.

Benefícios:

- evita download repetido;
- acelera restart;
- facilita operação offline depois de preparar artefatos, quando suportado.

Proteja o cache contra acesso indevido e corrupção.

## 14.9 TLS e gateway

Produção:

```text
cliente
 -> API gateway / ingress TLS
 -> autenticação
 -> rate limit
 -> NIM em rede privada
```

Não exponha a porta do NIM diretamente à internet.

## 14.10 Escalabilidade

- escale réplicas horizontalmente;
- use afinidade de GPU;
- readiness antes de receber tráfego;
- fila ou load shedding;
- sticky session não deve ser necessária para Chat Completions stateless;
- preserve histórico no cliente/aplicação;
- faça warm-up;
- limite contexto e saída.

## 14.11 Tool parsers e reasoning parsers

A versão self-hosted pode exigir parser específico por modelo. Consulte:

- documentação do modelo;
- matriz de suporte;
- release notes;
- flags do contêiner.

Parser incompatível pode gerar texto em vez de `tool_calls` ou quebrar argumentos.

## 14.12 Anthropic-compatible

Alguns NIMs/documentações oferecem compatibilidade com `/v1/messages`, útil em integrações como Claude Code. Isso é específico da versão/modelo. Não assuma disponibilidade global.

## 14.13 Atualização

Antes de atualizar NIM:

1. fixe a tag atual;
2. leia release notes;
3. valide driver e GPU;
4. teste endpoint e parser;
5. execute golden tests;
6. compare latência e tokens;
7. faça canary;
8. mantenha rollback.

Evite `latest` em produção.
