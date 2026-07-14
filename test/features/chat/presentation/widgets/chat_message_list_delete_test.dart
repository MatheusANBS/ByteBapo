import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';
import 'package:byte_papo/features/chat/presentation/widgets/chat_message_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses the character snapshot saved on each assistant message', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageList(
            controller: controller,
            character: null,
            messages: [
              ChatMessage(
                id: 'assistant-1',
                conversationId: 'conversation-1',
                role: ChatRole.assistant,
                content: 'Resposta da Ada',
                characterNameSnapshot: 'Ada',
                createdAt: DateTime.utc(2026),
                updatedAt: DateTime.utc(2026),
              ),
              ChatMessage(
                id: 'assistant-2',
                conversationId: 'conversation-1',
                role: ChatRole.assistant,
                content: 'Resposta da Grace',
                characterNameSnapshot: 'Grace',
                createdAt: DateTime.utc(2026, 1, 1, 0, 1),
                updatedAt: DateTime.utc(2026, 1, 1, 0, 1),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Grace'), findsOneWidget);
  });

  testWidgets('exposes a delete action for each message', (tester) async {
    String? deletedMessageId;
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageList(
            controller: controller,
            character: null,
            messages: [
              ChatMessage(
                id: 'message-1',
                conversationId: 'conversation-1',
                role: ChatRole.user,
                content: 'Oi',
                createdAt: DateTime.utc(2026),
                updatedAt: DateTime.utc(2026),
              ),
            ],
            onDeleteMessage: (message) => deletedMessageId = message.id,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Excluir mensagem'));
    await tester.pump();

    expect(deletedMessageId, 'message-1');
  });
}
