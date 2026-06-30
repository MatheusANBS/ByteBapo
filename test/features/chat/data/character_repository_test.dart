import 'package:flutter_test/flutter_test.dart';
import 'package:byte_papo/features/chat/data/repositories/character_repository_impl.dart';
import 'package:byte_papo/features/chat/domain/entities/chat_character.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('saves lists and selects a character', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = CharacterRepositoryImpl(preferences: preferences);
    final character = ChatCharacter.create(
      id: 'char-1',
      name: 'Ada',
      instructions: 'Responda como uma engenheira objetiva.',
      imagePath: '/tmp/ada.png',
    );

    await repository.save(character);
    await repository.setActiveCharacterId(character.id);

    final characters = await repository.list();

    expect(characters, hasLength(1));
    expect(characters.single.name, 'Ada');
    expect(characters.single.instructions, contains('engenheira'));
    expect(characters.single.imagePath, '/tmp/ada.png');
    expect(await repository.getActiveCharacterId(), 'char-1');
  });

  test(
    'removing the active character selects the remaining first character',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = CharacterRepositoryImpl(preferences: preferences);
      final ada = ChatCharacter.create(
        id: 'char-1',
        name: 'Ada',
        instructions: 'Objetiva.',
      );
      final bob = ChatCharacter.create(
        id: 'char-2',
        name: 'Bob',
        instructions: 'Didatico.',
      );

      await repository.save(ada);
      await repository.save(bob);
      await repository.setActiveCharacterId(ada.id);
      await repository.remove(ada.id);

      expect(await repository.getActiveCharacterId(), bob.id);
      expect(await repository.list(), hasLength(1));
    },
  );
}
