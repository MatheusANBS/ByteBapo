import 'dart:convert';

import 'package:byte_papo/features/providers/data/ollama/ollama_model_catalog_gateway.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('lists models from the Ollama tags endpoint', () async {
    http.Request? captured;
    final gateway = OllamaModelCatalogGateway(
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'models': [
              {'name': 'llama3.2', 'size': 2048},
            ],
          }),
          200,
        );
      }),
    );

    final models = await gateway.listModels(_server());

    expect(captured!.url.path, '/api/tags');
    expect(models.single.id, 'llama3.2');
    expect(models.single.sizeBytes, 2048);
    expect(models.single.provider, ApiProvider.ollama);
  });
}

ServerProfile _server() => ServerProfile(
  id: 'ollama',
  name: 'Ollama',
  protocol: 'http',
  host: 'localhost',
  port: 11434,
  headers: const {},
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);
