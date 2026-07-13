import 'package:byte_papo/core/database/app_database.dart'
    hide ChatCharacter, Conversation, ServerProfile;
import 'package:byte_papo/features/models/data/repositories/drift_model_selection_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upgrades a version 1 database before selecting a model', () async {
    final database = AppDatabase(
      NativeDatabase.memory(
        setup: (connection) {
          connection
            ..execute('PRAGMA user_version = 1')
            ..execute('''
              CREATE TABLE server_profiles (
                id TEXT NOT NULL PRIMARY KEY,
                name TEXT NOT NULL,
                provider TEXT NOT NULL,
                protocol TEXT NOT NULL,
                host TEXT NOT NULL,
                port INTEGER NOT NULL,
                base_path TEXT,
                avatar_path TEXT,
                api_key_alias TEXT,
                last_connection_status TEXT NOT NULL DEFAULT 'unknown',
                last_connected_at INTEGER,
                last_checked_at INTEGER,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
              )
            ''')
            ..execute('''
              CREATE TABLE app_settings (
                key TEXT NOT NULL PRIMARY KEY,
                value TEXT
              )
            ''')
            ..execute('''
              INSERT INTO server_profiles (
                id, name, provider, protocol, host, port, created_at, updated_at
              ) VALUES (
                'server-1', 'Servidor existente', 'ollama', 'http',
                '192.168.0.2', 11434, 0, 0
              )
            ''');
        },
      ),
    );
    addTearDown(database.close);

    await DriftModelSelectionRepository(
      database: database,
    ).selectModelAndActivateServer(
      model: 'qwen3:latest',
      serverProfileId: 'server-1',
    );

    expect(
      (await database.select(database.serverProfiles).getSingle()).name,
      'Servidor existente',
    );
    expect(
      (await database.select(database.selectedModels).getSingle()).modelId,
      'qwen3:latest',
    );
    expect(
      await database.readSetting(AppSettingKey.activeServerId),
      'server-1',
    );
  });
}
