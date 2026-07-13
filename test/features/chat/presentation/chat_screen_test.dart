import 'package:byte_papo/features/chat/domain/entities/chat_character.dart';
import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';
import 'package:byte_papo/features/chat/domain/entities/conversation.dart';
import 'package:byte_papo/features/chat/domain/entities/generation_options.dart';
import 'package:byte_papo/features/chat/domain/repositories/conversation_repository.dart';
import 'package:byte_papo/features/chat/presentation/chat_controller.dart';
import 'package:byte_papo/features/chat/presentation/widgets/chat_composer.dart';
import 'package:byte_papo/features/providers/domain/chat_completion_gateway.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:flutter/material.dart';
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
}
