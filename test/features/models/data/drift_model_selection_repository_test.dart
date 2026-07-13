import 'package:byte_papo/core/database/app_database.dart';
import 'package:byte_papo/features/models/data/repositories/drift_model_selection_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftModelSelectionRepository repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftModelSelectionRepository(database: database);
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
  });

  tearDown(() => database.close());

  test('updates and clears the selection for one server', () async {
    await repository.setSelectedModel(
      'qwen3:latest',
      serverProfileId: 'server-1',
    );

    expect(
      await repository.getSelectedModel(serverProfileId: 'server-1'),
      'qwen3:latest',
    );

    await repository.setSelectedModel(null, serverProfileId: 'server-1');

    expect(
      await repository.getSelectedModel(serverProfileId: 'server-1'),
      isNull,
    );
  });
}
