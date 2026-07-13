import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;

abstract final class ConversationSearchQuery {
  static Future<List<db.Conversation>> execute(
    db.AppDatabase database, {
    String? query,
    int limit = 50,
    int offset = 0,
  }) async {
    final searchTerm = query?.trim();
    final conversations = database.select(database.conversations)
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)])
      ..limit(limit, offset: offset);

    if (searchTerm != null && searchTerm.isNotEmpty) {
      final messageRows = await (database.select(
        database.chatMessages,
      )..where((row) => row.content.contains(searchTerm))).get();
      final messageConversationIds = messageRows
          .map((row) => row.conversationId)
          .toSet();

      conversations.where((row) {
        var filter =
            row.title.contains(searchTerm) |
            row.model.contains(searchTerm) |
            row.serverNameSnapshot.contains(searchTerm) |
            row.characterNameSnapshot.contains(searchTerm);
        if (messageConversationIds.isNotEmpty) {
          filter = filter | row.id.isIn(messageConversationIds);
        }
        return filter;
      });
    }

    return conversations.get();
  }
}
