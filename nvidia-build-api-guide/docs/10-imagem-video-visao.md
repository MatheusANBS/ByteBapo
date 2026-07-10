# 10. Imagem, vídeo e visão

## 10.1 Não existe um endpoint universal no catálogo

Alguns NIMs self-hosted de geração visual oferecem compatibilidade com:

```text
POST /v1/images/generations
```

Entretanto, endpoints hospedados de FLUX, Stable Diffusion, vídeo, detecção, segmentação e 3D frequentemente usam URL e JSON específicos.

## 10.2 Geração de imagem compatível com OpenAI

Quando a documentação do NIM declarar suporte:

```bash
curl http://localhost:8000/v1/images/generations \
  -H "Content-Type: application/json" \
  -d '{
    "model": "modelo-carregado",
    "prompt": "Uma interface futurista minimalista",
    "size": "1024x1024",
    "n": 1
  }'
```

Campos como `size`, `n`, `negative_prompt`, `seed`, `steps`, `cfg_scale` e formato de saída variam.

## 10.3 Endpoint hospedado específico

Padrão observado em páginas do catálogo:

```text
POST https://ai.api.nvidia.com/v1/genai/<publisher>/<modelo>
```

O payload pode usar:

```json
{
  "text_prompts": [
    {"text": "Descrição principal", "weight": 1.0},
    {"text": "Elementos indesejados", "weight": -1.0}
  ],
  "seed": 0,
  "steps": 30
}
```

Esse é apenas um formato possível. Use exatamente o schema apresentado pela página do modelo.

## 10.4 Image-to-image e edição

Entradas comuns:

- imagem base64;
- asset NVCF;
- prompt;
- máscara;
- força de transformação;
- seed;
- dimensões.

Valide:

- dimensão suportada;
- relação de aspecto;
- formato da máscara;
- canal alpha;
- tamanho máximo;
- política de conteúdo.

## 10.5 Geração de vídeo

Frequentemente assíncrona:

1. enviar prompt e/ou imagem;
2. receber `202`;
3. consultar status;
4. baixar resultado;
5. validar MIME e tamanho.

Não mantenha worker web bloqueado indefinidamente. Use fila de jobs e estado persistente.

## 10.6 Detecção, OCR, segmentação e análise

APIs de visão podem retornar:

- bounding boxes;
- classes;
- scores;
- máscaras;
- keypoints;
- texto;
- embeddings;
- metadados temporais;
- resposta textual de VLM.

Normalize para um DTO interno:

```typescript
interface Detection {
  label: string;
  score: number;
  box?: {
    xMin: number;
    yMin: number;
    xMax: number;
    yMax: number;
  };
  maskUri?: string;
  frame?: number;
  timestampMs?: number;
}
```

Confirme se as coordenadas são:

- pixels;
- normalizadas de 0 a 1;
- baseadas na imagem original ou redimensionada.

## 10.7 3D e simulação

Modelos de 3D podem produzir:

- mesh;
- point cloud;
- material;
- textura;
- pose;
- arquivo compactado;
- URL temporária.

Trate o resultado como artefato binário e valide antes de abrir em pipeline automático.

## 10.8 gRPC para mídia

Estrutura genérica:

```python
import grpc

credentials = grpc.ssl_channel_credentials()
channel = grpc.secure_channel(
    "grpc.nvcf.nvidia.com:443",
    credentials,
)

metadata = (
    ("authorization", f"Bearer {api_key}"),
    ("function-id", function_id),
)

# O stub, request e método vêm do .proto do modelo.
response = stub.Infer(request, metadata=metadata, timeout=120)
```

Não invente mensagens protobuf. Baixe e compile o `.proto` indicado na página.

## 10.9 Armazenamento de resultados

- não confie que URLs temporárias durarão;
- faça download para seu storage;
- calcule hash;
- registre modelo e parâmetros;
- guarde provenance;
- aplique retenção;
- não exponha bucket privado;
- limite o acesso por usuário.
