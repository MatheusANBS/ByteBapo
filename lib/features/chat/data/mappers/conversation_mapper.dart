import 'dart:convert';

import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/chat_message.dart' as domain;
import '../../domain/entities/conversation.dart' as domain;

abstract final class ConversationMapper {
  static domain.Conversation conversationFromRow(db.Conversation row) {
    return domain.Conversation(
      id: row.id,
      title: row.title,
      serverProfileId: row.serverProfileId,
      serverNameSnapshot: row.serverNameSnapshot,
      providerSnapshot: row.providerSnapshot,
      characterId: row.characterId,
      characterNameSnapshot: row.characterNameSnapshot,
      model: row.model,
      systemPrompt: row.systemPrompt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      archivedAt: row.archivedAt,
    );
  }

  static domain.ChatMessage messageFromRow(db.ChatMessage row) {
    return domain.ChatMessage(
      id: row.id,
      conversationId: row.conversationId,
      role: domain.ChatRole.fromName(row.role),
      content: row.content,
      thinking: row.thinking,
      model: row.model,
      status: domain.ChatMessageStatus.fromName(row.status),
      toolCalls: decodeToolCalls(row.toolCallsJson),
      toolCallId: row.toolCallId,
      characterIdSnapshot: row.characterIdSnapshot,
      characterNameSnapshot: row.characterNameSnapshot,
      characterAvatarPathSnapshot: row.characterAvatarPathSnapshot,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static String? encodeToolCalls(List<domain.ToolCall>? toolCalls) {
    if (toolCalls == null) return null;
    return jsonEncode(toolCalls.map((call) => call.toJson()).toList());
  }

  static List<domain.ToolCall>? decodeToolCalls(String? encoded) {
    if (encoded == null) return null;
    final decoded = jsonDecode(encoded);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(domain.ToolCall.fromJson)
        .toList(growable: false);
  }
}
