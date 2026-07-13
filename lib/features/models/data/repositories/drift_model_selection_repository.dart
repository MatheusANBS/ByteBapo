import '../../../../core/database/app_database.dart';
import '../../domain/repositories/model_selection_repository.dart';

class DriftModelSelectionRepository implements ModelSelectionRepository {
  const DriftModelSelectionRepository({required this.database});

  final AppDatabase database;

  @override
  Future<String?> getSelectedModel({String? serverProfileId}) async {
    if (serverProfileId == null || serverProfileId.isEmpty) {
      return null;
    }
    final row =
        await (database.select(database.selectedModels)..where(
              (selection) => selection.serverProfileId.equals(serverProfileId),
            ))
            .getSingleOrNull();
    return row?.modelId;
  }

  @override
  Future<void> setSelectedModel(
    String? model, {
    String? serverProfileId,
  }) async {
    if (serverProfileId == null || serverProfileId.isEmpty) {
      return;
    }
    if (model == null || model.isEmpty) {
      await (database.delete(database.selectedModels)..where(
            (selection) => selection.serverProfileId.equals(serverProfileId),
          ))
          .go();
      return;
    }
    await database
        .into(database.selectedModels)
        .insertOnConflictUpdate(
          SelectedModelsCompanion.insert(
            serverProfileId: serverProfileId,
            modelId: model,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  @override
  Future<void> selectModelAndActivateServer({
    required String model,
    required String serverProfileId,
  }) {
    return database.transaction(() async {
      await setSelectedModel(model, serverProfileId: serverProfileId);
      await database.writeSetting(
        AppSettingKey.activeServerId,
        serverProfileId,
      );
    });
  }
}
