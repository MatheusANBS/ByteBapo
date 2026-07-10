# 1. Visão geral e fluxo de integração

## 1.1 O que é o build.nvidia.com

O NVIDIA API Catalog permite:

- pesquisar modelos;
- abrir a página de cada modelo;
- testar prompts;
- gerar ou copiar uma API key;
- consultar exemplos de cURL, Python e outras linguagens;
- usar endpoints hospedados pela NVIDIA;
- obter instruções para executar um NVIDIA NIM localmente.

Os endpoints gratuitos do catálogo são destinados principalmente a prototipagem, pesquisa, desenvolvimento e testes. Para implantação comercial e suporte empresarial, consulte os termos e o NVIDIA AI Enterprise aplicáveis ao modelo.

## 1.2 Componentes envolvidos

```text
Sua aplicação
    |
    | HTTPS + Bearer token
    v
Endpoint apresentado na página do modelo
    |
    +-- integrate.api.nvidia.com  -> chat, embeddings e alguns VLMs
    +-- ai.api.nvidia.com         -> retrieval, imagem, vídeo e outros
    +-- optimize.api.nvidia.com   -> otimização
    +-- climate.api.nvidia.com    -> clima
    +-- api.nvcf.nvidia.com       -> assets, execução e polling NVCF
    +-- grpc.nvcf.nvidia.com      -> alguns serviços gRPC
```

Não derive URLs por conta própria. Copie a URL e o `model` diretamente da página **API** do modelo.

## 1.3 Fluxo seguro de adoção

1. Escolha o modelo no catálogo.
2. Leia a página **Model Card**:
   - licença;
   - finalidade;
   - limitações;
   - formatos;
   - contexto;
   - hardware para self-host.
3. Leia a página **API**:
   - endpoint;
   - autenticação;
   - schema;
   - exemplo;
   - respostas.
4. Execute o exemplo mínimo sem alterações.
5. Adicione timeout e logs.
6. Valide streaming, tools ou arquivos separadamente.
7. Registre as capacidades reais do modelo.
8. Implemente retries somente para falhas transitórias.
9. Defina fallback ou fila.
10. Teste carga com concorrência limitada.

## 1.4 Famílias de transporte

### REST síncrono

A requisição permanece aberta até a resposta:

```text
POST endpoint
Authorization: Bearer <API_KEY>
Content-Type: application/json
```

### Streaming SSE

A resposta chega em eventos:

```text
Accept: text/event-stream
```

Cada linha costuma iniciar com `data:` e o fim geralmente é `data: [DONE]`.

### NVCF assíncrono

Operações demoradas podem retornar `202 Accepted` com um identificador de requisição. O cliente consulta o status até obter `200`, erro ou URL de resultado.

### gRPC

Algumas APIs de mídia usam `grpc.nvcf.nvidia.com:443`, TLS e metadados como API key e function ID. Use o `.proto` e o exemplo da página do modelo.

## 1.5 Regra de compatibilidade

Mesmo quando dois modelos usam `/v1/chat/completions`, eles podem divergir em:

- ordem de mensagens;
- suporte a `system`;
- `tools`;
- structured output;
- multimodalidade;
- campo de reasoning;
- tamanho de contexto;
- limite de saída;
- tipos MIME;
- parâmetros ignorados;
- forma de cobrança ou rate limiting.

A integração deve ser dirigida por capacidades, não apenas pelo nome do endpoint.
