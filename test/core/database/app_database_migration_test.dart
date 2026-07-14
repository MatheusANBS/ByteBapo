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

  test(
    'upgrades a version 4 database with message character snapshots',
    () async {
      final database = AppDatabase(
        NativeDatabase.memory(
          setup: (connection) {
            connection
              ..execute('PRAGMA user_version = 4')
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
              CREATE TABLE selected_models (
                server_profile_id TEXT NOT NULL PRIMARY KEY,
                model_id TEXT NOT NULL,
                updated_at INTEGER NOT NULL,
                FOREIGN KEY (server_profile_id)
                  REFERENCES server_profiles (id)
                  ON DELETE CASCADE
              )
            ''')
              ..execute('''
              CREATE TABLE chat_characters (
                id TEXT NOT NULL PRIMARY KEY,
                name TEXT NOT NULL,
                instructions TEXT NOT NULL,
                avatar_path TEXT,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
              )
            ''')
              ..execute('''
              CREATE TABLE conversations (
                id TEXT NOT NULL PRIMARY KEY,
                title TEXT NOT NULL,
                server_profile_id TEXT REFERENCES server_profiles (id)
                  ON DELETE SET NULL,
                server_name_snapshot TEXT,
                provider_snapshot TEXT,
                character_id TEXT REFERENCES chat_characters (id)
                  ON DELETE SET NULL,
                character_name_snapshot TEXT,
                model TEXT NOT NULL,
                system_prompt TEXT,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL,
                archived_at INTEGER
              )
            ''')
              ..execute('''
              CREATE TABLE chat_messages (
                id TEXT NOT NULL PRIMARY KEY,
                conversation_id TEXT NOT NULL REFERENCES conversations (id)
                  ON DELETE CASCADE,
                role TEXT NOT NULL,
                content TEXT NOT NULL,
                thinking TEXT NOT NULL,
                model TEXT,
                status TEXT NOT NULL,
                tool_calls_json TEXT,
                tool_call_id TEXT,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
              )
            ''')
              ..execute('''
              INSERT INTO conversations (
                id, title, model, created_at, updated_at
              ) VALUES ('conversation-1', 'Antiga', 'qwen3', 0, 0)
            ''')
              ..execute('''
              INSERT INTO chat_messages (
                id, conversation_id, role, content, thinking, status,
                created_at, updated_at
              ) VALUES (
                'message-1', 'conversation-1', 'assistant', 'Oi', '',
                'completed', 0, 0
              )
            ''');
          },
        ),
      );
      addTearDown(database.close);

      final columns = await database
          .customSelect('PRAGMA table_info(chat_messages)')
          .get();
      final columnNames = columns.map((row) => row.data['name']);

      expect(columnNames, contains('character_id_snapshot'));
      expect(columnNames, contains('character_name_snapshot'));
      expect(columnNames, contains('character_avatar_path_snapshot'));
      expect(
        (await database.select(database.chatMessages).get()).single.id,
        'message-1',
      );
    },
  );
}
