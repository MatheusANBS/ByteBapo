import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../servers/domain/entities/server_profile.dart';
import '../../domain/entities/available_model.dart';
import '../../domain/model_catalog_gateway.dart';

class NvidiaModelCatalogGateway implements ModelCatalogGateway {
  NvidiaModelCatalogGateway({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  @override
  Future<List<AvailableModel>> listModels(ServerProfile server) async {
    final response = await _httpClient.get(
      server.resolve('models'),
      headers: server.headers,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'NVIDIA model catalog returned HTTP ${response.statusCode}.',
      );
    }
    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic> || payload['data'] is! List) {
      return const [];
    }
    return (payload['data'] as List)
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final id = item['id'] as String? ?? '';
          return AvailableModel(
            id: id,
            displayName: id,
            serverId: server.id,
            provider: ApiProvider.nvidia,
          );
        })
        .where((model) => model.id.isNotEmpty)
        .toList(growable: false);
  }
}
