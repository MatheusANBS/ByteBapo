# Correção do fluxo da API NVIDIA

## Objetivo

Restaurar o fluxo NVIDIA já existente no BytePapo para que o usuário consiga cadastrar a chave, testar a conexão, listar e selecionar modelos e conversar por streaming. O trabalho não adiciona capacidades novas ou tratamento específico por modelo.

## Escopo

O conserto cobre:

- montagem das URLs `https://integrate.api.nvidia.com/v1/models` e `https://integrate.api.nvidia.com/v1/chat/completions`;
- compatibilidade com perfis NVIDIA salvos antes e depois da regressão de URL;
- preservação do header `Authorization: Bearer <api-key>` na criação, persistência e restauração do perfil;
- classificação correta de falhas HTTP, rede, TLS e timeout como erros NVIDIA;
- mensagens de erro coerentes no teste de conexão NVIDIA;
- testes automatizados da listagem de modelos, autenticação, chat streaming e URLs.

Ficam fora do escopo:

- reasoning, visão, tools, embeddings ou parâmetros específicos por modelo;
- descoberta dinâmica de capacidades;
- novo suporte a configuração por `.env`;
- mudanças no fluxo Ollama além das necessárias para preservar o comportamento atual.

## Arquitetura

### Fonte única para a versão da API

O segmento `/v1` ficará no `basePath` dos perfis NVIDIA. `NvidiaEndpoints` continuará expondo caminhos relativos, como `models` e `chat/completions`. Assim, cada URL contém `/v1` exatamente uma vez e o `ServerProfile.resolve()` continua sendo o único combinador genérico de URL.

A criação de um novo perfil NVIDIA usará `basePath: '/v1'`. A restauração de perfis persistidos normalizará o `basePath` NVIDIA para `/v1`, corrigindo tanto perfis salvos com valor vazio quanto perfis antigos já salvos com `/v1`. Essa normalização evita exigir que o usuário apague e cadastre novamente a configuração.

### Cliente HTTP e erros

`ApiClient` continuará compartilhando transporte entre Ollama e NVIDIA, mas a proteção contra timeout, socket, TLS e `http.ClientException` receberá o provedor da operação. Uma falha de transporte NVIDIA produzirá `NvidiaApiException`; uma operação Ollama continuará produzindo `OllamaApiException`.

Respostas HTTP NVIDIA continuarão usando o mapeamento existente para `401`, `403`, `404`, `422`, `429` e `5xx`. O teste de conexão não acrescentará orientações de IP, Wi-Fi ou firewall quando o provedor for NVIDIA.

### Modelos e chat

A listagem continuará consumindo o formato OpenAI compatível `{ "data": [...] }` de `GET /v1/models` e convertendo cada entrada em `NvidiaModel`. A seleção de modelo existente não será alterada.

O chat continuará enviando `POST /v1/chat/completions` com o modelo selecionado, mensagens no formato OpenAI, `Authorization`, `Content-Type: application/json` e `Accept: text/event-stream`. O parser SSE existente continuará processando `data: {...}` e `[DONE]`.

## Fluxo de dados

1. O usuário escolhe NVIDIA e informa a API key.
2. A tela cria um `ServerProfile` HTTPS para `integrate.api.nvidia.com`, porta `443` e base path `/v1`.
3. `ServerProfile` cria o header Bearer e o repositório persiste o perfil.
4. Ao restaurar o perfil, o base path e o header são reconstruídos de forma determinística.
5. O teste de conexão chama `GET /v1/models`.
6. A tela de modelos exibe a lista retornada e persiste o identificador selecionado.
7. O chat envia o modelo selecionado para `POST /v1/chat/completions` e entrega os eventos SSE ao parser atual.

## Tratamento de compatibilidade

- Perfil NVIDIA com `basePath` ausente, vazio ou `/`: normalizar para `/v1`.
- Perfil NVIDIA com `basePath: '/v1'`: manter `/v1`.
- Perfil Ollama: preservar o `basePath` persistido sem normalização NVIDIA.
- Header NVIDIA persistido ausente ou desatualizado: reconstruir a partir de `apiKey` quando ela não estiver vazia.

## Estratégia de testes

O desenvolvimento seguirá TDD, com cada teste executado primeiro em estado vermelho.

Testes de `ServerProfile` verificarão:

- base URL NVIDIA nova termina em `/v1`;
- `resolve('models')` produz `/v1/models` sem duplicação;
- perfis NVIDIA persistidos sem `/v1` são normalizados;
- perfis Ollama preservam seus caminhos;
- o header Bearer sobrevive à restauração.

Testes de `ApiClient` verificarão:

- listagem usa `GET https://integrate.api.nvidia.com/v1/models` com Bearer;
- resposta `data` é convertida em `NvidiaModel`;
- chat usa `POST https://integrate.api.nvidia.com/v1/chat/completions` com headers e corpo esperados;
- streaming SSE retorna conteúdo até `[DONE]`;
- falha de transporte NVIDIA produz `NvidiaApiException`;
- status HTTP relevantes continuam produzindo falhas NVIDIA.

Ao final serão executados `dart format lib test`, `flutter analyze` e `flutter test`.

## Critérios de aceite

- Uma configuração NVIDIA nova testa conexão sem retornar `404` por URL incorreta.
- Uma configuração NVIDIA já salva durante a regressão passa a usar `/v1` sem recadastro.
- A lista de modelos NVIDIA é carregada e um modelo pode ser selecionado pelo fluxo atual.
- O chat envia mensagens ao endpoint NVIDIA correto e processa a resposta em streaming.
- Falhas NVIDIA não são apresentadas como falhas Ollama.
- Todos os testes e a análise estática passam.
