abstract class ModelSelectionRepository {
  Future<String?> getSelectedModel({String? serverProfileId});

  Future<void> setSelectedModel(String? model, {String? serverProfileId});

  Future<void> selectModelAndActivateServer({
    required String model,
    required String serverProfileId,
  });
}
