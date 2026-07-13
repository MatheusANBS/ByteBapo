import 'package:drift/drift.dart';

import 'server_tables.dart';

class ChatCharacters extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get instructions => text()();
  TextColumn get avatarPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'conversations_updated_at', columns: {#updatedAt})
class Conversations extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get serverProfileId => text().nullable().references(
    ServerProfiles,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get serverNameSnapshot => text().nullable()();
  TextColumn get providerSnapshot => text().nullable()();
  TextColumn get characterId => text().nullable().references(
    ChatCharacters,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get characterNameSnapshot => text().nullable()();
  TextColumn get model => text()();
  TextColumn get systemPrompt => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(
  name: 'chat_messages_conversation_created_at',
  columns: {#conversationId, #createdAt},
)
class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId =>
      text().references(Conversations, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get thinking => text()();
  TextColumn get model => text().nullable()();
  TextColumn get status => text()();
  TextColumn get toolCallsJson => text().nullable()();
  TextColumn get toolCallId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
