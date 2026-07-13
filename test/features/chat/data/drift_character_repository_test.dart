import 'package:byte_papo/core/database/app_database.dart' as db;
import 'package:byte_papo/features/chat/data/character_photo_store.dart';
import 'package:byte_papo/features/chat/data/repositories/drift_character_repository.dart';
import 'package:byte_papo/features/chat/domain/entities/chat_character.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late db.AppDatabase database;
  late DriftCharacterRepository repository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = DriftCharacterRepository(database: database);
  });

  tearDown(() => database.close());

  test('lists characters alphabetically and upserts saved character', () async {
    final zelda = _character(id: 'char-1', name: 'Zelda');
    final ada = _character(id: 'char-2', name: 'Ada');

    await repository.save(zelda);
    await repository.save(ada);
    await repository.save(zelda.copyWith(name: 'Zoe'));

    final characters = await repository.list();

    expect(characters.map((character) => character.name), ['Ada', 'Zoe']);
    expect(
      characters.where((character) => character.id == zelda.id),
      hasLength(1),
    );
  });

  test('removing active character clears active selection', () async {
    final character = _character(id: 'char-1', name: 'Ada');
    await repository.save(character);
    await repository.setActiveCharacterId(character.id);

    await repository.remove(character.id);

    expect(await repository.getActiveCharacterId(), isNull);
    expect(
      await database.readSetting(db.AppSettingKey.activeCharacterId),
      isNull,
    );
  });

  test(
    'returns null when the persisted active character no longer exists',
    () async {
      await database.writeSetting(
        db.AppSettingKey.activeCharacterId,
        'missing',
      );

      expect(await repository.getActiveCharacterId(), isNull);
    },
  );

  test('clears active selection for blank id', () async {
    await database.writeSetting(db.AppSettingKey.activeCharacterId, 'char-1');

    await repository.setActiveCharacterId('  ');

    expect(
      await database.readSetting(db.AppSettingKey.activeCharacterId),
      isNull,
    );
  });

  test('does not persist an active id that does not exist', () async {
    await repository.setActiveCharacterId('missing');

    expect(
      await database.readSetting(db.AppSettingKey.activeCharacterId),
      isNull,
    );
  });

  test(
    'copies a new photo before saving and deletes the replaced photo',
    () async {
      final store = _PhotoStore(copyResult: 'managed/new.png');
      repository = DriftCharacterRepository(
        database: database,
        photoStore: store,
      );
      await database
          .into(database.chatCharacters)
          .insert(
            db.ChatCharactersCompanion.insert(
              id: 'char-1',
              name: 'Ada',
              instructions: 'Instrucoes',
              avatarPath: const Value('managed/old.png'),
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          );

      await repository.save(
        _character(
          id: 'char-1',
          name: 'Ada',
        ).copyWith(imagePath: 'external/photo.png'),
      );

      final row = await (database.select(
        database.chatCharacters,
      )..where((row) => row.id.equals('char-1'))).getSingle();
      expect(store.copiedPaths, ['external/photo.png']);
      expect(row.avatarPath, 'managed/new.png');
      expect(store.deletedPaths, ['managed/old.png']);
    },
  );

  test('keeps the existing photo when copying a replacement fails', () async {
    final store = _PhotoStore(
      copyResult: 'unused',
      copyError: StateError('copy failed'),
    );
    repository = DriftCharacterRepository(
      database: database,
      photoStore: store,
    );
    await database
        .into(database.chatCharacters)
        .insert(
          db.ChatCharactersCompanion.insert(
            id: 'char-1',
            name: 'Ada',
            instructions: 'Instrucoes',
            avatarPath: const Value('managed/old.png'),
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );

    await expectLater(
      repository.save(
        _character(
          id: 'char-1',
          name: 'Ada',
        ).copyWith(imagePath: 'external/photo.png'),
      ),
      throwsStateError,
    );

    final row = await (database.select(
      database.chatCharacters,
    )..where((row) => row.id.equals('char-1'))).getSingle();
    expect(row.avatarPath, 'managed/old.png');
    expect(store.deletedPaths, isEmpty);
  });

  test('keeps the previous photo when database persistence fails', () async {
    final store = _PhotoStore(
      copyResult: 'managed/new.png',
      onCopy: database.close,
    );
    repository = DriftCharacterRepository(
      database: database,
      photoStore: store,
    );
    await database
        .into(database.chatCharacters)
        .insert(
          db.ChatCharactersCompanion.insert(
            id: 'char-1',
            name: 'Ada',
            instructions: 'Instrucoes',
            avatarPath: const Value('managed/old.png'),
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );
    await expectLater(
      repository.save(
        _character(
          id: 'char-1',
          name: 'Ada',
        ).copyWith(imagePath: 'external/photo.png'),
      ),
      throwsStateError,
    );

    expect(store.deletedPaths, ['managed/new.png']);
    expect(store.deletedPaths, isNot(contains('managed/old.png')));
  });

  test('deletes a character photo after removing its row', () async {
    final store = _PhotoStore(copyResult: 'unused');
    repository = DriftCharacterRepository(
      database: database,
      photoStore: store,
    );
    await database
        .into(database.chatCharacters)
        .insert(
          db.ChatCharactersCompanion.insert(
            id: 'char-1',
            name: 'Ada',
            instructions: 'Instrucoes',
            avatarPath: const Value('/tmp/char-1.png'),
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );

    await repository.remove('char-1');

    expect(store.deletedPaths, ['/tmp/char-1.png']);
    expect(
      await (database.select(
        database.chatCharacters,
      )..where((row) => row.id.equals('char-1'))).getSingleOrNull(),
      isNull,
    );
  });
}

class _PhotoStore implements CharacterPhotoStore {
  _PhotoStore({required this.copyResult, this.copyError, this.onCopy});

  final String copyResult;
  final Object? copyError;
  final Future<void> Function()? onCopy;
  final copiedPaths = <String>[];
  final deletedPaths = <String>[];

  @override
  Future<String> copyFrom(String sourcePath) async {
    copiedPaths.add(sourcePath);
    await onCopy?.call();
    if (copyError != null) {
      throw copyError!;
    }
    return copyResult;
  }

  @override
  Future<void> delete(String path) async {
    deletedPaths.add(path);
  }
}

ChatCharacter _character({required String id, required String name}) {
  return ChatCharacter(
    id: id,
    name: name,
    instructions: 'Instrucoes',
    imagePath: '/tmp/$id.png',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}
