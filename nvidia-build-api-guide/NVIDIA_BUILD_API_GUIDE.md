# Guia completo das APIs do NVIDIA API Catalog / build.nvidia.com

> Última atualização: **10 de julho de 2026**  
> Escopo: endpoints hospedados apresentados no `build.nvidia.com`, APIs NVCF usadas por esses endpoints e NVIDIA NIM self-hosted.

Este documento consolidado cobre autenticação, descoberta de modelos, Chat Completions, streaming, tools, MCP, agentes, reasoning, JSON estruturado, multimodalidade, embeddings, reranking, RAG, geração visual, assets, execução assíncrona, APIs especializadas, resiliência, self-hosted, observabilidade, segurança e produção.

## Regra central

O `build.nvidia.com` é um catálogo de modelos e APIs, não uma única API uniforme. A página **API** de cada modelo é a fonte de verdade para URL, schema, parâmetros, formatos, limites e capacidades.

## Sumário

1. [Visão geral e fluxo de integração](#1-visão-geral-e-fluxo-de-integração)
2. [Autenticação e segurança](#2-autenticação-e-segurança)
3. [Descoberta de modelos e registro de capacidades](#3-descoberta-de-modelos-e-registro-de-capacidades)
4. [Chat Completions](#4-chat-completions)
5. [Streaming SSE](#5-streaming-sse)
6. [Tools, MCP e agentes](#6-tools-mcp-e-agentes)
7. [Reasoning e saída JSON](#7-reasoning-e-saída-json)
8. [Entradas multimodais](#8-entradas-multimodais)
9. [Embeddings, reranking e RAG](#9-embeddings-reranking-e-rag)
10. [Imagem, vídeo e visão](#10-imagem-vídeo-e-visão)
11. [NVCF Assets e execução assíncrona](#11-nvcf-assets-e-execução-assíncrona)
12. [APIs especializadas](#12-apis-especializadas)
13. [Erros, limites e resiliência](#13-erros-limites-e-resiliência)
14. [NVIDIA NIM self-hosted](#14-nvidia-nim-self-hosted)
15. [Observabilidade e segurança operacional](#15-observabilidade-e-segurança-operacional)
16. [Checklist de produção](#16-checklist-de-produção)
17. [Referências oficiais](#referências-oficiais)

---

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

---

# 2. Autenticação e segurança

## 2.1 Obtenção da chave

Na página de um modelo do catálogo:

1. entre com sua conta NVIDIA;
2. participe do NVIDIA Developer Program quando solicitado;
3. abra a guia **API**;
4. selecione **Get API Key**;
5. copie a chave.

O prefixo frequentemente observado é `nvapi-`, mas não valide a chave apenas pelo prefixo.

## 2.2 Header padrão

```http
Authorization: Bearer nvapi-...
Content-Type: application/json
```

Exemplo:

```bash
curl --request POST \
  --url "https://integrate.api.nvidia.com/v1/chat/completions" \
  --header "Authorization: Bearer $NVIDIA_API_KEY" \
  --header "Content-Type: application/json" \
  --data '{
    "model": "'"$NVIDIA_MODEL"'",
    "messages": [{"role": "user", "content": "Olá"}]
  }'
```

## 2.3 Onde guardar a chave

### Desenvolvimento local

Use `.env` fora do Git:

```dotenv
NVIDIA_API_KEY=nvapi-...
```

`.gitignore`:

```gitignore
.env
.env.*
!.env.example
```

### Produção

Use secret manager:

- Kubernetes Secret com criptografia e controle de acesso;
- HashiCorp Vault;
- AWS Secrets Manager;
- Azure Key Vault;
- Google Secret Manager;
- secret store da plataforma de CI/CD.

### Nunca coloque a chave em

- React/Vite compilado;
- JavaScript executado no navegador;
- aplicativo mobile distribuído;
- Electron renderer;
- repositório;
- log;
- screenshot;
- parâmetro de URL;
- mensagem de erro enviada ao usuário.

## 2.4 Arquitetura recomendada para frontend

```text
Browser ou app
    |
    | autenticação da sua aplicação
    v
Seu backend / API gateway
    |
    | NVIDIA_API_KEY no servidor
    v
NVIDIA API
```

O backend deve aplicar:

- autenticação do seu usuário;
- quotas internas;
- validação de payload;
- timeout;
- limite de tamanho;
- auditoria;
- filtragem de conteúdo quando aplicável.

## 2.5 Rotação e incidente

Ao suspeitar de vazamento:

1. revogue ou substitua a chave;
2. remova a chave do histórico do Git;
3. invalide caches e artefatos de CI;
4. procure uso indevido nos logs;
5. gere uma chave nova;
6. atualize os secrets;
7. documente o incidente.

## 2.6 Escopos NVCF

Fluxos de assets e funções NVCF podem exigir permissões de invocação específicas. Um `403` pode significar:

- chave sem escopo;
- função não autorizada;
- modelo não disponível para sua conta;
- região ou entitlement incompatível.

Use a chave gerada ou indicada na página específica do modelo.

---

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

---

# 4. Chat Completions

## 4.1 Endpoint hospedado comum

```text
POST https://integrate.api.nvidia.com/v1/chat/completions
```

Nem todo modelo usa essa rota. Copie o exemplo da página do modelo.

## 4.2 Requisição mínima

```bash
curl "https://integrate.api.nvidia.com/v1/chat/completions" \
  -H "Authorization: Bearer $NVIDIA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "'"$NVIDIA_MODEL"'",
    "messages": [
      {"role": "user", "content": "Explique inversão de dependência."}
    ]
  }'
```

## 4.3 Python com SDK OpenAI

```python
import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["NVIDIA_API_KEY"],
    base_url=os.getenv(
        "NVIDIA_BASE_URL",
        "https://integrate.api.nvidia.com/v1",
    ),
    timeout=60.0,
    max_retries=0,
)

response = client.chat.completions.create(
    model=os.environ["NVIDIA_MODEL"],
    messages=[
        {"role": "system", "content": "Responda tecnicamente em português."},
        {"role": "user", "content": "Explique Clean Architecture."},
    ],
    temperature=0.2,
    top_p=0.9,
    max_tokens=1200,
)

print(response.choices[0].message.content)
```

## 4.4 TypeScript com SDK OpenAI

```typescript
import OpenAI from "openai";

const client = new OpenAI({
  apiKey: process.env.NVIDIA_API_KEY,
  baseURL:
    process.env.NVIDIA_BASE_URL ??
    "https://integrate.api.nvidia.com/v1",
  timeout: 60_000,
  maxRetries: 0,
});

const response = await client.chat.completions.create({
  model: process.env.NVIDIA_MODEL!,
  messages: [
    { role: "system", content: "Responda tecnicamente em português." },
    { role: "user", content: "Explique Clean Architecture." },
  ],
  temperature: 0.2,
  top_p: 0.9,
  max_tokens: 1200,
});

console.log(response.choices[0]?.message.content);
```

## 4.5 Campos comuns

| Campo | Finalidade | Observação |
|---|---|---|
| `model` | Identificador do modelo | Copie da página API |
| `messages` | Histórico | Regras de ordem podem variar |
| `temperature` | Aleatoriedade | Use valores baixos para tarefas determinísticas |
| `top_p` | Nucleus sampling | Evite ajustar agressivamente junto com temperature |
| `max_tokens` | Limite da geração | Pode incluir reasoning, conforme o modelo |
| `stream` | Habilita SSE | Ver capítulo de streaming |
| `stop` | Sequências de parada | String ou lista, conforme contrato |
| `seed` | Reprodutibilidade aproximada | Nem todo backend garante determinismo |
| `frequency_penalty` | Penaliza repetição por frequência | Pode não ser suportado |
| `presence_penalty` | Penaliza termos já presentes | Pode não ser suportado |
| `tools` | Funções disponíveis | Somente em modelos compatíveis |
| `tool_choice` | Seleção de tool | Pode variar |
| `response_format` | JSON/structured output | Depende do modelo |
| `extra_body` | Campos específicos | Recurso do SDK, não do HTTP em si |

Não envie campos não documentados esperando que sejam ignorados. Alguns endpoints retornam `422`.

## 4.6 Mensagens

Papéis típicos:

```json
[
  {"role": "system", "content": "Instruções globais"},
  {"role": "user", "content": "Pergunta"},
  {"role": "assistant", "content": "Resposta anterior"},
  {"role": "user", "content": "Continuação"}
]
```

Alguns modelos exigem alternância estrita entre `user` e `assistant`, `system` apenas na primeira posição e última mensagem como `user`.

## 4.7 Resposta típica

```json
{
  "id": "chatcmpl-...",
  "object": "chat.completion",
  "created": 0,
  "model": "modelo",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "..."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 100,
    "completion_tokens": 250,
    "total_tokens": 350
  }
}
```

Campos podem variar. Trate campos opcionais defensivamente.

## 4.8 Finish reasons

Valores comuns:

- `stop`: término normal;
- `length`: atingiu limite;
- `tool_calls`: solicitou execução de ferramenta;
- `content_filter`: bloqueio ou moderação, quando suportado;
- valor específico do backend.

Ao receber `length`, não concatene automaticamente outra geração sem preservar contexto e verificar se houve corte em JSON ou código.

## 4.9 Completions legadas

NIM self-hosted pode expor:

```text
POST /v1/completions
```

Prefira Chat Completions para modelos instrucionais, salvo orientação contrária do model card.

---

# 5. Streaming SSE

## 5.1 Ativação

No payload:

```json
{
  "stream": true
}
```

A resposta é `text/event-stream`.

## 5.2 cURL

```bash
curl -N "https://integrate.api.nvidia.com/v1/chat/completions" \
  -H "Authorization: Bearer $NVIDIA_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{
    "model": "'"$NVIDIA_MODEL"'",
    "messages": [{"role": "user", "content": "Escreva um resumo."}],
    "stream": true,
    "max_tokens": 500
  }'
```

`-N` desabilita o buffer do cURL.

## 5.3 Python

```python
stream = client.chat.completions.create(
    model=os.environ["NVIDIA_MODEL"],
    messages=[{"role": "user", "content": "Explique RAG."}],
    stream=True,
)

for chunk in stream:
    delta = chunk.choices[0].delta
    if delta.content:
        print(delta.content, end="", flush=True)
```

## 5.4 TypeScript

```typescript
const stream = await client.chat.completions.create({
  model: process.env.NVIDIA_MODEL!,
  messages: [{ role: "user", content: "Explique RAG." }],
  stream: true,
});

for await (const chunk of stream) {
  const text = chunk.choices[0]?.delta?.content;
  if (text) process.stdout.write(text);
}
```

## 5.5 Parser SSE manual

Não faça `split("\n")` em cada pacote de rede presumindo que um evento chegou inteiro. TCP pode:

- dividir uma linha;
- juntar vários eventos;
- quebrar UTF-8;
- entregar comentários e linhas vazias.

Mantenha buffer incremental e processe eventos completos.

```python
import json

def iter_sse(response):
    event_lines = []
    for raw_line in response.iter_lines(decode_unicode=True):
        if raw_line == "":
            if event_lines:
                data = "\n".join(
                    line[5:].lstrip()
                    for line in event_lines
                    if line.startswith("data:")
                )
                event_lines.clear()
                if data == "[DONE]":
                    return
                if data:
                    yield json.loads(data)
            continue
        event_lines.append(raw_line)
```

## 5.6 Cancelamento

Ao usuário cancelar:

- feche a conexão HTTP;
- cancele a task/AbortController;
- não reutilize o corpo parcial como resposta concluída;
- registre `cancelled_by_client`;
- evite retry automático.

## 5.7 Streaming de tools

Uma chamada de tool pode chegar fragmentada:

- nome em um delta;
- argumentos em vários deltas;
- múltiplos índices.

Acumule por `tool_call.index` ou `id`, concatene a string de argumentos e só faça `JSON.parse` após o término da chamada.

## 5.8 Timeouts

Separe:

- timeout de conexão;
- timeout até o primeiro token;
- timeout de inatividade entre eventos;
- duração total máxima.

Streaming ativo não deve ser encerrado apenas porque ultrapassou o timeout usado em requisições síncronas.

---

# 6. Tools, MCP e agentes

## 6.1 Conceito

O modelo não executa funções por conta própria. Ele produz uma intenção estruturada. Sua aplicação:

1. envia schemas de tools;
2. recebe `tool_calls`;
3. valida os argumentos;
4. autoriza a ação;
5. executa o código;
6. adiciona o resultado ao histórico;
7. chama o modelo novamente.

## 6.2 Definição de tool

```json
{
  "type": "function",
  "function": {
    "name": "consultar_clima",
    "description": "Consulta o clima atual de uma cidade.",
    "parameters": {
      "type": "object",
      "properties": {
        "cidade": {
          "type": "string",
          "description": "Cidade e estado ou país."
        }
      },
      "required": ["cidade"],
      "additionalProperties": false
    }
  }
}
```

## 6.3 Requisição

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "somar",
            "description": "Soma dois números.",
            "parameters": {
                "type": "object",
                "properties": {
                    "a": {"type": "number"},
                    "b": {"type": "number"},
                },
                "required": ["a", "b"],
                "additionalProperties": False,
            },
        },
    }
]

response = client.chat.completions.create(
    model=os.environ["NVIDIA_MODEL"],
    messages=[{"role": "user", "content": "Quanto é 19,5 + 7?"}],
    tools=tools,
    tool_choice="auto",
)
```

## 6.4 Loop completo

```python
import json

def somar(a: float, b: float) -> dict:
    return {"resultado": a + b}

handlers = {"somar": somar}
messages = [{"role": "user", "content": "Quanto é 19,5 + 7?"}]

for _ in range(8):
    response = client.chat.completions.create(
        model=os.environ["NVIDIA_MODEL"],
        messages=messages,
        tools=tools,
        tool_choice="auto",
    )

    assistant = response.choices[0].message
    messages.append(assistant.model_dump(exclude_none=True))

    if not assistant.tool_calls:
        print(assistant.content)
        break

    for call in assistant.tool_calls:
        name = call.function.name
        args = json.loads(call.function.arguments)

        if name not in handlers:
            result = {"error": "tool_desconhecida"}
        else:
            try:
                result = handlers[name](**args)
            except Exception as exc:
                result = {"error": type(exc).__name__}

        messages.append(
            {
                "role": "tool",
                "tool_call_id": call.id,
                "content": json.dumps(result, ensure_ascii=False),
            }
        )
else:
    raise RuntimeError("Limite de iterações do agente atingido")
```

## 6.5 Controles obrigatórios

Não confie nos argumentos gerados. Implemente:

- validação JSON Schema;
- allowlist de tools;
- limite de iterações;
- timeout por tool;
- tamanho máximo do resultado;
- sandbox para shell ou código;
- path normalization para arquivos;
- aprovação humana para efeitos irreversíveis;
- idempotency key para ações repetíveis;
- auditoria;
- redaction de secrets.

## 6.6 Prompt injection

Conteúdo de:

- páginas web;
- arquivos;
- e-mails;
- resultados de busca;
- respostas de MCP;

é dado não confiável. Não permita que o conteúdo altere políticas do agente.

Separe:

```text
Instruções do sistema
Política de autorização
Solicitação do usuário
Dados externos não confiáveis
```

## 6.7 MCP

NVIDIA NIM não se conecta diretamente ao MCP. O cliente ou framework deve:

1. conectar ao servidor MCP;
2. executar `tools/list`;
3. converter os schemas para o formato OpenAI `tools`;
4. enviar esses schemas ao modelo;
5. receber `tool_calls`;
6. executar `tools/call`;
7. devolver o resultado ao modelo.

Pseudocódigo:

```python
mcp_tools = await mcp_session.list_tools()
openai_tools = [convert_mcp_tool(t) for t in mcp_tools.tools]

response = client.chat.completions.create(
    model=model,
    messages=messages,
    tools=openai_tools,
)

for call in response.choices[0].message.tool_calls or []:
    result = await mcp_session.call_tool(
        call.function.name,
        json.loads(call.function.arguments),
    )
```

## 6.8 NIM self-hosted e parser de tools

Em NIM local, o servidor pode precisar de:

- auto tool choice habilitado;
- parser compatível com a família do modelo;
- versão NIM que suporte o modelo e o parser.

Exemplos de conceito:

```text
--enable-auto-tool-choice
--tool-call-parser <parser-compatível>
```

Não escolha o parser por tentativa cega. Siga a documentação do modelo e da versão NIM.

## 6.9 Estratégias de agente

### ReAct

Modelo alterna análise, tool e observação. Bom para tarefas exploratórias, mas exige limite de passos.

### Plan-and-execute

Um planejador cria etapas e um executor usa tools. Bom para tarefas longas; precisa replanejamento controlado.

### Workflow determinístico

O código decide a sequência e usa o modelo em pontos específicos. É a opção mais previsível para processos empresariais.

## 6.10 Aprovação

Classifique tools:

| Classe | Exemplo | Política |
|---|---|---|
| Leitura | consultar arquivo | automática com escopo |
| Escrita reversível | criar rascunho | automática ou aprovação |
| Escrita externa | enviar e-mail | aprovação |
| Destrutiva | excluir dados | aprovação forte |
| Execução | shell | sandbox + allowlist |
| Financeira | compra/pagamento | confirmação explícita |

---

# 7. Reasoning e saída JSON

## 7.1 Reasoning não é uniforme

Modelos diferentes podem usar:

- `reasoning_effort`;
- `reasoning_budget`;
- `thinking_token_budget`;
- `chat_template_kwargs.enable_thinking`;
- comandos no prompt, como `/think` ou `/no_think`;
- nenhum controle exposto.

Não envie todos esses campos juntos.

## 7.2 Exemplo com campos do endpoint específico

```json
{
  "model": "modelo-que-documenta-estes-campos",
  "messages": [
    {"role": "user", "content": "Resolva o problema e explique o resultado."}
  ],
  "reasoning_effort": "low",
  "reasoning_budget": 2048,
  "max_tokens": 4096
}
```

Use apenas quando a página do modelo declarar suporte.

## 7.3 `extra_body` no SDK OpenAI

Campos que não fazem parte da tipagem padrão do SDK podem ser enviados com `extra_body`:

```python
response = client.chat.completions.create(
    model=os.environ["NVIDIA_MODEL"],
    messages=[{"role": "user", "content": "Analise este algoritmo."}],
    max_tokens=2048,
    extra_body={
        "chat_template_kwargs": {
            "enable_thinking": True
        }
    },
)
```

No HTTP bruto, os campos de `extra_body` ficam no JSON principal conforme o contrato do endpoint.

## 7.4 Orçamento de tokens

Em alguns modelos:

```text
max_tokens = reasoning + resposta visível
```

Consequências:

- reasoning alto pode deixar pouco espaço para a resposta;
- JSON pode ser truncado;
- `finish_reason="length"` precisa ser tratado;
- custo e latência podem aumentar.

## 7.5 JSON object

Quando suportado:

```python
response = client.chat.completions.create(
    model=os.environ["NVIDIA_MODEL"],
    messages=[
        {
            "role": "system",
            "content": "Responda somente com JSON válido."
        },
        {
            "role": "user",
            "content": "Extraia nome e idade de: Ana, 31 anos."
        },
    ],
    response_format={"type": "json_object"},
)
```

Mesmo assim:

1. faça `json.loads`;
2. valide com schema;
3. rejeite campos extras;
4. trate truncamento;
5. não execute valores diretamente.

## 7.6 JSON Schema

Alguns modelos ou backends aceitam structured output com schema. O formato exato pode variar. Exemplo conceitual:

```json
{
  "type": "json_schema",
  "json_schema": {
    "name": "pessoa",
    "strict": true,
    "schema": {
      "type": "object",
      "properties": {
        "nome": {"type": "string"},
        "idade": {"type": "integer", "minimum": 0}
      },
      "required": ["nome", "idade"],
      "additionalProperties": false
    }
  }
}
```

Confirme se a página do modelo suporta `json_schema`, apenas `json_object` ou nenhum dos dois.

## 7.7 Parsing seguro

```python
from pydantic import BaseModel, ConfigDict, Field, ValidationError

class Pessoa(BaseModel):
    model_config = ConfigDict(extra="forbid")
    nome: str = Field(min_length=1, max_length=200)
    idade: int = Field(ge=0, le=150)

try:
    pessoa = Pessoa.model_validate_json(texto)
except ValidationError as exc:
    # solicitar correção, usar fallback ou falhar explicitamente
    raise
```

## 7.8 Não dependa de raciocínio oculto

Para auditoria, solicite:

- resultado;
- premissas;
- evidências;
- cálculos verificáveis;
- nível de confiança;
- limitações.

Não trate texto de reasoning como prova de correção. Valide o resultado por código, testes ou fontes.

---

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

---

# 9. Embeddings, reranking e RAG

## 9.1 Embeddings

Endpoint comum:

```text
POST https://integrate.api.nvidia.com/v1/embeddings
```

Exemplo:

```bash
curl "https://integrate.api.nvidia.com/v1/embeddings" \
  -H "Authorization: Bearer $NVIDIA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "'"$NVIDIA_EMBEDDING_MODEL"'",
    "input": ["Documento A", "Documento B"],
    "input_type": "passage",
    "encoding_format": "float",
    "truncate": "END"
  }'
```

## 9.2 `input_type`

Modelos Retriever podem exigir:

- `passage`: documentos a indexar;
- `query`: consulta de busca.

Use o tipo correto em cada etapa. A assimetria faz parte do treinamento de alguns modelos.

## 9.3 Campos comuns

| Campo | Uso |
|---|---|
| `model` | Identificador |
| `input` | String ou lista |
| `input_type` | `query` ou `passage`, quando exigido |
| `encoding_format` | `float` ou `base64`, conforme suporte |
| `truncate` | Política como `NONE`, `START` ou `END` |
| `user` | Pode ser ignorado por alguns endpoints |

Dimensão e contexto são específicos do modelo.

## 9.4 Python

```python
result = client.embeddings.create(
    model=os.environ["NVIDIA_EMBEDDING_MODEL"],
    input=["Clean Architecture separa regras de negócio."],
    encoding_format="float",
    extra_body={
        "input_type": "passage",
        "truncate": "END",
    },
)

vector = result.data[0].embedding
print(len(vector))
```

## 9.5 Normalização

Antes de indexar:

- preserve o texto original;
- normalize Unicode;
- remova lixo de layout;
- guarde metadados;
- use chunking coerente;
- não faça stemming agressivo sem avaliação;
- registre versão do modelo de embedding.

Nunca misture vetores de modelos ou dimensões diferentes no mesmo índice sem separação.

## 9.6 Chunking

Ponto de partida:

- 300 a 800 tokens por chunk;
- overlap de 10% a 20%;
- respeitar títulos e parágrafos;
- não cortar tabelas no meio;
- guardar `document_id`, `chunk_id`, página e seção.

Ajuste por avaliação real.

## 9.7 Similaridade

Com embeddings normalizados, cosine similarity pode ser implementada por produto escalar:

```python
import numpy as np

def cosine(a, b):
    a = np.asarray(a, dtype=np.float32)
    b = np.asarray(b, dtype=np.float32)
    denom = np.linalg.norm(a) * np.linalg.norm(b)
    if denom == 0:
        return 0.0
    return float(np.dot(a, b) / denom)
```

## 9.8 Reranking

Fluxo:

```text
query
  -> embedding/lexical/hybrid retrieval
  -> top 20-200 candidatos
  -> reranker
  -> top 3-20
  -> prompt do LLM
```

Um reranker cross-encoder avalia a consulta junto de cada candidato. É mais caro que busca vetorial e não deve percorrer o corpus inteiro.

## 9.9 Endpoint de reranking

A URL é específica do modelo, por exemplo no padrão:

```text
POST https://ai.api.nvidia.com/v1/retrieval/<modelo>/reranking
```

Payload típico:

```json
{
  "model": "modelo-de-reranking",
  "query": {
    "text": "Como funciona o fluxo de aprovação?"
  },
  "passages": [
    {"text": "Documento 1..."},
    {"text": "Documento 2..."}
  ],
  "truncate": "END"
}
```

Não generalize o caminho ou schema sem abrir a página do reranker.

## 9.10 Pipeline RAG

```python
def answer_with_rag(question: str) -> str:
    query_vector = embed_query(question)
    candidates = vector_store.search(query_vector, limit=50)
    reranked = rerank(question, candidates)
    selected = reranked[:8]

    context = "\n\n".join(
        f"[{item['source']}]\n{item['text']}"
        for item in selected
    )

    response = client.chat.completions.create(
        model=os.environ["NVIDIA_CHAT_MODEL"],
        messages=[
            {
                "role": "system",
                "content": (
                    "Responda apenas com base no contexto. "
                    "Cite os identificadores das fontes. "
                    "Quando faltar evidência, diga que não encontrou."
                ),
            },
            {
                "role": "user",
                "content": f"CONTEXTO:\n{context}\n\nPERGUNTA:\n{question}",
            },
        ],
        temperature=0.1,
    )
    return response.choices[0].message.content
```

## 9.11 Avaliação

Meça separadamente:

- recall@k da recuperação;
- MRR ou NDCG do ranking;
- precisão factual;
- completude;
- taxa de citação correta;
- abstention quando não há evidência;
- latência;
- custo/tokens;
- resistência a prompt injection no corpus.

## 9.12 Versionamento

Ao trocar o embedding:

1. crie novo índice;
2. re-embed todo o corpus;
3. execute avaliação;
4. faça migração gradual;
5. mantenha rollback.

Não atualize metade do índice com o modelo novo.

---

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

---

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

---

# 12. APIs especializadas

## 12.1 Princípio geral

APIs especializadas não devem ser encapsuladas como se fossem Chat Completions. Crie adaptadores por domínio.

```typescript
interface NvidiaAdapter<Input, Output> {
  validate(input: Input): void;
  invoke(input: Input, signal?: AbortSignal): Promise<Output>;
  normalize(raw: unknown): Output;
}
```

## 12.2 Healthcare e biologia

O catálogo pode incluir modelos e pipelines para:

- sequências genômicas;
- multiple sequence alignment;
- estrutura de proteínas;
- design de proteínas;
- docking molecular;
- geração molecular;
- imagens médicas;
- segmentação 3D.

Entradas possíveis:

- FASTA;
- PDB/mmCIF;
- SMILES;
- volumes médicos;
- máscaras;
- parâmetros científicos;
- assets.

Saídas possíveis:

- sequências;
- estruturas;
- coordenadas;
- scores;
- arquivos;
- visualizações;
- jobs assíncronos.

Boas práticas:

- valide alfabeto e tamanho das sequências;
- normalize unidades;
- preserve identificadores;
- registre versão de banco de dados;
- não trate o resultado como diagnóstico;
- mantenha revisão humana especializada;
- respeite privacidade de dados clínicos;
- siga licença e intended use do model card.

## 12.3 Clima

Endpoints de modelos climáticos podem usar domínio como:

```text
https://climate.api.nvidia.com/...
```

Entradas podem incluir:

- condição inicial;
- dataset ou sample ID;
- variáveis atmosféricas;
- área geográfica;
- horizonte;
- resolução.

Saídas podem ser arrays científicos, NetCDF, mapas ou assets. Preserve CRS, grade, unidade, timestamp e convenção de longitude.

## 12.4 Otimização com cuOpt

Endpoint hospedado pode seguir:

```text
POST https://optimize.api.nvidia.com/v1/nvidia/cuopt
```

Casos:

- vehicle routing;
- pickup and delivery;
- time windows;
- capacidades;
- custos;
- restrições.

Para instâncias grandes, use assets quando indicado. Valide:

- matriz de custos;
- simetria ou assimetria;
- índices de nós;
- unidade de tempo;
- capacidade;
- veículos;
- janelas;
- solução inviável.

## 12.5 Detecção de mídia sintética

Alguns modelos usam gRPC e recebem:

- vídeo;
- áudio;
- frames;
- metadados.

A saída é probabilística. Não use um único score como prova definitiva. Defina threshold por avaliação, mantenha trilha de auditoria e revisão humana.

## 12.6 Áudio

Famílias possíveis:

- ASR;
- tradução;
- text-to-speech;
- remoção de ruído;
- diarização;
- speaker detection.

Parâmetros recorrentes:

- sample rate;
- canais;
- codec;
- idioma;
- timestamps;
- segmentação;
- voz;
- streaming.

Sempre converta áudio para formato aceito e evite resampling repetido.

## 12.7 Safety e guardrails

Modelos de segurança podem classificar:

- prompt;
- resposta;
- imagem;
- combinação multimodal.

Arquitetura:

```text
input
 -> validação
 -> guard de entrada
 -> modelo principal
 -> guard de saída
 -> política da aplicação
 -> usuário
```

Um guard model não substitui autorização, validação de tools ou política de negócio.

## 12.8 Adaptador por endpoint

```python
from dataclasses import dataclass
from typing import Protocol, Any

class Adapter(Protocol):
    def invoke(self, payload: dict[str, Any]) -> Any: ...

@dataclass
class EndpointConfig:
    url: str
    timeout_seconds: int
    asynchronous: bool
    uses_assets: bool
    transport: str
```

Mantenha testes de contrato gravados para cada adaptador.

---

# 13. Erros, limites e resiliência

## 13.1 Não há uma quota universal

Endpoints do catálogo são compartilhados e cada serviço pode ter:

- limite de requisições;
- limite de tokens;
- limite de concorrência;
- limite do worker;
- fila;
- tamanho máximo;
- timeout;
- créditos;
- restrição por função.

Não existe uma única tabela aplicável a todos os modelos. Leia a página do endpoint e trate o comportamento observado.

## 13.2 Códigos comuns

| Código | Interpretação provável | Ação |
|---:|---|---|
| 200 | Sucesso | processar |
| 202 | Processamento pendente | polling |
| 302 | Resultado grande em outra URL | ler `Location` |
| 400 | JSON ou parâmetro inválido | corrigir, não fazer retry cego |
| 401 | Chave ausente/inválida | corrigir secret |
| 402 | Créditos/entitlement | verificar conta |
| 403 | Permissão/escopo | verificar acesso |
| 404 | Endpoint, função ou modelo | revisar configuração |
| 408 | Timeout | retry condicionado |
| 409 | Conflito | verificar idempotência |
| 413 | Payload grande | asset ou compressão aceita |
| 422 | Validação semântica | corrigir payload |
| 429 | Rate limit/ResourceExhausted | backoff e reduzir concorrência |
| 500 | Falha interna | retry limitado |
| 502/503/504 | indisponibilidade | retry limitado/fallback |

O corpo da resposta é a fonte principal.

## 13.3 `ResourceExhausted`

Mensagens como:

```text
ResourceExhausted: Worker local total request limit reached
```

normalmente indicam saturação ou limite de concorrência do worker/serviço. Não há garantia de uma data fixa de reset.

Ações:

1. reduza concorrência;
2. adicione fila;
3. backoff exponencial com jitter;
4. respeite `Retry-After`;
5. tente modelo alternativo aprovado;
6. faça self-host quando precisar de capacidade previsível;
7. não crie tempestade de retries.

## 13.4 Retry policy

Faça retry apenas para falhas transitórias:

```python
RETRYABLE = {408, 429, 500, 502, 503, 504}
```

Alguns `409` e `202` têm fluxo próprio.

```python
import random
import time
import requests

def post_with_retry(url, headers, payload, attempts=5):
    for attempt in range(attempts):
        try:
            response = requests.post(
                url,
                headers=headers,
                json=payload,
                timeout=(10, 120),
            )
        except (requests.Timeout, requests.ConnectionError):
            response = None

        if response is not None and response.status_code not in RETRYABLE:
            response.raise_for_status()
            return response

        if attempt == attempts - 1:
            if response is not None:
                response.raise_for_status()
            raise TimeoutError("Falha de rede após retries")

        retry_after = (
            response.headers.get("Retry-After")
            if response is not None
            else None
        )
        delay = float(retry_after) if retry_after else min(2 ** attempt, 30)
        time.sleep(delay + random.uniform(0, 0.5))
```

## 13.5 Concorrência limitada

```python
import asyncio

semaphore = asyncio.Semaphore(4)

async def invoke_bounded(call):
    async with semaphore:
        return await call()
```

Ajuste por endpoint e ambiente.

## 13.6 Circuit breaker

Abra o circuito quando ocorrer:

- sequência de 5xx;
- taxa alta de 429;
- latência extrema;
- timeout repetido.

Estados:

```text
CLOSED -> OPEN -> HALF_OPEN -> CLOSED
```

Não conte `400/422` como falha do provedor.

## 13.7 Idempotência

Para operações que geram assets, jobs ou efeitos:

- atribua `operation_id` interno;
- salve request ID;
- não reenvie ao perder a conexão sem verificar estado;
- deduplique por hash de entrada quando apropriado.

## 13.8 Fallback

Política explícita:

```text
modelo primário
 -> mesmo modelo self-hosted
 -> modelo alternativo compatível
 -> resposta degradada
 -> fila
 -> erro claro
```

Não troque silenciosamente para um modelo com licença, contexto ou segurança diferente.

## 13.9 Limites locais

Aplique antes de chamar a NVIDIA:

- tamanho do prompt;
- quantidade de mensagens;
- bytes de base64;
- número de imagens;
- duração de vídeo;
- tokens máximos;
- tools por requisição;
- profundidade de agente;
- requisições por usuário.

## 13.10 Diagnóstico mínimo

Registre:

- endpoint lógico, sem secret;
- model ID;
- status code;
- request ID;
- duração;
- tentativa;
- tamanho de entrada;
- tokens;
- `finish_reason`;
- erro sanitizado;
- concorrência atual.

---

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

---

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

---

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

---

# Referências oficiais

> Consulte as páginas novamente antes de implantar, pois o catálogo e as versões NIM mudam.

## Catálogo e início rápido

- [NVIDIA API Catalog](https://build.nvidia.com/)
- [API Catalog Quickstart](https://docs.api.nvidia.com/nim/docs/api-quickstart)
- [NVIDIA NIM General FAQ](https://docs.nvidia.com/nim/faq/latest/general.html)
- [Run NIM Anywhere](https://build.nvidia.com/explore/discover)

## LLM

- [LLM APIs — NVIDIA API Reference](https://docs.api.nvidia.com/nim/reference/llm-apis)
- [NVIDIA NIM for LLMs — API Reference](https://docs.nvidia.com/nim/large-language-models/latest/api-reference.html)
- [NVIDIA NIM for LLMs — Documentation](https://docs.nvidia.com/nim/large-language-models/latest/)
- [Tool calling e MCP no NIM](https://docs.nvidia.com/nim/large-language-models/latest/function-calling.html)
- [Observability no NIM for LLMs](https://docs.nvidia.com/nim/large-language-models/latest/observability.html)
- [Support Matrix](https://docs.nvidia.com/nim/large-language-models/latest/supported-models.html)

## Retrieval

- [Retrieval APIs](https://docs.api.nvidia.com/nim/reference/retrieval-apis)
- [NVIDIA Retrieval NIMs](https://docs.nvidia.com/nim/nemo-retriever/text-embedding/latest/)

## Vision e geração visual

- [NIM for Vision Language Models — API Reference](https://docs.nvidia.com/nim/vision-language-models/latest/api-reference.html)
- [NIM Visual Generative AI — OpenAI Image Generation API](https://docs.nvidia.com/nim/visual-genai/latest/api/openai-image-generation.html)
- [Visual Generative AI NIM Documentation](https://docs.nvidia.com/nim/visual-genai/latest/)

## NVCF

- [NVCF API Reference](https://docs.nvidia.com/cloud-functions/user-guide/latest/cloud-function/api-reference.html)
- [NVCF Assets](https://docs.nvidia.com/cloud-functions/user-guide/latest/cloud-function/assets.html)
- [NVCF Function Invocation](https://docs.nvidia.com/cloud-functions/user-guide/latest/cloud-function/function-invocation.html)

## Segurança e operação

- [NVIDIA NIM Model Signature Verification](https://docs.nvidia.com/nim/large-language-models/latest/model-signing.html)
- [NVIDIA AI Enterprise](https://www.nvidia.com/en-us/data-center/products/ai-enterprise/)
