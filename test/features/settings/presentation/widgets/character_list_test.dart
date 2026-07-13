import 'package:byte_papo/features/chat/domain/entities/chat_character.dart';
import 'package:byte_papo/features/settings/presentation/widgets/character_list.dart';
import 'package:byte_papo/features/settings/presentation/character_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the management hierarchy and a primary add action', (
    tester,
  ) async {
    final character = ChatCharacter.create(
      id: 'luna',
      name: 'Luna',
      instructions: 'Curiosa e observadora.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CharacterManagementScreen(
          characters: [character],
          activeCharacter: character,
          onSelect: (_) async {},
          onEdit: (_) {},
          onDelete: (_) {},
          onCreate: () {},
        ),
      ),
    );

    expect(find.text('Personagens'), findsOneWidget);
    expect(find.text('Pesquisar personagens'), findsOneWidget);
    expect(find.text('Adicionar personagem'), findsOneWidget);
    expect(find.text('Luna'), findsOneWidget);
  });

  testWidgets('selects a character through its callback', (tester) async {
    String? selectedId;
    final character = ChatCharacter.create(
      id: 'char-1',
      name: 'Assistente',
      instructions: 'Seja direto.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CharacterList(
            characters: [character],
            activeCharacter: null,
            onCreate: () {},
            onSelect: (id) async => selectedId = id,
            onEdit: (_) {},
            onDelete: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Assistente'));

    expect(selectedId, 'char-1');
  });

  testWidgets('filters characters without considering letter case', (
    tester,
  ) async {
    final ada = ChatCharacter.create(
      id: 'ada',
      name: 'Ada Lovelace',
      instructions: '',
    );
    final grace = ChatCharacter.create(
      id: 'grace',
      name: 'Grace Hopper',
      instructions: '',
    );

    await tester.pumpWidget(_characterList(characters: [ada, grace]));

    await tester.enterText(find.byType(TextField), 'aDa');
    await tester.pump();

    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('Grace Hopper'), findsNothing);
  });

  testWidgets('asks for confirmation before deleting a character', (
    tester,
  ) async {
    var deleted = false;
    final character = ChatCharacter.create(
      id: 'char-1',
      name: 'Assistente',
      instructions: '',
    );

    await tester.pumpWidget(
      _characterList(characters: [character], onDelete: (_) => deleted = true),
    );

    await tester.tap(find.byTooltip('Excluir Assistente'));
    await tester.pumpAndSettle();

    expect(find.text('Excluir personagem?'), findsOneWidget);
    expect(deleted, isFalse);

    await tester.tap(find.text('Excluir', skipOffstage: false).last);
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
  });
}

Widget _characterList({
  required List<ChatCharacter> characters,
  void Function(ChatCharacter character)? onDelete,
}) {
  return MaterialApp(
    home: Scaffold(
      body: CharacterList(
        characters: characters,
        activeCharacter: null,
        onCreate: () {},
        onSelect: (_) async {},
        onEdit: (_) {},
        onDelete: onDelete ?? (_) {},
      ),
    ),
  );
}
