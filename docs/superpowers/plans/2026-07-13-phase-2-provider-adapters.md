# Fase 2 — Adapters NVIDIA e Ollama Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Isolar protocolos NVIDIA e Ollama atrás de contratos de domínio neutros.

**Architecture:** `features/providers/domain` declara gateways e entidades puras. Cada adapter mantém seus próprios DTOs, payloads, parser e tradução de falhas. Um resolver escolhe o adapter apenas na composição Riverpod.

**Tech Stack:** Dart, Flutter, http, Riverpod, flutter_test.

## Global Constraints

- Nenhum cliente ou parser processa os dois protocolos.
- O domínio não importa Flutter, Riverpod, HTTP, Drift, SQLite, DTOs ou armazenamento seguro.
- NVIDIA usa SSE e payload OpenAI; Ollama usa NDJSON e payload próprio.

## Fontes oficiais verificadas em 2026-07-13

- NVIDIA NIM LLM API: `POST https://integrate.api.nvidia.com/v1/chat/completions`; streaming retorna SSE `data:` e termina com `data: [DONE]`.
- Ollama API: `GET /api/tags` retorna o catálogo; `POST /api/chat` recebe `model`, `messages`, `options` e `stream`; streaming usa `application/x-ndjson`.
- Drift: `drift_flutter` fornece o executor Flutter e o código gerado é produzido por `drift_dev` e `build_runner`.

---

### Task 1: Contratos neutros

**Files:**
- Create: `lib/features/providers/domain/model_catalog_gateway.dart`
- Create: `lib/features/providers/domain/chat_completion_gateway.dart`
- Create: `lib/features/providers/domain/provider_gateway_resolver.dart`
- Create: `lib/features/providers/domain/entities/available_model.dart`
- Test: `test/features/providers/domain/provider_gateway_resolver_test.dart`

- [ ] Write a failing resolver test:

```dart
expect(resolver.forProvider(ApiProvider.nvidia).catalog, isA<NvidiaCatalogGateway>());
expect(resolver.forProvider(ApiProvider.ollama).chat, isA<OllamaChatGateway>());
```

- [ ] Run `flutter test test/features/providers/domain/provider_gateway_resolver_test.dart` and observe the missing-contract failure.
- [ ] Implement `ModelCatalogGateway`, `ChatCompletionGateway`, `ProviderGateway` and `ProviderGatewayResolver` with `forProvider(ApiProvider provider)`.
- [ ] Re-run the test and expect PASS.

### Task 2: Adapter NVIDIA

**Files:**
- Create: `lib/features/providers/data/nvidia/nvidia_model_catalog_gateway.dart`
- Create: `lib/features/providers/data/nvidia/nvidia_chat_completion_gateway.dart`
- Create: `lib/features/providers/data/nvidia/nvidia_sse_parser.dart`
- Test: `test/features/providers/data/nvidia/nvidia_sse_parser_test.dart`

- [ ] Write a failing test that supplies split UTF-8 SSE bytes and expects `choices[0].delta.content` plus `[DONE]` termination.
- [ ] Run `flutter test test/features/providers/data/nvidia/nvidia_sse_parser_test.dart` and observe the missing-parser failure.
- [ ] Implement the exclusive NVIDIA parser and gateways; use `/v1/models`, `/v1/chat/completions`, bearer auth and OpenAI payloads only.
- [ ] Re-run the test and expect PASS.

### Task 3: Adapter Ollama

**Files:**
- Create: `lib/features/providers/data/ollama/ollama_model_catalog_gateway.dart`
- Create: `lib/features/providers/data/ollama/ollama_chat_completion_gateway.dart`
- Create: `lib/features/providers/data/ollama/ollama_ndjson_parser.dart`
- Test: `test/features/providers/data/ollama/ollama_ndjson_parser_test.dart`

- [ ] Write a failing test that supplies split NDJSON bytes and expects thinking, content and `done: true` termination.
- [ ] Run `flutter test test/features/providers/data/ollama/ollama_ndjson_parser_test.dart` and observe the missing-parser failure.
- [ ] Implement the exclusive Ollama parser and gateways; use `/api/tags`, `/api/chat`, `think` and `options` only.
- [ ] Re-run the test and expect PASS.

### Task 4: Composição e remoção do cliente misto

**Files:**
- Modify: `lib/shared/providers.dart`
- Modify: `lib/features/chat/presentation/chat_controller.dart`
- Modify: `lib/features/models/presentation/models_screen.dart`
- Delete: `lib/core/network/api_client.dart`
- Delete: `lib/core/network/ollama_stream_parser.dart`

- [ ] Write controller tests injecting a `ChatCompletionGateway` and asserting no provider branch occurs in presentation.
- [ ] Run the affected tests and observe the old `ApiClient` dependency failure.
- [ ] Wire the resolver through Riverpod and migrate the callers to gateway contracts.
- [ ] Run `dart format lib test && flutter analyze && flutter test`; expect exit code 0.
