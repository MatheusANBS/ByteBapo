import 'package:byte_papo/features/settings/presentation/widgets/global_prompt_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('forwards the edited global instructions when saved', (
    tester,
  ) async {
    String? savedValue;
    final controller = TextEditingController(text: 'Initial prompt');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlobalPromptEditor(
            controller: controller,
            onSave: (value) async => savedValue = value,
            onClear: () async {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Prompt atualizado');
    await tester.tap(find.text('Salvar'));

    expect(savedValue, 'Prompt atualizado');
  });
}
