import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/chat_character.dart';
import '../../domain/repositories/character_repository.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  const CharacterRepositoryImpl({required this.preferences});

  static const _charactersKey = 'chat.characters.v1';
  static const _activeCharacterKey = 'chat.active_character.v1';

  final SharedPreferences preferences;

  @override
  Future<List<ChatCharacter>> list() async {
    final raw = preferences.getStringList(_charactersKey) ?? const [];
    final characters = raw
        .map(
          (item) =>
              ChatCharacter.fromJson(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList();
    characters.sort((a, b) => a.name.compareTo(b.name));
    return characters;
  }

  @override
  Future<void> save(ChatCharacter character) async {
    final characters = await list();
    final index = characters.indexWhere((item) => item.id == character.id);
    final next = [...characters];
    if (index == -1) {
      next.add(character);
    } else {
      next[index] = character;
    }
    await preferences.setStringList(
      _charactersKey,
      next.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  @override
  Future<void> remove(String id) async {
    final characters = await list();
    final next = characters
        .where((character) => character.id != id)
        .toList(growable: false);
    await preferences.setStringList(
      _charactersKey,
      next.map((item) => jsonEncode(item.toJson())).toList(),
    );
    if (preferences.getString(_activeCharacterKey) == id) {
      if (next.isEmpty) {
        await preferences.remove(_activeCharacterKey);
      } else {
        await preferences.setString(_activeCharacterKey, next.first.id);
      }
    }
  }

  @override
  Future<String?> getActiveCharacterId() async {
    final id = preferences.getString(_activeCharacterKey);
    if (id == null) {
      return null;
    }
    final exists = (await list()).any((character) => character.id == id);
    return exists ? id : null;
  }

  @override
  Future<void> setActiveCharacterId(String? id) async {
    final trimmed = id?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await preferences.remove(_activeCharacterKey);
      return;
    }
    await preferences.setString(_activeCharacterKey, trimmed);
  }
}
