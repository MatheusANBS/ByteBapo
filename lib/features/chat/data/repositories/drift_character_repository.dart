import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../character_photo_store.dart';
import '../../domain/entities/chat_character.dart';
import '../../domain/repositories/character_repository.dart';

class DriftCharacterRepository implements CharacterRepository {
  const DriftCharacterRepository({required this.database, this.photoStore});

  final db.AppDatabase database;
  final CharacterPhotoStore? photoStore;

  @override
  Future<List<ChatCharacter>> list() async {
    final rows = await (database.select(
      database.chatCharacters,
    )..orderBy([(row) => OrderingTerm.asc(row.name)])).get();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<void> save(ChatCharacter character) async {
    final existing = await (database.select(
      database.chatCharacters,
    )..where((row) => row.id.equals(character.id))).getSingleOrNull();

    var avatarPath = character.imagePath;
    String? copiedPhotoPath;
    if (photoStore != null && avatarPath != null) {
      copiedPhotoPath = await photoStore!.copyFrom(avatarPath);
      avatarPath = copiedPhotoPath;
    }

    try {
      await database
          .into(database.chatCharacters)
          .insertOnConflictUpdate(
            db.ChatCharactersCompanion.insert(
              id: character.id,
              name: character.name,
              instructions: character.instructions,
              avatarPath: Value(avatarPath),
              createdAt: character.createdAt,
              updatedAt: character.updatedAt,
            ),
          );
    } catch (_) {
      if (copiedPhotoPath != null) {
        await photoStore!.delete(copiedPhotoPath);
      }
      rethrow;
    }

    final previousAvatarPath = existing?.avatarPath;
    if (photoStore != null &&
        previousAvatarPath != null &&
        previousAvatarPath != avatarPath) {
      await photoStore!.delete(previousAvatarPath);
    }
  }

  @override
  Future<void> remove(String id) async {
    final existing = await (database.select(
      database.chatCharacters,
    )..where((row) => row.id.equals(id))).getSingleOrNull();

    await database.transaction(() async {
      await (database.delete(
        database.chatCharacters,
      )..where((row) => row.id.equals(id))).go();
      if (await database.readSetting(db.AppSettingKey.activeCharacterId) ==
          id) {
        await database.writeSetting(db.AppSettingKey.activeCharacterId, null);
      }
    });

    if (photoStore != null && existing?.avatarPath != null) {
      await photoStore!.delete(existing!.avatarPath!);
    }
  }

  @override
  Future<String?> getActiveCharacterId() async {
    final id = await database.readSetting(db.AppSettingKey.activeCharacterId);
    if (id == null) {
      return null;
    }
    final exists = await (database.select(
      database.chatCharacters,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    return exists == null ? null : id;
  }

  @override
  Future<void> setActiveCharacterId(String? id) async {
    final normalizedId = id?.trim();
    if (normalizedId == null || normalizedId.isEmpty) {
      await database.writeSetting(db.AppSettingKey.activeCharacterId, null);
      return;
    }
    final exists = await (database.select(
      database.chatCharacters,
    )..where((row) => row.id.equals(normalizedId))).getSingleOrNull();
    if (exists != null) {
      await database.writeSetting(
        db.AppSettingKey.activeCharacterId,
        normalizedId,
      );
    }
  }

  ChatCharacter _toEntity(db.ChatCharacter row) {
    return ChatCharacter(
      id: row.id,
      name: row.name,
      instructions: row.instructions,
      imagePath: row.avatarPath,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
