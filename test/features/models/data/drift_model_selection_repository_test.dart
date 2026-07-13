import 'package:byte_papo/core/database/app_database.dart';
import 'package:byte_papo/features/models/data/repositories/drift_model_selection_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'selecting a model activates its server in the same database operation',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final now = DateTime.utc(2026);
      await database
          .into(database.serverProfiles)
          .insert(
            ServerProfilesCompanion.insert(
              id: 'server-1',
              name: 'Local',
              provider: 'ollama',
              protocol: 'http',
              host: 'localhost',
              port: 11434,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await DriftModelSelectionRepository(
        database: database,
      ).selectModelAndActivateServer(
        model: 'qwen3',
        serverProfileId: 'server-1',
      );

      expect(
        await database.readSetting(AppSettingKey.activeServerId),
        'server-1',
      );
      expect(
        (await database.select(database.selectedModels).getSingle()).modelId,
        'qwen3',
      );
    },
  );
}
