# SOLID Boundaries Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduzir arquivos monolíticos e separar UI, orquestração, infraestrutura e mapeamento sem alterar os fluxos visíveis do BytePapo.

**Architecture:** Cada feature passa a expor widgets de apresentação pequenos e uma camada de coordenação testável. Adaptadores Android, casos de uso de servidor e mapeadores Drift deixam de ser implementados por telas ou repositórios extensos. A composição Riverpod permanece uma raiz de composição, dividida por feature.

**Tech Stack:** Flutter, Riverpod, Drift, flutter_test.

## Global Constraints

- Preservar rotas, textos, comportamento de streaming e aparência atual.
- Nenhum widget chama `MethodChannel`, SQL, armazenamento seguro ou gateway HTTP diretamente.
- Dependências apontam para contratos; infraestrutura é composta pelo Riverpod.
- Cada extração começa com teste de regressão em falha e termina com `flutter analyze` e testes do escopo.

---

### Task 1: Fragmentar a tela de chat

**Files:**
- Create: `lib/features/chat/presentation/widgets/chat_composer.dart`
- Create: `lib/features/chat/presentation/widgets/chat_message_list.dart`
- Create: `lib/features/chat/presentation/widgets/chat_character_selector.dart`
- Modify: `lib/features/chat/presentation/chat_screen.dart`
- Test: `test/features/chat/presentation/chat_screen_test.dart`

**Produces:** `ChatComposer`, `ChatMessageList` e `ChatCharacterSelector` recebem callbacks e estado simples; `ChatScreen` só coordena rota, controller e layout.

- [ ] Escrever widget test que envia uma mensagem pelo callback do composer e verifica que o seletor recebe personagens.
- [ ] Executar `flutter test test/features/chat/presentation/chat_screen_test.dart` e observar falha pela ausência dos widgets extraídos.
- [ ] Mover os widgets privados sem alterar os parâmetros públicos: `controller`, `messageController`, `characters`, `activeCharacter`, `onCharacterChanged`, `onSubmitted` e `thinkingMode`.
- [ ] Executar o teste e `flutter analyze`; ambos devem passar.

### Task 2: Extrair fluxos de servidor da tela

**Files:**
- Create: `lib/features/servers/domain/server_connection_tester.dart`
- Create: `lib/features/servers/application/server_commands.dart`
- Create: `lib/features/servers/presentation/widgets/server_form.dart`
- Modify: `lib/features/servers/presentation/server_screen.dart`
- Modify: `lib/shared/providers.dart`
- Test: `test/features/servers/application/server_commands_test.dart`

**Produces:** `ServerCommands.saveAndActivate`, `testConnection` e `select` isolam persistência, resolução de catálogo e invalidação; `ServerForm` contém controllers e validação local.

- [ ] Escrever teste que usa fakes de `ServerRepository` e `ModelCatalogGateway`, chama `testConnection` e espera mensagem específica do provider.
- [ ] Executar `flutter test test/features/servers/application/server_commands_test.dart` e observar falha por contratos ausentes.
- [ ] Implementar comandos que recebem abstrações e retornam resultados tipados, sem `BuildContext`, `WidgetRef` ou navegação.
- [ ] Fazer `ServerScreen` delegar aos comandos e manter somente `setState`, feedback e `context.go`.
- [ ] Executar o teste do comando, `test/widget_test.dart` e `flutter analyze`.

### Task 3: Separar configurações, personagens e picker Android

**Files:**
- Create: `lib/features/characters/domain/avatar_picker.dart`
- Create: `lib/features/characters/data/platform_avatar_picker.dart`
- Create: `lib/features/settings/presentation/widgets/global_prompt_editor.dart`
- Create: `lib/features/settings/presentation/widgets/character_list.dart`
- Modify: `lib/features/settings/presentation/settings_screen.dart`
- Modify: `lib/shared/providers.dart`
- Test: `test/features/characters/data/platform_avatar_picker_test.dart`

**Produces:** `AvatarPicker.pickImagePath()` encapsula `MethodChannel`; widgets de configurações recebem callbacks e não importam serviços de plataforma ou repositórios.

- [ ] Escrever teste do adapter com `TestDefaultBinaryMessengerBinding` que retorna um caminho e espera o mesmo `String?`.
- [ ] Executar o teste e observar falha por `PlatformAvatarPicker` ausente.
- [ ] Implementar `PlatformAvatarPicker` usando o canal `byte_papo/avatar_picker`; converter `null` para cancelamento e propagar erros de plataforma.
- [ ] Extrair editor de prompt e lista/editor de personagens; tela pai somente orquestra estado e navegação.
- [ ] Executar testes do adapter, widgets de configurações e `flutter analyze`.

### Task 4: Delimitar persistência e composição

**Files:**
- Create: `lib/core/database/tables/server_tables.dart`
- Create: `lib/core/database/tables/chat_tables.dart`
- Create: `lib/features/chat/data/mappers/conversation_mapper.dart`
- Create: `lib/features/chat/data/queries/conversation_search_query.dart`
- Create: `lib/features/chat/presentation/providers.dart`
- Create: `lib/features/servers/presentation/providers.dart`
- Modify: `lib/core/database/app_database.dart`
- Modify: `lib/features/chat/data/repositories/drift_conversation_repository.dart`
- Modify: `lib/shared/providers.dart`
- Test: `test/features/chat/data/mappers/conversation_mapper_test.dart`

**Produces:** `AppDatabase` declara executor, migrations e tabelas importadas; o mapper converte rows tipadas e JSON de tool calls; a query de histórico encapsula busca/paginação; providers ficam junto da feature.

- [ ] Escrever teste de round-trip para `ChatMessage` com tool calls usando `ConversationMapper`.
- [ ] Executar `flutter test test/features/chat/data/mappers/conversation_mapper_test.dart` e observar falha pelos tipos ausentes.
- [ ] Implementar o mapper com `Conversation` e `ChatMessage` gerados pelo Drift, sem `dynamic`.
- [ ] Extrair as definições `Table` sem alterar os nomes SQL, atualizar `@DriftDatabase` e rodar `dart run build_runner build`.
- [ ] Mover apenas providers de chat e servidores para os novos arquivos, reexportando-os temporariamente por `shared/providers.dart` para preservar consumidores.
- [ ] Executar `dart format lib test && flutter analyze && flutter test`.

### Task 5: Verificação de limites

**Files:**
- Modify: testes afetados nas tarefas anteriores.

- [ ] Executar `rg -n "MethodChannel" lib/features/*/presentation` e confirmar que não há resultado.
- [ ] Executar `rg -n "dynamic row|database\\.|secrets\\." lib/features/*/presentation` e confirmar que não há acesso de infraestrutura em apresentação.
- [ ] Executar `flutter analyze && flutter test && flutter build apk --debug`.
- [ ] Se o APK falhar por ambiente, registrar exatamente a ausência externa; não atribuir a falha ao código.
