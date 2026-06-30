import '../entities/chat_character.dart';

abstract class CharacterRepository {
  Future<List<ChatCharacter>> list();

  Future<void> save(ChatCharacter character);

  Future<void> remove(String id);

  Future<String?> getActiveCharacterId();

  Future<void> setActiveCharacterId(String? id);
}
