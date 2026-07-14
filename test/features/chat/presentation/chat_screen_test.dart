import 'package:byte_papo/features/chat/domain/entities/chat_character.dart';
import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';
import 'package:byte_papo/features/chat/domain/entities/conversation.dart';
import 'package:byte_papo/features/chat/domain/entities/generation_options.dart';
import 'package:byte_papo/features/chat/domain/repositories/conversation_repository.dart';
import 'package:byte_papo/features/chat/presentation/chat_controller.dart';
import 'package:byte_papo/features/chat/presentation/chat_screen.dart';
import 'package:byte_papo/features/chat/presentation/widgets/chat_composer.dart';
import 'package:byte_papo/features/providers/domain/chat_completion_gateway.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:byte_papo/shared/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('composer envia mensagem e exibe personagens no seletor', (
    tester,
  ) async {
    final messageController = TextEditingController(text: 'Ola');
    addTearDown(messageController.dispose);
    final controller = ChatController(
      chatGateway: _Gateway(),
      conversationRepository: _ConversationRepository(),
      server: ServerProfile.create(
        id: 'server',
        name: 'Local',
        input: 'http://localhost:11434',
      ),
      model: 'modelo',
    );
    addTearDown(controller.dispose);
    var submitted = false;
    final character = ChatCharacter.create(
      id: 'aria',
      name: 'Aria',
      instructions: 'Seja direta.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatComposer(
            controller: controller,
            messageController: messageController,
            characters: [character],
            activeCharacter: null,
            onCharacterChanged: (_) {},
            thinkingMode: ThinkingMode.modelDefault,
            onThinkingChanged: (_) {},
            onSubmitted: () async => submitted = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Sem personagem'));
    await tester.pumpAndSettle();
    expect(find.text('Aria'), findsOneWidget);

    await tester.tap(find.text('Aria'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Enviar'));
    await tester.pump();
    expect(submitted, isTrue);
  });

  testWidgets('chat top bar exposes new chat and settings buttons', (
    tester,
  ) async {
    final controller = ChatController(
      chatGateway: _Gateway(),
      conversationRepository: _ConversationRepository(),
      server: ServerProfile.create(
        id: 'server',
        name: 'Local',
        input: 'http://localhost:11434',
      ),
      model: 'modelo',
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeServerProvider.overrideWithValue(
            AsyncValue.data(
              ServerProfile.create(
                id: 'server',
                name: 'Local',
                input: 'http://localhost:11434',
              ),
            ),
          ),
          selectedModelProvider.overrideWithValue(
            const AsyncValue.data('modelo'),
          ),
          charactersProvider.overrideWithValue(const AsyncValue.data([])),
          activeCharacterProvider.overrideWithValue(
            const AsyncValue.data(null),
          ),
          globalInstructionsProvider.overrideWithValue(
            const AsyncValue.data(null),
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

    expect(find.byTooltip('Novo chat'), findsOneWidget);
    expect(find.byTooltip('Configuracoes'), findsOneWidget);
    expect(find.byTooltip('Mais'), findsNothing);
  });

  testWidgets('chat shows a jump to bottom action when it has messages', (
    tester,
  ) async {
    final controller =
        ChatController(
            chatGateway: _Gateway(),
            conversationRepository: _ConversationRepository(),
            server: ServerProfile.create(
              id: 'server',
              name: 'Local',
              input: 'http://localhost:11434',
            ),
            model: 'modelo',
          )
          ..messages = [
            ChatMessage(
              id: 'message-1',
              conversationId: 'conversation-1',
              role: ChatRole.user,
              content: 'Mensagem antiga',
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          ];
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeServerProvider.overrideWithValue(
            AsyncValue.data(
              ServerProfile.create(
                id: 'server',
                name: 'Local',
                input: 'http://localhost:11434',
              ),
            ),
          ),
          selectedModelProvider.overrideWithValue(
            const AsyncValue.data('modelo'),
          ),
          charactersProvider.overrideWithValue(const AsyncValue.data([])),
          activeCharacterProvider.overrideWithValue(
            const AsyncValue.data(null),
          ),
          globalInstructionsProvider.overrideWithValue(
            const AsyncValue.data(null),
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

    expect(find.byTooltip('Ir para o fim'), findsOneWidget);
    await tester.tap(find.byTooltip('Ir para o fim'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('chat error banner fits on narrow mobile screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller =
        ChatController(
            chatGateway: _Gateway(),
            conversationRepository: _ConversationRepository(),
            server: ServerProfile.create(
              id: 'server',
              name: 'Local',
              input: 'http://localhost:11434',
            ),
            model: 'modelo',
          )
          ..errorMessage =
              'Nao consegui concluir a resposta porque o servidor demorou demais. '
              'A mensagem do usuario foi preservada.';
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeServerProvider.overrideWithValue(
            AsyncValue.data(
              ServerProfile.create(
                id: 'server',
                name: 'Local',
                input: 'http://localhost:11434',
              ),
            ),
          ),
          selectedModelProvider.overrideWithValue(
            const AsyncValue.data('modelo'),
          ),
          charactersProvider.overrideWithValue(const AsyncValue.data([])),
          activeCharacterProvider.overrideWithValue(
            const AsyncValue.data(null),
          ),
          globalInstructionsProvider.overrideWithValue(
            const AsyncValue.data(null),
          ),
          chatControllerProvider(null).overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.2)),
            child: child!,
          ),
          home: const ChatScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Nao consegui concluir'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _Gateway implements ChatCompletionGateway {
  @override
  Stream<ChatChunk> streamChat({
    required ServerProfile server,
    required String model,
    required List<ChatMessage> messages,
    GenerationOptions options = const GenerationOptions(),
  }) => const Stream.empty();
}

class _ConversationRepository implements ConversationRepository {
  @override
  Future<List<Conversation>> listConversations() async => [];

  @override
  Future<List<Conversation>> listConversationsPage({
    String? query,
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<ChatMessage>> listMessages(String conversationId) async => [];

  @override
  Future<void> removeConversation(String id) async {}

  @override
  Future<void> removeMessages(String conversationId) async {}

  @override
  Future<void> saveConversation(Conversation conversation) async {}

  @override
  Future<void> saveMessage(ChatMessage message) async {}

  @override
  Future<void> removeMessage(String messageId) async {}
}
