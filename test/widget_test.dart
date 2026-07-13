import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byte_papo/core/errors/app_exception.dart';
import 'package:byte_papo/core/database/app_database.dart'
    hide ChatMessage, Conversation, ServerProfile;
import 'package:byte_papo/core/secure_storage/server_secret_store.dart';
import 'package:byte_papo/features/chat/data/repositories/drift_conversation_repository.dart';
import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';
import 'package:byte_papo/features/chat/domain/entities/conversation.dart';
import 'package:byte_papo/features/chat/presentation/chat_controller.dart';
import 'package:byte_papo/features/chat/presentation/chat_screen.dart';
import 'package:byte_papo/features/chat/domain/entities/generation_options.dart';
import 'package:byte_papo/features/models/domain/model_catalog_service.dart';
import 'package:byte_papo/features/models/presentation/models_screen.dart';
import 'package:byte_papo/features/providers/domain/chat_completion_gateway.dart';
import 'package:byte_papo/features/providers/domain/entities/available_model.dart';
import 'package:byte_papo/features/providers/domain/model_catalog_gateway.dart';
import 'package:byte_papo/features/providers/domain/provider_gateway_resolver.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:byte_papo/features/servers/presentation/server_screen.dart';
import 'package:byte_papo/shared/providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('renders the approved servers catalog layout', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [..._databaseOverrides(database)],
        child: const MaterialApp(home: ServerScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Meus servidores'), findsOneWidget);
    expect(find.text('Pesquisar servidores'), findsOneWidget);
    expect(find.text('Adicionar servidor'), findsOneWidget);
  });

  testWidgets('renders saved server list without framework exceptions', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final server = ServerProfile.create(
      id: 'server-1',
      name: 'Notebook',
      input: 'http://192.168.0.10:11434',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._databaseOverrides(database),
          serverProfilesProvider.overrideWithValue(AsyncValue.data([server])),
        ],
        child: const MaterialApp(home: ServerScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Notebook'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notebook'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the approved model catalog layout', (tester) async {
    final server = ServerProfile.create(
      id: 'server-1',
      name: 'NVIDIA Cloud',
      input: 'https://integrate.api.nvidia.com:443',
      provider: ApiProvider.nvidia,
    );
    final catalog = ModelCatalogResult(
      models: const [
        AvailableModel(
          id: 'meta/llama-3.1-8b-instruct',
          displayName: 'Llama 3 8B Instruct',
          serverId: 'server-1',
          provider: ApiProvider.nvidia,
        ),
      ],
      failures: const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          modelCatalogProvider.overrideWithValue(AsyncValue.data(catalog)),
          activeServerProvider.overrideWithValue(AsyncValue.data(server)),
          selectedModelProvider.overrideWithValue(
            const AsyncValue.data('meta/llama-3.1-8b-instruct'),
          ),
        ],
        child: const MaterialApp(home: ModelsScreen()),
      ),
    );

    expect(find.text('Escolher modelo'), findsOneWidget);
    expect(find.text('Pesquisar modelos'), findsOneWidget);
    expect(find.text('Fornecedor'), findsOneWidget);
    expect(find.text('Llama 3 8B Instruct'), findsOneWidget);
    expect(find.text('Página 1 de 1'), findsOneWidget);
  });

  testWidgets('renders thinking message without framework exceptions', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final conversationRepository = DriftConversationRepository(
      database: database,
    );
    final now = DateTime.utc(2026);

    await _seedServer(database);

    await conversationRepository.saveConversation(
      Conversation(
        id: 'conversation-1',
        title: 'Teste',
        serverProfileId: 'server-1',
        model: 'qwen3:latest',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await conversationRepository.saveMessage(
      ChatMessage(
        id: 'message-1',
        conversationId: 'conversation-1',
        role: ChatRole.assistant,
        content: 'Resposta final',
        thinking: 'Pensamento intermediario',
        createdAt: now,
        updatedAt: now,
      ),
    );
    final controller = await _loadedController(
      database: database,
      conversationId: 'conversation-1',
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._databaseOverrides(database),
          activeServerProvider.overrideWithValue(
            AsyncValue.data(
              ServerProfile.create(
                id: 'server-1',
                name: 'Notebook',
                input: 'http://192.168.0.10:11434',
              ),
            ),
          ),
          selectedModelProvider.overrideWithValue(
            const AsyncValue.data('qwen3:latest'),
          ),
          chatControllerProvider(
            'conversation-1',
          ).overrideWith((ref) => controller),
        ],
        child: const MaterialApp(
          home: ChatScreen(conversationId: 'conversation-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Thinking'), findsOneWidget);
    expect(find.text('Pensamento intermediario'), findsNothing);
    await tester.tap(find.text('Thinking'));
    await tester.pumpAndSettle();
    expect(find.text('Pensamento intermediario'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders persona loading while waiting for first stream chunk', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final conversationRepository = DriftConversationRepository(
      database: database,
    );
    final now = DateTime.utc(2026);

    await _seedServer(database);

    await conversationRepository.saveConversation(
      Conversation(
        id: 'conversation-2',
        title: 'Teste',
        serverProfileId: 'server-1',
        model: 'qwen3:latest',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await conversationRepository.saveMessage(
      ChatMessage(
        id: 'message-2',
        conversationId: 'conversation-2',
        role: ChatRole.assistant,
        content: '',
        status: ChatMessageStatus.streaming,
        createdAt: now,
        updatedAt: now,
      ),
    );
    final controller = await _loadedController(
      database: database,
      conversationId: 'conversation-2',
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._databaseOverrides(database),
          activeServerProvider.overrideWithValue(
            AsyncValue.data(
              ServerProfile.create(
                id: 'server-1',
                name: 'Notebook',
                input: 'http://192.168.0.10:11434',
              ),
            ),
          ),
          selectedModelProvider.overrideWithValue(
            const AsyncValue.data('qwen3:latest'),
          ),
          chatControllerProvider(
            'conversation-2',
          ).overrideWith((ref) => controller),
        ],
        child: const MaterialApp(
          home: ChatScreen(conversationId: 'conversation-2'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Carregando modelo'), findsOneWidget);
    expect(find.text('...'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not show cold start loader after first assistant turn', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final conversationRepository = DriftConversationRepository(
      database: database,
    );
    final now = DateTime.utc(2026);

    await _seedServer(database);

    await conversationRepository.saveConversation(
      Conversation(
        id: 'conversation-3',
        title: 'Teste',
        serverProfileId: 'server-1',
        model: 'qwen3:latest',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await conversationRepository.saveMessage(
      ChatMessage(
        id: 'message-3',
        conversationId: 'conversation-3',
        role: ChatRole.assistant,
        content: 'Primeira resposta',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await conversationRepository.saveMessage(
      ChatMessage(
        id: 'message-4',
        conversationId: 'conversation-3',
        role: ChatRole.assistant,
        content: '',
        status: ChatMessageStatus.streaming,
        createdAt: now.add(const Duration(seconds: 1)),
        updatedAt: now.add(const Duration(seconds: 1)),
      ),
    );
    final controller = await _loadedController(
      database: database,
      conversationId: 'conversation-3',
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._databaseOverrides(database),
          activeServerProvider.overrideWithValue(
            AsyncValue.data(
              ServerProfile.create(
                id: 'server-1',
                name: 'Notebook',
                input: 'http://192.168.0.10:11434',
              ),
            ),
          ),
          selectedModelProvider.overrideWithValue(
            const AsyncValue.data('qwen3:latest'),
          ),
          chatControllerProvider(
            'conversation-3',
          ).overrideWith((ref) => controller),
        ],
        child: const MaterialApp(
          home: ChatScreen(conversationId: 'conversation-3'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Carregando modelo'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows NVIDIA errors without local network guidance', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._databaseOverrides(database),
          providerGatewayResolverProvider.overrideWithValue(
            ProviderGatewayResolver(
              nvidia: ProviderGatewayBundle(
                _FailingNvidiaCatalogGateway(),
                _UnusedChatCompletionGateway(),
              ),
              ollama: ProviderGatewayBundle(
                _FailingNvidiaCatalogGateway(),
                _UnusedChatCompletionGateway(),
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: ServerScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Adicionar servidor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NVIDIA API'));
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

  testWidgets(
    'opens the server editor full screen with compact provider choices',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [..._databaseOverrides(database)],
          child: const MaterialApp(home: ServerScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Adicionar servidor'));
      await tester.pumpAndSettle();

      final editor = find.byKey(const Key('server-editor'));
      expect(editor, findsOneWidget);
      expect(tester.getRect(editor).top, 0);
      expect(find.text('Ollama local'), findsOneWidget);
      expect(find.text('NVIDIA API'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

List<dynamic> _databaseOverrides(AppDatabase database) => [
  appDatabaseProvider.overrideWithValue(database),
  serverSecretStoreProvider.overrideWithValue(_MemorySecretStore()),
];

Future<void> _seedServer(AppDatabase database) {
  final now = DateTime.utc(2026);
  return database
      .into(database.serverProfiles)
      .insert(
        ServerProfilesCompanion.insert(
          id: 'server-1',
          name: 'Notebook',
          provider: 'ollama',
          protocol: 'http',
          host: '192.168.0.10',
          port: 11434,
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<ChatController> _loadedController({
  required AppDatabase database,
  required String conversationId,
}) async {
  final controller = ChatController(
    chatGateway: _UnusedChatCompletionGateway(),
    conversationRepository: DriftConversationRepository(database: database),
    server: ServerProfile.create(
      id: 'server-1',
      name: 'Notebook',
      input: 'http://192.168.0.10:11434',
    ),
    model: 'qwen3:latest',
  );
  await controller.load(conversationId);
  return controller;
}

class _MemorySecretStore implements ServerSecretStore {
  final _values = <String, String>{};

  @override
  Future<void> delete(String alias) async => _values.remove(alias);

  @override
  Future<String?> read(String alias) async => _values[alias];

  @override
  Future<void> write(String alias, String value) async {
    _values[alias] = value;
  }
}

class _FailingNvidiaCatalogGateway implements ModelCatalogGateway {
  @override
  Future<List<AvailableModel>> listModels(ServerProfile server) {
    throw const NvidiaApiException(NvidiaApiFailure('Falha NVIDIA de teste.'));
  }
}

class _UnusedChatCompletionGateway implements ChatCompletionGateway {
  @override
  Stream<ChatChunk> streamChat({
    required ServerProfile server,
    required String model,
    required List<ChatMessage> messages,
    options = const GenerationOptions(),
  }) => throw UnimplementedError();
}
