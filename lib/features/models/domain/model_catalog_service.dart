import '../../providers/domain/entities/available_model.dart';
import '../../providers/domain/model_catalog_gateway.dart';
import '../../servers/domain/entities/server_profile.dart';

class ModelCatalogService {
  const ModelCatalogService({required this.gatewayFor});

  final ModelCatalogGateway Function(ApiProvider provider) gatewayFor;

  Future<ModelCatalogResult> load(List<ServerProfile> servers) async {
    final models = <AvailableModel>[];
    final failures = <ModelCatalogFailure>[];
    for (final server in servers) {
      try {
        models.addAll(await gatewayFor(server.provider).listModels(server));
      } catch (error) {
        failures.add(ModelCatalogFailure(serverId: server.id, cause: error));
      }
    }
    return ModelCatalogResult(models: models, failures: failures);
  }

  static ModelPage page(
    List<AvailableModel> models, {
    String query = '',
    ApiProvider? provider,
    int page = 1,
    int pageSize = 10,
  }) {
    final needle = query.trim().toLowerCase();
    final filtered = models
        .where((model) {
          final providerMatches =
              provider == null || model.provider == provider;
          final queryMatches =
              needle.isEmpty ||
              model.id.toLowerCase().contains(needle) ||
              model.displayName.toLowerCase().contains(needle);
          return providerMatches && queryMatches;
        })
        .toList(growable: false);
    final pageCount = filtered.isEmpty
        ? 1
        : (filtered.length / pageSize).ceil();
    final safePage = page.clamp(1, pageCount);
    final start = (safePage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, filtered.length);
    return ModelPage(
      items: filtered.sublist(start, end),
      page: safePage,
      pageCount: pageCount,
      total: filtered.length,
      pageSize: pageSize,
    );
  }
}

class ModelCatalogResult {
  const ModelCatalogResult({required this.models, required this.failures});

  final List<AvailableModel> models;
  final List<ModelCatalogFailure> failures;
}

class ModelCatalogFailure {
  const ModelCatalogFailure({required this.serverId, required this.cause});

  final String serverId;
  final Object cause;
}

class ModelPage {
  const ModelPage({
    required this.items,
    required this.page,
    required this.pageCount,
    required this.total,
    required this.pageSize,
  });

  final List<AvailableModel> items;
  final int page;
  final int pageCount;
  final int total;
  final int pageSize;

  int get start => total == 0 ? 0 : (page - 1) * pageSize + 1;
  int get end => (start - 1 + items.length).clamp(0, total);
  bool get hasPrevious => page > 1;
  bool get hasNext => page < pageCount;
}
