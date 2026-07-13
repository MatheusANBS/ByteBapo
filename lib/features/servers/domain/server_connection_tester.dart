import '../../providers/domain/entities/available_model.dart';
import '../../providers/domain/model_catalog_gateway.dart';
import 'entities/server_profile.dart';

abstract interface class ServerConnectionTester {
  Future<ServerConnectionTestResult> test(ServerProfile profile);
}

class ServerConnectionTestResult {
  const ServerConnectionTestResult({
    required this.provider,
    required this.models,
  });

  final ApiProvider provider;
  final List<AvailableModel> models;

  String get successMessage => switch (provider) {
    ApiProvider.nvidia =>
      'Conexão NVIDIA OK. ${models.length} modelo(s) disponível(is).',
    ApiProvider.ollama =>
      'Servidor Ollama encontrado. ${models.length} modelo(s) carregado(s).',
  };
}

class CatalogServerConnectionTester implements ServerConnectionTester {
  const CatalogServerConnectionTester({
    required this.nvidiaCatalog,
    required this.ollamaCatalog,
  });

  final ModelCatalogGateway nvidiaCatalog;
  final ModelCatalogGateway ollamaCatalog;

  @override
  Future<ServerConnectionTestResult> test(ServerProfile profile) async {
    final catalog = switch (profile.provider) {
      ApiProvider.nvidia => nvidiaCatalog,
      ApiProvider.ollama => ollamaCatalog,
    };
    final models = await catalog.listModels(profile);
    return ServerConnectionTestResult(
      provider: profile.provider,
      models: models,
    );
  }
}
