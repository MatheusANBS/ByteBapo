import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byte_papo/app/app.dart';
import 'package:byte_papo/features/chat/data/repositories/conversation_repository_impl.dart';
import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';
import 'package:byte_papo/features/chat/domain/entities/conversation.dart';
import 'package:byte_papo/features/chat/presentation/chat_screen.dart';
import 'package:byte_papo/features/models/data/repositories/model_selection_repository_impl.dart';
import 'package:byte_papo/features/servers/data/repositories/server_repository_impl.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:byte_papo/shared/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('renders server setup screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const OllamaMobileApp(),
      ),
    );

    expect(find.text('Servidor Ollama'), findsOneWidget);
    expect(find.text('Host ou IP'), findsOneWidget);
  });

  testWidgets('renders saved server list without framework exceptions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = ServerRepositoryImpl(preferences: preferences);
    await repository.save(
      ServerProfile.create(
        id: 'server-1',
        name: 'Notebook',
        input: 'http://192.168.0.10:11434',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const OllamaMobileApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notebook'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders thinking message without framework exceptions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final serverRepository = ServerRepositoryImpl(preferences: preferences);
    final modelRepository = ModelSelectionRepositoryImpl(
      preferences: preferences,
    );
    final conversationRepository = ConversationRepositoryImpl(
      preferences: preferences,
    );
    final now = DateTime.utc(2026);

    await serverRepository.save(
      ServerProfile.create(
        id: 'server-1',
        name: 'Notebook',
        input: 'http://192.168.0.10:11434',
      ),
    );
    await serverRepository.setActiveServerId('server-1');
    await modelRepository.setSelectedModel(
      'qwen3:latest',
      serverProfileId: 'server-1',
    );
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
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
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final serverRepository = ServerRepositoryImpl(preferences: preferences);
    final modelRepository = ModelSelectionRepositoryImpl(
      preferences: preferences,
    );
    final conversationRepository = ConversationRepositoryImpl(
      preferences: preferences,
    );
    final now = DateTime.utc(2026);

    await serverRepository.save(
      ServerProfile.create(
        id: 'server-1',
        name: 'Notebook',
        input: 'http://192.168.0.10:11434',
      ),
    );
    await serverRepository.setActiveServerId('server-1');
    await modelRepository.setSelectedModel(
      'qwen3:latest',
      serverProfileId: 'server-1',
    );
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
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
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final serverRepository = ServerRepositoryImpl(preferences: preferences);
    final modelRepository = ModelSelectionRepositoryImpl(
      preferences: preferences,
    );
    final conversationRepository = ConversationRepositoryImpl(
      preferences: preferences,
    );
    final now = DateTime.utc(2026);

    await serverRepository.save(
      ServerProfile.create(
        id: 'server-1',
        name: 'Notebook',
        input: 'http://192.168.0.10:11434',
      ),
    );
    await serverRepository.setActiveServerId('server-1');
    await modelRepository.setSelectedModel(
      'qwen3:latest',
      serverProfileId: 'server-1',
    );
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
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
}
