import '../../../../core/database/app_database.dart';
import '../../domain/repositories/instructions_repository.dart';

class DriftInstructionsRepository implements InstructionsRepository {
  const DriftInstructionsRepository({required this.database});

  final AppDatabase database;

  @override
  Future<String?> loadGlobalInstructions() async {
    final value = (await database.readSetting(
      AppSettingKey.globalPrompt,
    ))?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  @override
  Future<void> saveGlobalInstructions(String? instructions) {
    final value = instructions?.trim();
    return database.writeSetting(
      AppSettingKey.globalPrompt,
      value == null || value.isEmpty ? null : value,
    );
  }
}
