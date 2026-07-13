import 'package:byte_papo/core/database/app_database.dart';
import 'package:byte_papo/features/chat/data/repositories/drift_instructions_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftInstructionsRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftInstructionsRepository(database: database);
  });

  tearDown(() => database.close());

  test('trims and loads the global prompt', () async {
    await repository.saveGlobalInstructions('  Responda objetivamente.  ');

    expect(
      await repository.loadGlobalInstructions(),
      'Responda objetivamente.',
    );
  });

  test('removes global prompt when it is blank', () async {
    await repository.saveGlobalInstructions('Prompt atual');

    await repository.saveGlobalInstructions('  ');

    expect(await repository.loadGlobalInstructions(), isNull);
    expect(await database.readSetting(AppSettingKey.globalPrompt), isNull);
  });
}
