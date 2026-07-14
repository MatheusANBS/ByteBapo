import 'package:byte_papo/core/database/app_database.dart' as db;
import 'package:byte_papo/features/chat/data/mappers/conversation_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips a message row with tool calls', () {
    final row = db.ChatMessage(
      id: 'message-1',
      conversationId: 'conversation-1',
      role: 'assistant',
      content: 'Vou consultar o clima.',
      thinking: 'Preciso usar a ferramenta.',
      model: 'qwen3',
      status: 'completed',
      toolCallsJson:
          '[{"id":"call-1","type":"function","function":{"name":"weather","arguments":"{\\"city\\":\\"Sao Paulo\\"}"}}]',
      toolCallId: null,
      characterIdSnapshot: 'ada',
      characterNameSnapshot: 'Ada',
      characterAvatarPathSnapshot: '/tmp/ada.png',
      createdAt: DateTime.utc(2026, 7, 13),
      updatedAt: DateTime.utc(2026, 7, 13, 1),
    );

    final message = ConversationMapper.messageFromRow(row);

    expect(message.id, 'message-1');
    expect(message.characterIdSnapshot, 'ada');
    expect(message.characterNameSnapshot, 'Ada');
    expect(message.characterAvatarPathSnapshot, '/tmp/ada.png');
    expect(message.toolCalls, hasLength(1));
    expect(message.toolCalls!.single.name, 'weather');
    expect(
      ConversationMapper.encodeToolCalls(message.toolCalls),
      row.toolCallsJson,
    );
  });
}
