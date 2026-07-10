# 15. Observabilidade e segurança operacional

## 15.1 Logs

NIM self-hosted pode emitir logs em stderr e, quando suportado:

```text
NIM_LOG_LEVEL=INFO
NIM_JSONL_LOGGING=true
```

Não registre:

- API key;
- token Bearer;
- prompt completo por padrão;
- PII;
- base64;
- URLs pré-assinadas;
- resultado confidencial de tools.

## 15.2 Log estruturado recomendado

```json
{
  "timestamp": "2026-07-10T15:00:00Z",
  "provider": "nvidia",
  "endpoint_family": "chat",
  "model": "modelo",
  "request_id": "id-sanitizado",
  "status_code": 200,
  "latency_ms": 1530,
  "prompt_tokens": 400,
  "completion_tokens": 220,
  "finish_reason": "stop",
  "stream": true,
  "attempt": 1,
  "user_tenant": "hash-ou-id-interno"
}
```

## 15.3 Métricas

NIM pode expor Prometheus em:

```text
GET /v1/metrics
```

Monitore:

- requisições;
- erros por status;
- latência;
- time to first token;
- tokens por segundo;
- fila;
- concorrência;
- prompt/completion tokens;
- uso de GPU;
- memória GPU;
- restarts;
- readiness.

## 15.4 SLOs

Exemplo:

```text
Disponibilidade: 99,5%
P95 time-to-first-token: < 3 s
P95 resposta não streaming: < 15 s
Taxa de 5xx: < 1%
Taxa de 429 interna: < 2%
```

Defina por caso de uso e hardware.

## 15.5 Tracing

Quando suportado, preserve:

- `X-Request-Id`;
- W3C `traceparent`;
- correlation ID interno.

```text
requisição do usuário
 -> seu gateway
 -> serviço de agente
 -> NVIDIA API
 -> tool/MCP
```

Nunca use o prompt como identificador.

## 15.6 Redação de dados

Estratégias:

- regex para tokens e e-mails;
- detector de PII;
- hashing consistente;
- allowlist de campos;
- criptografia;
- retenção curta;
- acesso por função.

## 15.7 Egress e SSRF

Ao permitir URLs multimodais:

- não faça fetch arbitrário dentro da rede;
- bloqueie ranges privados;
- bloqueie metadata endpoints;
- limite redirects;
- valide DNS novamente;
- limite bytes;
- use fetch proxy isolado.

## 15.8 Supply chain

Para self-host:

- fixe digest da imagem;
- valide origem;
- use assinatura/verificação de artefatos quando disponível;
- gere SBOM;
- escaneie vulnerabilidades;
- execute como usuário não-root quando suportado;
- restrinja capabilities;
- monte filesystem read-only onde possível.

## 15.9 Segurança de tools

- shell desabilitado por padrão;
- sem acesso à chave NVIDIA dentro do sandbox;
- filesystem por workspace;
- rede bloqueada ou allowlist;
- CPU/memória/tempo limitados;
- output truncado;
- aprovação para efeitos externos;
- logs de auditoria imutáveis.

## 15.10 Privacidade

Antes de enviar dados a endpoint hospedado:

- verifique classificação da informação;
- termos aplicáveis;
- região;
- retenção;
- finalidade;
- consentimento;
- contrato;
- política interna.

Para cargas sensíveis, avalie self-hosted em ambiente controlado.
