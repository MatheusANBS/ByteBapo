import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/chat_tables.dart';
import 'tables/server_tables.dart';

part 'app_database.g.dart';

abstract final class AppSettingKey {
  static const activeServerId = 'active_server_id';
  static const activeCharacterId = 'active_character_id';
  static const globalPrompt = 'global_prompt';
}

@DriftDatabase(
  tables: [
    ServerProfiles,
    AppSettings,
    SelectedModels,
    ChatCharacters,
    Conversations,
    ChatMessages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults() : super(driftDatabase(name: 'bytepapo'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(selectedModels);
      }
      if (from < 3) {
        await migrator.createTable(chatCharacters);
      }
      if (from < 4) {
        await migrator.createTable(conversations);
        await migrator.createTable(chatMessages);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

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
