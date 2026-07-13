import 'package:byte_papo/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clears the active setting when its server is deleted', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database
        .into(database.serverProfiles)
        .insert(
          ServerProfilesCompanion.insert(
            id: 'server-1',
            name: 'NVIDIA',
            provider: 'nvidia',
            protocol: 'https',
            host: 'integrate.api.nvidia.com',
            port: 443,
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );
    await database.writeSetting(AppSettingKey.activeServerId, 'server-1');

    await database.deleteServer('server-1');

    expect(await database.readSetting(AppSettingKey.activeServerId), isNull);
  });

  test('deletes a selected model when its server is deleted', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final now = DateTime.utc(2026);

    await database
        .into(database.serverProfiles)
        .insert(
          ServerProfilesCompanion.insert(
            id: 'server-1',
            name: 'Ollama',
            provider: 'ollama',
            protocol: 'http',
            host: '127.0.0.1',
            port: 11434,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.selectedModels)
        .insert(
          SelectedModelsCompanion.insert(
            serverProfileId: 'server-1',
            modelId: 'qwen3:latest',
            updatedAt: now,
          ),
        );

    await database.deleteServer('server-1');

    expect(await database.select(database.selectedModels).get(), isEmpty);
  });
}
