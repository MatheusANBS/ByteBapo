abstract class InstructionsRepository {
  Future<String?> loadGlobalInstructions();

  Future<void> saveGlobalInstructions(String? instructions);
}
