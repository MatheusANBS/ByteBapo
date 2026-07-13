import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../servers/domain/entities/server_profile.dart';
import '../../domain/entities/available_model.dart';
import '../../domain/model_catalog_gateway.dart';

class OllamaModelCatalogGateway implements ModelCatalogGateway {
  OllamaModelCatalogGateway({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  @override
  Future<List<AvailableModel>> listModels(ServerProfile server) async {
    final response = await _httpClient.get(server.resolve('api/tags'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Ollama model catalog returned HTTP ${response.statusCode}.',
      );
    }
    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic> || payload['models'] is! List) {
      return const [];
    }
    return (payload['models'] as List)
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final name = item['name'] as String? ?? '';
          return AvailableModel(
            id: name,
            displayName: name,
            serverId: server.id,
            provider: ApiProvider.ollama,
            sizeBytes: (item['size'] as num?)?.toInt(),
          );
        })
        .where((model) => model.id.isNotEmpty)
        .toList(growable: false);
  }
}
