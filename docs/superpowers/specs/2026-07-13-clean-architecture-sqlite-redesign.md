# BytePapo Clean Architecture, SQLite e Redesign

## Contexto

O BytePapo mistura transporte HTTP, serialização de payloads, parsing de streaming e seleção de provedor em `ApiClient` e `StreamParser`. NVIDIA e Ollama têm protocolos diferentes: NVIDIA usa Chat Completions compatível com OpenAI e streaming SSE; Ollama usa endpoints próprios e streaming NDJSON. A persistência atual usa listas JSON em `SharedPreferences`, o que acopla repositórios ao mecanismo de armazenamento e não escala para histórico, busca ou paginação.

A navegação e as telas de servidores e modelos também serão substituídas pelo conceito visual aprovado. O redesign inclui gerenciamento completo de servidores, catálogo pesquisável e paginado de modelos e configuração de prompts e personagens.

## Objetivos

- Reorganizar todas as features em Clean Architecture feature-first.
- Separar completamente clientes, DTOs, payloads, parsers e erros de NVIDIA e Ollama.
- Substituir a persistência funcional por SQLite gerenciado pelo Drift.
- Criar um banco novo, sem importar ou migrar dados do `SharedPreferences`.
- Remover `List<dynamic>` e expor entidades de domínio tipadas à apresentação.
- Implementar CRUD completo de servidores e personagens, incluindo foto local.
- Implementar pesquisa e paginação de modelos sem carregar uma lista extensa na tela.
- Reproduzir fielmente as referências visuais aprovadas, sem reinterpretação.

## Fora do escopo

- Migração, leitura ou exclusão dos dados legados do `SharedPreferences`.
- Pesquisa web, tool calling ou navegação autônoma do modelo.
- Sincronização em nuvem ou backup remoto.
- Transformar features em packages Dart independentes.
- Descoberta genérica de protocolos além de NVIDIA e Ollama.
- Alterações visuais divergentes das referências aprovadas.

## Referências visuais obrigatórias

- `docs/assets/bytepapo-redesign-approved.png`: Chat, Servidores, Modelos e navegação inferior.
- `docs/assets/bytepapo-settings-approved.png`: Configurações, Personagens e edição de personagem.

Essas imagens são especificações de produção. A implementação deve preservar composição, textos, hierarquia, densidade, paleta, tipografia, espaçamento, bordas, ícones, estados selecionados e ações visíveis. O app manterá exatamente quatro destinos na navegação inferior: `Chat`, `Servidores`, `Modelos` e `Histórico`. Configurações será aberta pelo menu de três pontos; não haverá uma quinta aba.

## Arquitetura

### Organização feature-first

Cada feature terá limites explícitos:

```text
lib/
  app/                         inicialização, tema, roteamento e shell
  core/
    database/                  Drift, tabelas e abertura do banco
    errors/                    falhas compartilhadas mínimas
    network/                   transporte HTTP compartilhável, sem protocolo
    secure_storage/            API keys e outros segredos
  features/
    chat/
      domain/                  mensagens, chunks, opções e casos de uso
      data/                    mapeadores e repositórios Drift
      presentation/            controller e tela
    servers/
      domain/                  perfil, CRUD, ativação e teste
      data/                    DAO, repositório e fotos gerenciadas
      presentation/            lista e formulário
    models/
      domain/                  modelo disponível, busca, paginação e seleção
      data/                    agregação dos catálogos e persistência
      presentation/            catálogo paginado
    history/
      domain/                  consulta paginada e remoção
      data/                    consultas Drift
      presentation/            lista e abertura de conversa
    characters/
      domain/                  personagem, ativação e CRUD
      data/                    DAO, repositório e fotos gerenciadas
      presentation/            lista e editor
    settings/
      domain/                  prompt global
      data/                    repositório Drift
      presentation/            hub e editor do prompt
    providers/
      domain/                  contratos neutros de catálogo e chat
      data/
        nvidia/                cliente, endpoints, DTOs, SSE e erros NVIDIA
        ollama/                cliente, endpoints, DTOs, NDJSON e erros Ollama
  shared/
    presentation/              shell, navegação e widgets realmente comuns
    providers/                 composição Riverpod
```

Dependências apontam para dentro: apresentação usa casos de uso; casos de uso usam contratos de domínio; data implementa contratos. O domínio é Dart puro e não importa Flutter, Riverpod, HTTP, Drift, SQLite, armazenamento seguro ou DTOs.

### Interfaces segregadas

O domínio de providers terá contratos pequenos:

- `ModelCatalogGateway`: lista modelos de um servidor.
- `ChatCompletionGateway`: produz `Stream<ChatChunk>` para um servidor e modelo.
- `ProviderGatewayResolver`: resolve os contratos pelo `ApiProvider`.

NVIDIA e Ollama podem implementar ambos os contratos, mas não compartilham payloads ou parsers. O resolver é configurado pelo Riverpod. Casos de uso e controllers não contêm `if (provider == ...)` para decidir protocolo.

### Casos de uso

Os fluxos públicos serão coordenados por casos de uso focados, incluindo:

- servidores: listar, criar, editar, remover, ativar e testar conexão;
- modelos: carregar catálogo agregado, pesquisar, paginar e selecionar;
- chat: enviar, cancelar, carregar conversa e limpar conversa;
- histórico: pesquisar, paginar, abrir e remover conversa;
- personagens: listar, criar, editar, remover e ativar;
- configurações: carregar e salvar prompt global.

Controllers Riverpod mantêm somente estado de apresentação e delegam regras a casos de uso.

## Persistência SQLite

### Banco novo

O Drift abrirá um arquivo SQLite novo com `schemaVersion = 1`. Não haverá serviço de migração de `SharedPreferences`, marcador de migração ou fallback para os dados antigos. A dependência `shared_preferences` será removida quando nenhum fluxo funcional depender dela.

### Tabelas

#### `server_profiles`

- `id` texto, chave primária;
- `name` texto;
- `provider` texto (`ollama` ou `nvidia`);
- `protocol`, `host`, `port` e `base_path`;
- `avatar_path` anulável;
- `api_key_alias` anulável, apontando para armazenamento seguro;
- `last_connection_status` (`unknown`, `connected`, `disconnected`);
- `last_connected_at` e `last_checked_at` anuláveis;
- `created_at` e `updated_at`.

API keys nunca serão gravadas no SQLite. `flutter_secure_storage` guardará a chave com alias derivado do ID do servidor. Remover um servidor também remove seu segredo depois da transação do banco ser confirmada.

#### `app_settings`

Tabela chave/valor para `active_server_id`, `active_character_id` e `global_prompt`. IDs ativos inexistentes são tratados como nulos.

#### `selected_models`

- `server_profile_id` chave primária e estrangeira;
- `model_id`;
- `updated_at`.

Ao remover um servidor, sua seleção de modelo é removida em cascata.

#### `conversations`

- metadados atuais da conversa;
- `server_profile_id` anulável;
- `server_name_snapshot` e `provider_snapshot`;
- `character_id` anulável e `character_name_snapshot`;
- `model`, `system_prompt`, datas e arquivamento.

Excluir servidor ou personagem não apaga histórico. As referências tornam-se nulas e os snapshots preservam o contexto exibido.

#### `chat_messages`

- campos atuais de `ChatMessage`;
- chave estrangeira para conversa com exclusão em cascata;
- índice composto por `conversation_id` e `created_at`;
- tool calls persistidas em JSON somente como detalhe da mensagem, isolado pelo mapper.

#### `chat_characters`

- `id`, `name`, `instructions`, `avatar_path`, `created_at` e `updated_at`.

#### Fotos locais

Fotos escolhidas para servidores e personagens serão copiadas para diretórios gerenciados pelo app. O banco guarda apenas o caminho gerenciado. Atualização e remoção limpam a imagem anterior somente depois do sucesso da operação principal. Caminhos externos temporários do seletor de imagens não são persistidos diretamente.

## Integrações de modelo

### NVIDIA

- `GET /v1/models` com `Authorization: Bearer`.
- `POST /v1/chat/completions` com mensagens no formato OpenAI, modelo e opções compatíveis.
- `Accept: text/event-stream` quando `stream` for verdadeiro.
- Parser SSE exclusivo, capaz de recompor UTF-8 e eventos divididos em chunks, aceitar `data:` com ou sem espaço, processar `choices[].delta.content`, tool calls e terminar em `[DONE]` ou `finish_reason`.
- Falhas de autenticação, permissão, modelo/endpoint, limite, validação, servidor, TLS, rede e timeout produzem falhas NVIDIA.

### Ollama

- `GET /api/tags` para modelos.
- `POST /api/chat` com payload Ollama, `think` e `options` quando aplicáveis.
- Parser NDJSON exclusivo, capaz de recompor UTF-8 e linhas divididas, processar `message.thinking`, `message.content`, tool calls e terminar em `done: true`.
- Falhas de endpoint, modelo, rede, cleartext, TLS e timeout produzem falhas Ollama.

### Opções e mensagens

Entidades de domínio são neutras. Cada adapter converte mensagens e `GenerationOptions` para seu próprio DTO. Campos exclusivos do Ollama, como `num_ctx` e `think`, nunca entram no payload NVIDIA. Campos OpenAI/NVIDIA nunca são interpretados pelo parser Ollama.

## Fluxos funcionais

### Servidores

- A tela lista servidores com nome personalizado, avatar, provedor e último estado de conexão.
- O usuário pode adicionar, editar, testar, ativar e excluir.
- Exclusão exige confirmação e preserva conversas existentes por snapshots.
- O formulário NVIDIA fixa HTTPS, host oficial e base `/v1`, mas permite nome e foto personalizados.
- O formulário Ollama permite protocolo, host, porta e base path.

### Catálogo agregado de modelos

A tela de modelos representa modelos de todos os servidores cadastrados, como na referência aprovada. O caso de uso consulta cada servidor e converte respostas para `AvailableModel`, contendo `id`, nome exibido, provider, servidor, tamanho/metadados disponíveis e identidade composta.

- Falha em um servidor não descarta resultados dos demais; a tela apresenta feedback parcial.
- Modelos iguais em servidores diferentes permanecem entradas distintas.
- Pesquisa é case-insensitive pelo ID/nome do modelo.
- O filtro `Fornecedor` aceita Todos, NVIDIA e Ollama.
- Filtro e busca são aplicados antes da paginação.
- A página contém 10 resultados; a mudança de busca/filtro volta à página 1.
- `Anterior` e `Próxima` respeitam os limites e a tela mostra página, intervalo e total.
- Selecionar um item grava o modelo daquele servidor e torna o mesmo servidor ativo numa única operação lógica.

### Chat

- O chat usa exclusivamente o servidor e modelo selecionados juntos.
- O prompt do sistema combina prompt global e prompt do personagem ativo.
- A mensagem do usuário é persistida antes da requisição.
- Chunks atualizam thinking e conteúdo incrementalmente.
- Conclusão, erro e cancelamento sempre fecham o estado de streaming e persistem o estado final da resposta.
- Erros preservam a mensagem do usuário e exibem texto específico do provedor.

### Configurações e personagens

- Configurações abre pelo menu de três pontos.
- O hub exibe e permite editar o prompt global.
- O hub exibe o personagem ativo e navega para gerenciamento.
- Personagens podem ser pesquisados, adicionados, selecionados, editados, excluídos e receber foto.
- Excluir o personagem ativo deixa a seleção vazia; não escolhe outro implicitamente.
- O prompt do personagem é combinado com o global no envio, conforme texto aprovado na tela.

### Histórico

- Histórico é destino fixo da navegação inferior.
- Consultas são paginadas no SQLite, ordenadas por `updated_at` decrescente.
- Pesquisa cobre título, modelo, snapshot de servidor/personagem e conteúdo de mensagens.
- Abrir uma conversa navega ao chat; remover uma conversa apaga suas mensagens em cascata.

## Navegação e apresentação

Um shell compartilhado mantém a barra inferior exatamente com quatro destinos. Rotas aninhadas de formulários e editores usam seta de voltar e podem ocultar a barra inferior quando a referência aprovada assim mostra. Configurações não vira destino inferior.

Widgets compartilhados serão limitados a elementos visuais realmente reutilizados: shell, barra inferior, avatar circular, estados assíncronos, campo de busca, linha de ação e paginação. Widgets não fazem chamadas HTTP ou SQL.

O tema será extraído das imagens aprovadas antes da implementação: cores, escala tipográfica, raios, divisores, espaçamentos, tamanhos de ícones e estados. Não serão adicionados gradientes, glow, glassmorphism, bento grids, ilustrações decorativas ou uma quinta aba.

## Erros e consistência

- Falhas de domínio possuem mensagens estáveis e causa opcional.
- Adapters traduzem erros técnicos; controllers não inspecionam códigos HTTP.
- Operações que abrangem banco e armazenamento seguro compensam falhas para não deixar alias sem chave ou chave órfã.
- A seleção servidor/modelo é atualizada de forma transacional no SQLite.
- Exclusões destrutivas exigem confirmação visual.
- Estados vazios e parciais oferecem ação de recuperação apropriada.

## Estratégia de testes

O desenvolvimento seguirá TDD com falha observada antes de cada implementação.

- Domínio: casos de uso, regras de paginação, busca, seleção conjunta, composição de prompt e preservação de histórico.
- NVIDIA: request, autenticação, DTOs, SSE fragmentado, `[DONE]`, tool calls e falhas específicas.
- Ollama: request, opções, NDJSON fragmentado, thinking, content, done e falhas específicas.
- Drift: DAOs, constraints, cascatas, snapshots, busca e paginação em banco temporário.
- Repositórios: mapeamento entre rows e entidades e coordenação com armazenamento seguro/fotos.
- Controllers: loading, dados, resultado parcial, erro, cancelamento e atualização incremental.
- Widgets: navegação inferior, CRUD de servidores/personagens, confirmação de exclusão, pesquisa/paginação e configurações.
- Golden/visual: telas nos tamanhos das referências aprovadas e comparação manual obrigatória.
- Android: build debug, instalação e fluxo principal no aparelho conectado.

## Critérios de aceite

- Nenhum cliente ou parser processa os dois protocolos.
- Domínio não importa dependências externas.
- Nenhum repositório funcional usa `SharedPreferences`.
- API keys não aparecem no SQLite, logs ou mensagens de erro.
- Banco novo inicia vazio e não importa dados antigos.
- Servidores e personagens suportam adicionar, editar, excluir, selecionar e foto conforme as referências.
- Modelos suportam agregação, pesquisa, filtro e páginas de 10 itens.
- Seleção de modelo também ativa seu servidor.
- Streaming NVIDIA SSE e Ollama NDJSON funcionam nos seus adapters e atualizam o chat incrementalmente.
- As telas reproduzem fielmente `bytepapo-redesign-approved.png` e `bytepapo-settings-approved.png`.
- Não existem controles inertes, overflow no viewport aprovado ou divergências visuais não documentadas.
- `dart format lib test`, `flutter analyze`, `flutter test` e `flutter build apk --debug` terminam com sucesso.

