import 'package:flutter_test/flutter_test.dart';
import 'package:byte_papo/features/chat/domain/chat_context_builder.dart';
import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';

void main() {
  test('buildChatContext prepends system prompt as system message', () {
    final now = DateTime.utc(2026);
    final messages = [
      ChatMessage(
        id: 'user-1',
        conversationId: 'conversation-1',
        role: ChatRole.user,
        content: 'Oi',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final context = buildChatContext(
      messages: messages,
      systemPrompt: 'Responda como um assistente tecnico.',
    );

    expect(context, hasLength(2));
    expect(context.first.role, ChatRole.system);
    expect(context.first.content, 'Responda como um assistente tecnico.');
    expect(context.last.content, 'Oi');
  });

  test('buildChatContext does not add blank instructions', () {
    final context = buildChatContext(messages: const [], systemPrompt: '   ');

    expect(context, isEmpty);
  });

  test(
    'composeSystemPrompt keeps global policies before character instructions',
    () {
      final prompt = composeSystemPrompt(
        globalInstructions: 'Sempre responda em pt-BR.',
        characterInstructions: 'Voce e Ada, uma engenheira direta.',
      );

      expect(
        prompt,
        '[Politicas globais]\n'
        'Sempre responda em pt-BR.\n\n'
        '[Personagem]\n'
        'Voce e Ada, uma engenheira direta.',
      );
    },
  );

  test('composeSystemPrompt ignores blank parts', () {
    expect(
      composeSystemPrompt(
        globalInstructions: 'Use Markdown.',
        characterInstructions: '   ',
      ),
      'Use Markdown.',
    );
    expect(
      composeSystemPrompt(
        globalInstructions: '',
        characterInstructions: 'Seja Socrates.',
      ),
      'Seja Socrates.',
    );
  });
}
