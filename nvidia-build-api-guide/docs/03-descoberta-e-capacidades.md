# 3. Descoberta de modelos e registro de capacidades

## 3.1 Não mantenha uma lista fixa global

O catálogo é dinâmico. Modelos podem ser:

- adicionados;
- atualizados;
- substituídos;
- removidos;
- migrados para outro endpoint;
- alterados quanto a licença ou disponibilidade.

Guarde os identificadores em configuração e valide-os periodicamente.

## 3.2 Registro recomendado

```typescript
export type EndpointFamily =
  | "chat"
  | "embedding"
  | "reranking"
  | "image"
  | "video"
  | "vision"
  | "audio"
  | "grpc"
  | "specialized";

export interface NvidiaModelCapabilities {
  id: string;
  endpoint: string;
  endpointFamily: EndpointFamily;

  maxContextTokens?: number;
  maxOutputTokens?: number;
  embeddingDimensions?: number;

  supportsStreaming: boolean;
  supportsTools: boolean;
  supportsParallelToolCalls?: boolean;
  supportsJsonObject: boolean;
  supportsJsonSchema?: boolean;
  supportsReasoning: boolean;

  acceptsImages: boolean;
  acceptsAudio: boolean;
  acceptsVideo: boolean;
  acceptedMimeTypes?: string[];

  asynchronous: boolean;
  requiresAssets: boolean;
  transport: "https-json" | "sse" | "grpc";

  modelSpecific?: Record<string, unknown>;
  verifiedAt: string;
}
```

Exemplo de configuração:

```json
{
  "id": "copie-da-pagina-do-modelo",
  "endpoint": "https://integrate.api.nvidia.com/v1/chat/completions",
  "endpointFamily": "chat",
  "supportsStreaming": true,
  "supportsTools": false,
  "supportsJsonObject": true,
  "supportsReasoning": true,
  "acceptsImages": false,
  "acceptsAudio": false,
  "acceptsVideo": false,
  "asynchronous": false,
  "requiresAssets": false,
  "transport": "https-json",
  "modelSpecific": {
    "reasoningField": "reasoning_effort"
  },
  "verifiedAt": "2026-07-10"
}
```

## 3.3 Endpoint `/v1/models`

NIM self-hosted e alguns serviços OpenAI-compatible expõem:

```bash
curl http://localhost:8000/v1/models
```

Esse endpoint ajuda a descobrir o modelo carregado localmente. Não assuma que o endpoint hospedado do catálogo retornará todos os modelos disponíveis ou os recursos de cada um.

## 3.4 Capability probing

Quando a documentação não é explícita, realize testes controlados:

1. requisição mínima;
2. streaming;
3. `response_format`;
4. uma tool simples;
5. imagem pequena;
6. limite de saída;
7. mensagem `system`;
8. sequência de múltiplos turnos.

Não envie probes em massa. Registre resultado, data e código HTTP.

## 3.5 Fonte de verdade

Ordem recomendada:

1. página API do modelo;
2. model card do modelo;
3. documentação da família NIM;
4. matriz de suporte da versão NIM;
5. exemplo gerado pelo catálogo;
6. fórum apenas para incidentes e comportamento observado.
