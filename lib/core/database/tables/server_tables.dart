import 'package:drift/drift.dart';

class ServerProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get provider => text()();
  TextColumn get protocol => text()();
  TextColumn get host => text()();
  IntColumn get port => integer()();
  TextColumn get basePath => text().nullable()();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get apiKeyAlias => text().nullable()();
  TextColumn get lastConnectionStatus =>
      text().withDefault(const Constant('unknown'))();
  DateTimeColumn get lastConnectedAt => dateTime().nullable()();
  DateTimeColumn get lastCheckedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class SelectedModels extends Table {
  TextColumn get serverProfileId =>
      text().references(ServerProfiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get modelId => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {serverProfileId};
}
