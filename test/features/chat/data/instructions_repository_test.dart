import 'package:flutter_test/flutter_test.dart';
import 'package:byte_papo/features/chat/data/repositories/instructions_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'InstructionsRepositoryImpl saves and loads global instructions',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = InstructionsRepositoryImpl(preferences: preferences);

      await repository.saveGlobalInstructions('Responda sempre em portugues.');

      expect(
        await repository.loadGlobalInstructions(),
        'Responda sempre em portugues.',
      );
    },
  );

  test('InstructionsRepositoryImpl removes blank instructions', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = InstructionsRepositoryImpl(preferences: preferences);

    await repository.saveGlobalInstructions('Use respostas curtas.');
    await repository.saveGlobalInstructions('   ');

    expect(await repository.loadGlobalInstructions(), isNull);
  });
}
