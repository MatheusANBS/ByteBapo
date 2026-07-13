import '../../servers/domain/entities/server_profile.dart';
import 'entities/available_model.dart';

abstract interface class ModelCatalogGateway {
  Future<List<AvailableModel>> listModels(ServerProfile server);
}
