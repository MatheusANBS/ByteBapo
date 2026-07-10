# 8. Entradas multimodais

## 8.1 Modelos compatíveis com conteúdo OpenAI

Alguns VLMs aceitam uma lista em `content`:

```json
{
  "role": "user",
  "content": [
    {
      "type": "text",
      "text": "Descreva os componentes visíveis."
    },
    {
      "type": "image_url",
      "image_url": {
        "url": "https://exemplo.com/imagem.png"
      }
    }
  ]
}
```

## 8.2 Imagem em base64

```python
import base64
from pathlib import Path

mime = "image/png"
encoded = base64.b64encode(
    Path("imagem.png").read_bytes()
).decode("ascii")

data_url = f"data:{mime};base64,{encoded}"

response = client.chat.completions.create(
    model=os.environ["NVIDIA_MODEL"],
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "Analise esta imagem."},
                {
                    "type": "image_url",
                    "image_url": {"url": data_url},
                },
            ],
        }
    ],
)
```

## 8.3 URL remota

Ao usar URL:

- prefira HTTPS;
- evite URL privada ou temporária curta demais;
- confirme se o serviço NVIDIA consegue acessá-la;
- não use endereço `localhost`;
- trate SSRF no seu próprio proxy;
- não coloque credenciais na query string.

## 8.4 Vídeo

Alguns NIMs aceitam conteúdo semelhante a:

```json
{
  "type": "video_url",
  "video_url": {
    "url": "data:video/mp4;base64,..."
  }
}
```

ou um asset NVCF. Outros usam um campo próprio.

Parâmetros específicos podem controlar:

- frames por segundo;
- número máximo de frames;
- resolução;
- duração;
- pré-processamento;
- quantidade de vídeos por prompt.

## 8.5 Áudio

Dependendo do modelo, a entrada pode ser:

- URL;
- base64;
- asset NVCF;
- campo próprio;
- stream gRPC.

Formatos podem incluir WAV ou MP3, mas a lista exata é por modelo.

## 8.6 Limites por prompt

NIM self-hosted pode ter variáveis como:

```text
NIM_MAX_IMAGES_PER_PROMPT
NIM_MAX_VIDEOS_PER_PROMPT
```

A presença e o valor suportado dependem do contêiner e do modelo.

## 8.7 Pré-processamento

Alguns VLMs aceitam opções extras:

```python
extra_body={
    "media_io_kwargs": {
        "video": {
            "fps": 1.0
        }
    },
    "mm_processor_kwargs": {
        # opções documentadas pelo modelo
    }
}
```

Não copie parâmetros entre VLMs sem validação.

## 8.8 Arquivos maiores

Páginas de alguns modelos recomendam asset NVCF quando a mídia passa de um limite pequeno para inline. O valor não é universal. O fluxo é:

1. criar asset;
2. fazer upload;
3. invocar endpoint referenciando o asset;
4. consultar status;
5. apagar o asset quando não for mais necessário.

## 8.9 Segurança multimodal

Antes de enviar mídia:

- valide assinatura mágica, não só extensão;
- limite bytes e dimensões;
- remova metadados desnecessários;
- faça varredura antimalware;
- normalize formato;
- bloqueie arquivos compactados inesperados;
- não confie em texto lido da imagem;
- aplique política de privacidade e retenção.

## 8.10 Prompt multimodal robusto

```text
Tarefa: identificar componentes do diagrama.
Use somente evidências visíveis.
Liste itens incertos separadamente.
Não invente texto ilegível.
Retorne JSON com:
- components
- relationships
- unreadable_regions
- confidence
```
