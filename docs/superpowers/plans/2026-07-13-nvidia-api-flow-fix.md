# NVIDIA API Flow Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fazer o fluxo NVIDIA atual cadastrar e restaurar perfis compatíveis, listar modelos em `/v1/models` e conversar por streaming em `/v1/chat/completions`, com erros identificados como NVIDIA.

**Architecture:** `/v1` terá uma única fonte no `ServerProfile.basePath`, enquanto `NvidiaEndpoints` permanecerá relativo. `ApiClient` continuará compartilhando o transporte HTTP, mas `_guardHttp` passará a receber o provedor para criar a exceção e a mensagem corretas. A UI continuará com o mesmo fluxo e apenas corrigirá a URL exibida e as orientações de erro.

**Tech Stack:** Flutter, Dart, Riverpod, package:http, SharedPreferences, flutter_test.

## Global Constraints

- Não adicionar capacidades novas de reasoning, visão, tools, embeddings ou parâmetros específicos por modelo.
- Não adicionar configuração por `.env`; a API key continua sendo informada na interface.
- Preservar o fluxo Ollama e seus caminhos atuais.
- Usar `snake_case.dart`, indentação de dois espaços e código compatível com `flutter_lints`.
- Cada mudança de comportamento deve seguir RED-GREEN e ter cobertura automatizada.
- Não registrar API keys reais em código, fixtures, logs ou commits.

---

### Task 1: Normalizar perfis NVIDIA para `/v1`

**Files:**
- Modify: `test/features/servers/data/server_profile_test.dart`
- Modify: `lib/features/servers/domain/entities/server_profile.dart:38-57,61-91,138-160,221-229`

**Interfaces:**
- Consumes: `ApiProvider`, `ServerProfile.create`, `ServerProfile.fromJson`, `ServerProfile.copyWith`, `ServerProfile.resolve`.
- Produces: todo perfil com `provider == ApiProvider.nvidia` terá `basePath == '/v1'`; perfis Ollama manterão a normalização genérica existente.

- [ ] **Step 1: Escrever testes vermelhos para criação, restauração e resolução NVIDIA**

Adicionar ao grupo `ServerProfile`:

```dart
test('normalizes NVIDIA profiles to the v1 base path', () {
  final profile = ServerProfile.create(
    id: 'nvidia-1',
    name: 'NVIDIA',
    input: 'https://integrate.api.nvidia.com:443',
    provider: ApiProvider.nvidia,
    apiKey: 'nvapi-test',
  );

  expect(profile.basePath, '/v1');
  expect(
    profile.resolve('models').toString(),
    'https://integrate.api.nvidia.com/v1/models',
  );
  expect(profile.headers['Authorization'], 'Bearer nvapi-test');
});

test('repairs a persisted NVIDIA profile without v1', () {
  final profile = ServerProfile.fromJson({
    'id': 'nvidia-1',
    'name': 'NVIDIA',
    'protocol': 'https',
    'host': 'integrate.api.nvidia.com',
    'port': 443,
    'basePath': null,
    'headers': <String, String>{},
    'createdAt': '2026-07-13T00:00:00.000Z',
    'updatedAt': '2026-07-13T00:00:00.000Z',
    'lastConnectedAt': null,
    'provider': 'nvidia',
    'apiKey': 'nvapi-restored',
    'defaultModel': null,
  });

  expect(profile.basePath, '/v1');
  expect(profile.headers['Authorization'], 'Bearer nvapi-restored');
  expect(
    profile.resolve('chat/completions').toString(),
    'https://integrate.api.nvidia.com/v1/chat/completions',
  );
});

test('keeps an Ollama persisted base path unchanged', () {
  final profile = ServerProfile.fromJson({
    'id': 'ollama-1',
    'name': 'Ollama',
    'protocol': 'https',
    'host': 'ollama.example.com',
    'port': 443,
    'basePath': '/ollama',
    'headers': <String, String>{},
    'createdAt': '2026-07-13T00:00:00.000Z',
    'updatedAt': '2026-07-13T00:00:00.000Z',
    'lastConnectedAt': null,
    'provider': 'ollama',
    'apiKey': null,
    'defaultModel': null,
  });

  expect(profile.basePath, '/ollama');
  expect(profile.resolve('api/tags').path, '/ollama/api/tags');
});
```

- [ ] **Step 2: Executar o teste e confirmar RED**

Run:

```powershell
flutter test test/features/servers/data/server_profile_test.dart
```

Expected: FAIL porque o perfil NVIDIA criado/restaurado possui `basePath == null` e resolve URLs sem `/v1`.

- [ ] **Step 3: Implementar a normalização mínima por provedor**

Adicionar ao final de `ServerProfile`, perto de `_normalizeBasePath`:

```dart
static String? _normalizeProviderBasePath(
  ApiProvider provider,
  String? path,
) {
  if (provider == ApiProvider.nvidia) {
    return '/v1';
  }
  return _normalizeBasePath(path);
}
```

Em `ServerProfile.create`, substituir o cálculo de `basePath` por:

```dart
basePath: _normalizeProviderBasePath(
  provider,
  basePath ?? parsed.basePath,
),
```

Em `ServerProfile.fromJson`, substituir a atribuição por:

```dart
basePath: _normalizeProviderBasePath(
  provider,
  json['basePath'] as String?,
),
```

Em `copyWith`, normalizar usando o provedor final:

```dart
basePath: _normalizeProviderBasePath(
  newProvider,
  basePath ?? this.basePath,
),
```

- [ ] **Step 4: Executar o teste e confirmar GREEN**

Run:

```powershell
dart format lib/features/servers/domain/entities/server_profile.dart test/features/servers/data/server_profile_test.dart
flutter test test/features/servers/data/server_profile_test.dart
```

Expected: PASS para todos os testes de `ServerProfile`.

- [ ] **Step 5: Commitar a normalização de perfis**

```powershell
git add lib/features/servers/domain/entities/server_profile.dart test/features/servers/data/server_profile_test.dart
git commit -m "fix: normalize NVIDIA API base path"
```

---

### Task 2: Cobrir listagem de modelos e chat NVIDIA

**Files:**
- Create: `test/core/network/nvidia_api_client_test.dart`
- Verify: `lib/core/network/api_client.dart:53-78,132-161`
- Verify: `lib/core/network/nvidia_endpoints.dart:1-7`
- Verify: `lib/core/network/ollama_stream_parser.dart:47-145`

**Interfaces:**
- Consumes: `ApiClient.listNvidiaModels`, `ApiClient.streamChat`, `NvidiaModel`, `ServerProfile`, `NvidiaEndpoints` e `StreamParser`.
- Produces: testes de contrato que fixam método, URL, Bearer, corpo OpenAI e resposta SSE do fluxo NVIDIA atual.

- [ ] **Step 1: Escrever o teste de contrato da listagem de modelos**

Criar `test/core/network/nvidia_api_client_test.dart` com imports e helper:

```dart
import 'dart:convert';

import 'package:byte_papo/core/network/api_client.dart';
import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';
import 'package:byte_papo/features/models/domain/entities/nvidia_model.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('lists NVIDIA models from v1 with bearer authentication', () async {
    late http.Request capturedRequest;
    final client = ApiClient(
      httpClient: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 'meta/llama-3.3-70b-instruct',
                'object': 'model',
                'created': 1,
                'owned_by': 'meta',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final models = await client.listNvidiaModels(_nvidiaServer());

    expect(capturedRequest.method, 'GET');
    expect(
      capturedRequest.url.toString(),
      'https://integrate.api.nvidia.com/v1/models',
    );
    expect(capturedRequest.headers['Authorization'], 'Bearer nvapi-test');
    expect(
      models,
      const [
        NvidiaModel(
          id: 'meta/llama-3.3-70b-instruct',
          object: 'model',
          created: 1,
          ownedBy: 'meta',
        ),
      ],
    );
  });

  test('streams NVIDIA chat from v1 using the selected model', () async {
    late http.Request capturedRequest;
    final client = ApiClient(
      httpClient: MockClient.streaming((request, bodyStream) async {
        capturedRequest = request as http.Request;
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode(
              'data: {"choices":[{"delta":{"content":"Olá"},"finish_reason":null}]}\n\n',
            ),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      }),
    );

    final tokens = await client
        .streamChatTokens(
          server: _nvidiaServer(),
          model: 'meta/llama-3.3-70b-instruct',
          messages: [_userMessage()],
        )
        .toList();
    final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;

    expect(capturedRequest.method, 'POST');
    expect(
      capturedRequest.url.toString(),
      'https://integrate.api.nvidia.com/v1/chat/completions',
    );
    expect(capturedRequest.headers['Authorization'], 'Bearer nvapi-test');
    expect(capturedRequest.headers['Accept'], 'text/event-stream');
    expect(body['model'], 'meta/llama-3.3-70b-instruct');
    expect(body['stream'], isTrue);
    expect(tokens, ['Olá']);
  });
}

ServerProfile _nvidiaServer() {
  return ServerProfile.create(
    id: 'nvidia-1',
    name: 'NVIDIA',
    input: 'https://integrate.api.nvidia.com:443',
    provider: ApiProvider.nvidia,
    apiKey: 'nvapi-test',
  );
}

ChatMessage _userMessage() {
  final now = DateTime.utc(2026, 7, 13);
  return ChatMessage(
    id: 'message-1',
    conversationId: 'conversation-1',
    role: ChatRole.user,
    content: 'Olá',
    createdAt: now,
    updatedAt: now,
  );
}
```

- [ ] **Step 2: Executar os testes de contrato**

Run:

```powershell
flutter test test/core/network/nvidia_api_client_test.dart
```

Expected: PASS após a Task 1. Se URL, Bearer, formato `data` ou SSE divergirem, corrigir apenas a divergência observada em `ApiClient`, `NvidiaEndpoints` ou `StreamParser` e executar novamente.

- [ ] **Step 3: Confirmar que os endpoints permanecem relativos**

Verificar que `lib/core/network/nvidia_endpoints.dart` contém exatamente:

```dart
class NvidiaEndpoints {
  const NvidiaEndpoints._();

  static const models = 'models';
  static const chat = 'chat/completions';
  static const embeddings = 'embeddings';
}
```

Não adicionar `/v1` aqui, pois ele já pertence ao `ServerProfile.basePath`.

- [ ] **Step 4: Formatar e executar testes NVIDIA e de streaming**

Run:

```powershell
dart format test/core/network/nvidia_api_client_test.dart
flutter test test/core/network/nvidia_api_client_test.dart test/core/network/ollama_stream_parser_test.dart
```

Expected: PASS em listagem, chat NVIDIA e parser SSE/NDJSON.

- [ ] **Step 5: Commitar os testes de contrato**

```powershell
git add test/core/network/nvidia_api_client_test.dart lib/core/network/api_client.dart lib/core/network/nvidia_endpoints.dart lib/core/network/ollama_stream_parser.dart
git commit -m "test: cover NVIDIA models and chat flow"
```

---

### Task 3: Classificar falhas de transporte pelo provedor

**Files:**
- Modify: `test/core/network/nvidia_api_client_test.dart`
- Modify: `lib/core/network/api_client.dart:25-29,53-58,123,155,180-192`

**Interfaces:**
- Consumes: `_guardHttp<T>(Future<T> Function(), {required ApiProvider provider})` dentro de `ApiClient`.
- Produces: `NvidiaApiException` com mensagem NVIDIA para falhas de timeout, socket, TLS e `http.ClientException`; Ollama mantém seus tipos e mensagens atuais.

- [ ] **Step 1: Escrever um teste vermelho para falha de transporte NVIDIA**

Adicionar imports:

```dart
import 'package:byte_papo/core/errors/app_exception.dart';
```

Adicionar dentro de `main()`:

```dart
test('wraps NVIDIA transport failures as NvidiaApiException', () async {
  final client = ApiClient(
    httpClient: MockClient((request) async {
      throw http.ClientException('connection failed', request.url);
    }),
  );

  await expectLater(
    client.listNvidiaModels(_nvidiaServer()),
    throwsA(
      isA<NvidiaApiException>().having(
        (error) => error.message,
        'message',
        contains('NVIDIA'),
      ),
    ),
  );
});
```

- [ ] **Step 2: Executar o teste e confirmar RED**

Run:

```powershell
flutter test test/core/network/nvidia_api_client_test.dart --plain-name "wraps NVIDIA transport failures as NvidiaApiException"
```

Expected: FAIL porque `_guardHttp` lança `OllamaApiException` para qualquer provedor.

- [ ] **Step 3: Tornar `_guardHttp` consciente do provedor**

Alterar as quatro chamadas para informar o provedor da operação:

```dart
final response = await _guardHttp(
  () => requestFuture,
  provider: server.provider,
);
```

Aplicar esse formato em `listOllamaModels`, `listNvidiaModels`, `_streamOllamaChat` e `_streamNvidiaChat`, preservando `.timeout(_timeout)` apenas onde ele já existe.

Substituir `_guardHttp` por:

```dart
Future<T> _guardHttp<T>(
  Future<T> Function() request, {
  required ApiProvider provider,
}) async {
  try {
    return await request();
  } on TimeoutException catch (error) {
    throw _transportException(
      provider: provider,
      ollamaFailure: const TimeoutFailure(),
      nvidiaFailure: const NvidiaApiFailure(
        'Tempo esgotado ao conectar à API NVIDIA.',
      ),
      cause: error,
    );
  } on SocketException catch (error) {
    throw _transportException(
      provider: provider,
      ollamaFailure: const NetworkFailure(),
      nvidiaFailure: const NvidiaApiFailure(
        'Não foi possível conectar à API NVIDIA.',
      ),
      cause: error,
    );
  } on HandshakeException catch (error) {
    throw _transportException(
      provider: provider,
      ollamaFailure: const CleartextBlockedFailure(),
      nvidiaFailure: const NvidiaApiFailure(
        'Falha na conexão segura com a API NVIDIA.',
      ),
      cause: error,
    );
  } on http.ClientException catch (error) {
    throw _transportException(
      provider: provider,
      ollamaFailure: const NetworkFailure(),
      nvidiaFailure: const NvidiaApiFailure(
        'Não foi possível conectar à API NVIDIA.',
      ),
      cause: error,
    );
  }
}

AppException _transportException({
  required ApiProvider provider,
  required AppFailure ollamaFailure,
  required AppFailure nvidiaFailure,
  required Object cause,
}) {
  if (provider == ApiProvider.nvidia) {
    return NvidiaApiException(nvidiaFailure, cause);
  }
  return OllamaApiException(ollamaFailure, cause);
}
```

- [ ] **Step 4: Executar testes NVIDIA e Ollama e confirmar GREEN**

Run:

```powershell
dart format lib/core/network/api_client.dart test/core/network/nvidia_api_client_test.dart
flutter test test/core/network/nvidia_api_client_test.dart test/core/network/ollama_api_client_test.dart
```

Expected: PASS; o teste novo recebe `NvidiaApiException` e os testes Ollama continuam verdes.

- [ ] **Step 5: Commitar o tratamento de transporte**

```powershell
git add lib/core/network/api_client.dart test/core/network/nvidia_api_client_test.dart
git commit -m "fix: report NVIDIA transport failures correctly"
```

---

### Task 4: Corrigir a configuração e o feedback da tela NVIDIA

**Files:**
- Modify: `test/widget_test.dart`
- Modify: `lib/features/servers/presentation/server_screen.dart:155-176,199-225,337-354`

**Interfaces:**
- Consumes: `apiClientProvider`, `ServerProfile.create`, `_testConnection` e `_ServerForm`.
- Produces: a tela mostra a base automática com `/v1`, cria o perfil com `/v1` explícito e não sugere rede local em erros NVIDIA.

- [ ] **Step 1: Escrever um teste de widget vermelho para feedback NVIDIA**

Adicionar imports em `test/widget_test.dart`:

```dart
import 'package:byte_papo/core/errors/app_exception.dart';
import 'package:byte_papo/core/network/api_client.dart';
import 'package:byte_papo/features/models/domain/entities/nvidia_model.dart';
```

Adicionar dentro de `main()`:

```dart
testWidgets('shows NVIDIA errors without local network guidance', (
  tester,
) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        apiClientProvider.overrideWithValue(_FailingNvidiaApiClient()),
      ],
      child: const MaterialApp(home: ServerScreen()),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('NVIDIA API (build.nvidia.com)'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.widgetWithText(TextFormField, 'NVIDIA API Key'),
    'nvapi-test',
  );
  await tester.ensureVisible(find.text('Testar NVIDIA'));
  await tester.tap(find.text('Testar NVIDIA'));
  await tester.pumpAndSettle();

  expect(find.text('Falha NVIDIA de teste.'), findsOneWidget);
  expect(find.textContaining('Wi-Fi'), findsNothing);
  expect(find.textContaining('firewall'), findsNothing);
});
```

Adicionar após os helpers do arquivo:

```dart
class _FailingNvidiaApiClient extends ApiClient {
  @override
  Future<List<NvidiaModel>> listNvidiaModels(ServerProfile server) {
    throw const NvidiaApiException(
      NvidiaApiFailure('Falha NVIDIA de teste.'),
    );
  }
}
```

- [ ] **Step 2: Executar o teste e confirmar RED**

Run:

```powershell
flutter test test/widget_test.dart --plain-name "shows NVIDIA errors without local network guidance"
```

Expected: FAIL porque a mensagem atual concatena `Verifique IP, porta, Wi-Fi e firewall.`.

- [ ] **Step 3: Corrigir base path, texto informativo e feedback**

Em `_buildProfile`, usar:

```dart
final basePath = isNvidia ? '/v1' : _basePathController.text.trim();
```

Em `_testConnection`, substituir o `catch` por:

```dart
} on AppException catch (error) {
  final guidance = _provider == ApiProvider.nvidia
      ? ''
      : '\nVerifique IP, porta, Wi-Fi e firewall.';
  setState(() => _feedback = '${error.message}$guidance');
} finally {
```

Na `_InfoStrip` NVIDIA, usar:

```dart
message:
    'A URL base será configurada automaticamente '
    '(https://integrate.api.nvidia.com/v1).',
```

- [ ] **Step 4: Executar o teste e confirmar GREEN**

Run:

```powershell
dart format lib/features/servers/presentation/server_screen.dart test/widget_test.dart
flutter test test/widget_test.dart --plain-name "shows NVIDIA errors without local network guidance"
flutter test test/widget_test.dart
```

Expected: PASS no teste NVIDIA e em todos os testes de widget existentes.

- [ ] **Step 5: Commitar a correção da tela**

```powershell
git add lib/features/servers/presentation/server_screen.dart test/widget_test.dart
git commit -m "fix: clarify NVIDIA connection feedback"
```

---

### Task 5: Verificação integrada do fluxo

**Files:**
- Verify: `lib/`
- Verify: `test/`
- Verify: `README.md:76-86`
- Verify: `.env.example:4-8`

**Interfaces:**
- Consumes: todos os comportamentos produzidos nas Tasks 1–4.
- Produces: evidência de formatação, análise, testes e build Android sem incluir segredo real.

- [ ] **Step 1: Confirmar documentação coerente sem adicionar dotenv**

Verificar que `README.md` mantém a base URL:

```markdown
https://integrate.api.nvidia.com/v1
```

E que o fluxo documentado orienta inserir a API key no app. Não adicionar `flutter_dotenv` nem leitura automática de `.env`.

- [ ] **Step 2: Formatar todo o código relevante**

Run:

```powershell
dart format lib test
```

Expected: comando termina com exit code `0`.

- [ ] **Step 3: Executar análise estática**

Run:

```powershell
flutter analyze
```

Expected: `No issues found!`.

- [ ] **Step 4: Executar a suíte completa**

Run:

```powershell
flutter test
```

Expected: todos os testes passam, incluindo `nvidia_api_client_test.dart` e o teste de widget NVIDIA.

- [ ] **Step 5: Gerar APK de validação**

Run:

```powershell
flutter build apk --debug
```

Expected: build termina com exit code `0` e gera `build/app/outputs/flutter-apk/app-debug.apk`.

- [ ] **Step 6: Confirmar o endpoint público sem usar API key**

Run:

```powershell
curl.exe -sS -o NUL -w "%{http_code}" https://integrate.api.nvidia.com/v1/models
```

Expected: HTTP `200`. Não executar chat real sem uma chave fornecida de forma segura pelo usuário.

- [ ] **Step 7: Revisar alterações e registrar a verificação final**

Run:

```powershell
git status --short
git log -5 --oneline
```

Expected: somente alterações intencionais; commits separados para normalização, contrato NVIDIA, erros de transporte e feedback da UI.
