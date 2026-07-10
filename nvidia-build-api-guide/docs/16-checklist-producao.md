# 16. Checklist de produção

## Catálogo e modelo

- [ ] Model ID copiado da página oficial
- [ ] Endpoint exato registrado
- [ ] Data da última verificação registrada
- [ ] Licença revisada
- [ ] Intended use e limitações revisados
- [ ] Contexto e saída máximos confirmados
- [ ] Formatos aceitos confirmados
- [ ] Suporte a tools/reasoning/JSON confirmado
- [ ] Modelo fallback aprovado

## Segurança

- [ ] Chave somente no servidor
- [ ] Secret manager configurado
- [ ] Rotação documentada
- [ ] Payload validado
- [ ] Upload validado por MIME/assinatura
- [ ] PII redigida
- [ ] URLs pré-assinadas fora dos logs
- [ ] Tools com allowlist e autorização
- [ ] Prompt injection tratado
- [ ] Política de retenção definida

## Resiliência

- [ ] Timeout de conexão
- [ ] Timeout de primeira resposta
- [ ] Timeout total
- [ ] Retry apenas para transitórios
- [ ] Exponential backoff + jitter
- [ ] `Retry-After` respeitado
- [ ] Concorrência limitada
- [ ] Circuit breaker
- [ ] Idempotência
- [ ] Polling persistente
- [ ] Fila para operações longas

## Observabilidade

- [ ] Correlation/request ID
- [ ] Status e erro sanitizado
- [ ] Latência
- [ ] TTFT
- [ ] Tokens
- [ ] `finish_reason`
- [ ] Métricas de fila/concorrência
- [ ] Dashboard
- [ ] Alertas
- [ ] SLOs

## Qualidade

- [ ] Golden prompts
- [ ] Testes de contrato
- [ ] Avaliação de factualidade
- [ ] Avaliação de RAG
- [ ] Testes de JSON truncado
- [ ] Testes de tool malformada
- [ ] Testes multimodais
- [ ] Teste de carga controlado
- [ ] Canary para atualização
- [ ] Rollback

## Self-hosted

- [ ] Tag/digest fixado
- [ ] Matriz GPU/driver validada
- [ ] Cache persistente
- [ ] Probes configuradas
- [ ] NIM em rede privada
- [ ] TLS no gateway
- [ ] Métricas coletadas
- [ ] Parser de tools/reasoning validado
- [ ] Capacidade de VRAM testada
- [ ] Warm-up configurado
