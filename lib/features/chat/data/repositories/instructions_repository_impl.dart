import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/instructions_repository.dart';

class InstructionsRepositoryImpl implements InstructionsRepository {
  const InstructionsRepositoryImpl({required this.preferences});

  static const _globalInstructionsKey = 'chat.global_instructions.v1';

  final SharedPreferences preferences;

  @override
  Future<String?> loadGlobalInstructions() async {
    final value = preferences.getString(_globalInstructionsKey)?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  @override
  Future<void> saveGlobalInstructions(String? instructions) async {
    final value = instructions?.trim();
    if (value == null || value.isEmpty) {
      await preferences.remove(_globalInstructionsKey);
      return;
    }
    await preferences.setString(_globalInstructionsKey, value);
  }
}
