import 'package:byte_papo/features/models/domain/model_catalog_service.dart';
import 'package:byte_papo/features/providers/domain/entities/available_model.dart';
import 'package:byte_papo/features/providers/domain/model_catalog_gateway.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps successful server models when another catalog fails', () async {
    final server = _server('local', ApiProvider.nvidia);
    final service = ModelCatalogService(
      gatewayFor: (provider) => provider == ApiProvider.nvidia
          ? _CatalogGateway([
              AvailableModel(
                id: 'qwen3',
                displayName: 'Qwen 3',
                serverId: server.id,
                provider: server.provider,
              ),
            ])
          : _CatalogGateway(const [], error: StateError('offline')),
    );

    final result = await service.load([
      server,
      _server('offline', ApiProvider.ollama),
    ]);

    expect(result.models.single.id, 'qwen3');
    expect(result.failures.single.serverId, 'offline');
  });

  test('filters case-insensitively before returning a page of ten', () {
    final models = List.generate(
      12,
      (index) => AvailableModel(
        id: index == 10 ? 'QWEN:latest' : 'model-$index',
        displayName: index == 10 ? 'Qwen Latest' : 'Model $index',
        serverId: 'local',
        provider: ApiProvider.ollama,
      ),
    );

    final page = ModelCatalogService.page(
      models,
      query: 'qWeN',
      provider: ApiProvider.ollama,
      page: 1,
    );

    expect(page.total, 1);
    expect(page.items.single.id, 'QWEN:latest');
  });
}

class _CatalogGateway implements ModelCatalogGateway {
  const _CatalogGateway(this.models, {this.error});

  final List<AvailableModel> models;
  final Object? error;

  @override
  Future<List<AvailableModel>> listModels(ServerProfile server) async {
    if (error != null) throw error!;
    return models;
  }
}

ServerProfile _server(String id, ApiProvider provider) => ServerProfile(
  id: id,
  name: id,
  protocol: provider == ApiProvider.nvidia ? 'https' : 'http',
  host: 'localhost',
  port: provider == ApiProvider.nvidia ? 443 : 11434,
  provider: provider,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);
