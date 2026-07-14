import 'package:byte_papo/features/chat/domain/entities/chat_character.dart';
import 'package:byte_papo/features/chat/presentation/widgets/chat_character_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('scrolls many characters inside the picker sheet', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final characters = [
      for (var index = 0; index < 24; index++)
        ChatCharacter.create(
          id: 'char-$index',
          name: 'Personagem $index',
          instructions: 'Instrucoes $index',
        ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatCharacterSelector(
            characters: characters,
            activeCharacter: null,
            enabled: true,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Sem personagem'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.dragUntilVisible(
      find.text('Personagem 23'),
      find.byType(ListView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    expect(find.text('Personagem 23'), findsOneWidget);
  });
}
