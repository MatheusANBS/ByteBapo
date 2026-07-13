import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

abstract final class AppSettingKey {
  static const activeServerId = 'active_server_id';
}

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

@DriftDatabase(tables: [ServerProfiles, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults() : super(driftDatabase(name: 'bytepapo'));

  @override
  int get schemaVersion => 1;

  Future<String?> readSetting(String key) async {
    final setting = await (select(
      appSettings,
    )..where((row) => row.key.equals(key))).getSingleOrNull();
    return setting?.value;
  }

  Future<void> writeSetting(String key, String? value) async {
    if (value == null) {
      await (delete(appSettings)..where((row) => row.key.equals(key))).go();
      return;
    }
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: Value(value)),
    );
  }

  Future<void> deleteServer(String id) {
    return transaction(() async {
      await (delete(serverProfiles)..where((row) => row.id.equals(id))).go();
      if (await readSetting(AppSettingKey.activeServerId) == id) {
        await writeSetting(AppSettingKey.activeServerId, null);
      }
    });
  }
}
