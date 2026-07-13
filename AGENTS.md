# Repository Guidelines

## Estrutura do projeto e módulos

O BytePapo é um cliente Android em Flutter. O código fica em `lib/`: `app/` contém tema, rotas e inicialização; `core/` reúne rede e erros; `features/` organiza os fluxos por domínio (`chat`, `models`, `servers`, `settings`); e `shared/` abriga providers e widgets reutilizáveis. Testes unitários e de widget espelham essa estrutura em `test/`. Mantenha mudanças Android em `android/` e documentação/imagens em `docs/` e `docs/assets/`. Não edite o SDK local em `flutter/`.

## Comandos de build, teste e desenvolvimento

- `flutter pub get` instala as dependências do `pubspec.yaml`.
- `flutter analyze` aplica os lints configurados em `analysis_options.yaml`.
- `flutter test` executa a suíte unitária e de widgets.
- `flutter run -d <device-id>` inicia o app em um emulador ou dispositivo Android.
- `flutter build apk --debug` gera um APK de validação local.

Execute `flutter pub get`, `flutter analyze` e `flutter test` antes de abrir um PR. Verifique mudanças de rede, streaming ou UI em Android quando possível.

## Estilo e convenções de nomes

Use `dart format lib test` antes de enviar código e mantenha código compatível com `flutter_lints`. A indentação é de dois espaços. Arquivos usam `snake_case.dart`; classes, enums e widgets usam `UpperCamelCase`; métodos, variáveis e parâmetros usam `lowerCamelCase`. Dê nomes descritivos, como `ServerProfile` e `chatControllerProvider`. Mantenha entidades, repositórios, estado/provider e apresentação nas respectivas camadas da feature; não misture chamadas HTTP diretamente em widgets.

## Diretrizes de testes

Crie testes em `test/` com o sufixo `_test.dart`, na mesma hierarquia do código coberto: por exemplo, `test/core/network/ollama_api_client_test.dart`. Teste regras de domínio e parsing de streaming com testes unitários; use testes de widget para interação, navegação e estado Riverpod. Todo comportamento corrigido ou novo deve ter cobertura relevante. Rode testes específicos com `flutter test test/features/servers/data/server_repository_test.dart` durante a iteração e a suíte completa antes do PR.

## Commits e pull requests

O histórico usa mensagens convencionais curtas, como `fix: resolve lint issue` e `test: cover saved server scrolling`. Prefira `feat:`, `fix:`, `test:`, `docs:` ou `refactor:` seguidos de descrição imperativa. PRs devem explicar o motivo e a mudança, vincular a issue quando houver, informar os comandos executados e incluir captura de tela ou vídeo para mudanças visuais.

## Segurança e configuração

Comece por `.env.example`; nunca versione chaves NVIDIA, tokens, IPs privados sensíveis ou artefatos de build. Não exponha servidores Ollama diretamente à internet e revise HTTPS/TLS e `cleartextTraffic` antes de sair de uma rede confiável.
