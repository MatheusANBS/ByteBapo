import 'package:flutter_test/flutter_test.dart';
import 'package:byte_papo/features/chat/domain/entities/conversation.dart';

void main() {
  test('Conversation persists character id and keeps old json compatible', () {
    final now = DateTime.utc(2026);
    final conversation = Conversation(
      id: 'conversation-1',
      title: 'Oi',
      serverProfileId: 'server-1',
      model: 'qwen3',
      characterId: 'char-1',
      systemPrompt: 'Responda como Ada.',
      createdAt: now,
      updatedAt: now,
    );

    final restored = Conversation.fromJson(conversation.toJson());
    final oldRestored = Conversation.fromJson({
      'id': 'old-1',
      'title': 'Antiga',
      'serverProfileId': 'server-1',
      'model': 'qwen3',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    expect(restored.characterId, 'char-1');
    expect(restored.systemPrompt, 'Responda como Ada.');
    expect(oldRestored.characterId, isNull);
  });
}
