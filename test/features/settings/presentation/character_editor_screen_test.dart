import 'package:byte_papo/features/characters/domain/avatar_picker.dart';
import 'package:byte_papo/features/settings/presentation/character_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses the approved editor labels and saves a character', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: CharacterEditorScreen(avatarPicker: _AvatarPicker())),
    );

    expect(find.text('Novo personagem'), findsOneWidget);
    expect(find.text('Alterar foto'), findsOneWidget);
    expect(find.text('Prompt do personagem'), findsOneWidget);
    expect(find.text('Salvar personagem'), findsOneWidget);
  });

  testWidgets('keeps fields scrollable when the viewport becomes short', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: CharacterEditorScreen(avatarPicker: _AvatarPicker())),
    );

    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}

class _AvatarPicker implements AvatarPicker {
  @override
  Future<String?> pickImagePath() async => null;
}
