import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/model_selection_repository.dart';

class ModelSelectionRepositoryImpl implements ModelSelectionRepository {
  const ModelSelectionRepositoryImpl({required this.preferences});

  static const _selectedModelKey = 'models.selected.v1';

  final SharedPreferences preferences;

  @override
  Future<String?> getSelectedModel({String? serverProfileId}) async {
    return preferences.getString(_key(serverProfileId));
  }

  @override
  Future<void> setSelectedModel(
    String? model, {
    String? serverProfileId,
  }) async {
    if (model == null || model.isEmpty) {
      await preferences.remove(_key(serverProfileId));
      return;
    }
    await preferences.setString(_key(serverProfileId), model);
  }

  String _key(String? serverProfileId) {
    if (serverProfileId == null || serverProfileId.isEmpty) {
      return _selectedModelKey;
    }
    return '$_selectedModelKey.$serverProfileId';
  }
}
