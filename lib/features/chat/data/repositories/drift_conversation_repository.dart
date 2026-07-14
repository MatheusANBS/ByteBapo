import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart'
    hide ChatMessage, Conversation;
import '../mappers/conversation_mapper.dart';
import '../queries/conversation_search_query.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';

class DriftConversationRepository implements ConversationRepository {
  const DriftConversationRepository({required this.database});

  final AppDatabase database;

  @override
  Future<List<Conversation>> listConversations() async {
    final rows = await (database.select(
      database.conversations,
    )..orderBy([(row) => OrderingTerm.desc(row.updatedAt)])).get();
    return rows
        .map(ConversationMapper.conversationFromRow)
        .toList(growable: false);
  }

  @override
  Future<List<Conversation>> listConversationsPage({
    String? query,
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = await ConversationSearchQuery.execute(
      database,
      query: query,
      limit: limit,
      offset: offset,
    );
    return rows
        .map(ConversationMapper.conversationFromRow)
        .toList(growable: false);
  }

  @override
  Future<void> saveConversation(Conversation conversation) {
    return database
        .into(database.conversations)
        .insertOnConflictUpdate(
          ConversationsCompanion(
            id: Value(conversation.id),
            title: Value(conversation.title),
            serverProfileId: Value(conversation.serverProfileId),
            serverNameSnapshot: Value(conversation.serverNameSnapshot),
            providerSnapshot: Value(conversation.providerSnapshot),
            characterId: Value(conversation.characterId),
            characterNameSnapshot: Value(conversation.characterNameSnapshot),
            model: Value(conversation.model),
            systemPrompt: Value(conversation.systemPrompt),
            createdAt: Value(conversation.createdAt),
            updatedAt: Value(conversation.updatedAt),
            archivedAt: Value(conversation.archivedAt),
          ),
        );
  }

  @override
  Future<void> removeConversation(String id) async {
    await (database.delete(
      database.conversations,
    )..where((row) => row.id.equals(id))).go();
  }

  @override
  Future<List<ChatMessage>> listMessages(String conversationId) async {
    final rows =
        await (database.select(database.chatMessages)
              ..where((row) => row.conversationId.equals(conversationId))
              ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
            .get();
    return rows.map(ConversationMapper.messageFromRow).toList(growable: false);
  }

  @override
  Future<void> saveMessage(ChatMessage message) {
    return database
        .into(database.chatMessages)
        .insertOnConflictUpdate(
          ChatMessagesCompanion(
            id: Value(message.id),
            conversationId: Value(message.conversationId),
            role: Value(message.role.name),
            content: Value(message.content),
            thinking: Value(message.thinking),
            model: Value(message.model),
            status: Value(message.status.name),
            toolCallsJson: Value(
              ConversationMapper.encodeToolCalls(message.toolCalls),
            ),
            toolCallId: Value(message.toolCallId),
            characterIdSnapshot: Value(message.characterIdSnapshot),
            characterNameSnapshot: Value(message.characterNameSnapshot),
            characterAvatarPathSnapshot: Value(
              message.characterAvatarPathSnapshot,
            ),
            createdAt: Value(message.createdAt),
            updatedAt: Value(message.updatedAt),
          ),
        );
  }

  @override
  Future<void> removeMessage(String messageId) async {
    await (database.delete(
      database.chatMessages,
    )..where((row) => row.id.equals(messageId))).go();
  }

  @override
  Future<void> removeMessages(String conversationId) async {
    await (database.delete(
      database.chatMessages,
    )..where((row) => row.conversationId.equals(conversationId))).go();
  }
}
