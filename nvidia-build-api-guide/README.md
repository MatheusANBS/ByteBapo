# Guia completo das APIs do NVIDIA API Catalog / build.nvidia.com

> Última atualização: **10 de julho de 2026**  
> Escopo: endpoints hospedados apresentados no `build.nvidia.com`, APIs NVCF usadas por esses endpoints e NVIDIA NIM self-hosted.

Este repositório documenta como descobrir, autenticar, chamar, integrar, observar e tornar resilientes as APIs associadas ao catálogo de modelos da NVIDIA.

## Aviso essencial

O `build.nvidia.com` é um **catálogo de modelos e APIs**, não uma única API uniforme. Há famílias com contratos diferentes:

| Família | Padrão mais comum |
|---|---|
| LLM e alguns VLMs | Compatível com OpenAI: `/v1/chat/completions` |
| Embeddings | `/v1/embeddings` |
| Reranking | Endpoint de retrieval específico |
| Geração de imagem e vídeo | Endpoint e schema por modelo |
| Visão computacional | Endpoint, payload e retorno por modelo |
| Áudio e mídia | REST ou gRPC, dependendo do modelo |
| Healthcare, clima, otimização e simulação | Contratos especializados |
| NIM self-hosted | API compatível com OpenAI + saúde, métricas e metadados |
| Arquivos grandes e operações longas | NVCF Assets + execução assíncrona |

A página **API** de cada modelo continua sendo a fonte de verdade para:

- URL exata;
- identificador do modelo;
- campos aceitos;
- formatos de arquivo;
- limites de entrada e saída;
- suporte a streaming, tools, reasoning ou multimodalidade;
- códigos de resposta;
- licença e restrições de uso.

## Comece por aqui

1. [Visão geral e fluxo de integração](docs/01-visao-geral.md)
2. [Autenticação e segurança](docs/02-autenticacao-e-seguranca.md)
3. [Descoberta de modelos e registro de capacidades](docs/03-descoberta-e-capacidades.md)
4. [Chat Completions](docs/04-chat-completions.md)
5. [Streaming SSE](docs/05-streaming.md)
6. [Tools, MCP e agentes](docs/06-tools-mcp-e-agentes.md)
7. [Reasoning e JSON estruturado](docs/07-reasoning-e-json.md)
8. [Entradas multimodais](docs/08-multimodal.md)
9. [Embeddings, reranking e RAG](docs/09-embeddings-reranking-rag.md)
10. [Imagem, vídeo e visão](docs/10-imagem-video-visao.md)
11. [Assets e execução assíncrona](docs/11-assets-e-assincrono.md)
12. [APIs especializadas](docs/12-apis-especializadas.md)
13. [Erros, limites e resiliência](docs/13-erros-limites-resiliencia.md)
14. [NIM self-hosted](docs/14-self-hosted-nim.md)
15. [Observabilidade e segurança operacional](docs/15-observabilidade-seguranca.md)
16. [Checklist de produção](docs/16-checklist-producao.md)
17. [Referências oficiais](SOURCES.md)

## Exemplos executáveis

- [`examples/chat_python.py`](examples/chat_python.py)
- [`examples/chat_typescript.ts`](examples/chat_typescript.ts)
- [`examples/tool_loop_python.py`](examples/tool_loop_python.py)
- [`examples/rag_python.py`](examples/rag_python.py)
- [`examples/nvcf_asset_python.py`](examples/nvcf_asset_python.py)
- [`examples/.env.example`](examples/.env.example)

## Variáveis de ambiente recomendadas

```bash
NVIDIA_API_KEY=nvapi-...
NVIDIA_BASE_URL=https://integrate.api.nvidia.com/v1
NVIDIA_MODEL=<id-copiado-da-pagina-do-modelo>
```

Nunca publique a chave em Git, bundle web, aplicativo mobile, Electron renderer ou código distribuído ao cliente.
