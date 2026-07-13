import 'dart:convert';

import 'package:byte_papo/features/providers/data/nvidia/nvidia_model_catalog_gateway.dart';
import 'package:byte_papo/core/errors/app_exception.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('lists NVIDIA models from v1 using bearer authentication', () async {
    http.Request? captured;
    final gateway = NvidiaModelCatalogGateway(
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': [
              {'id': 'meta/llama-3.1-8b-instruct'},
            ],
          }),
          200,
        );
      }),
    );

    final models = await gateway.listModels(_server());

    expect(captured!.url.path, '/v1/models');
    expect(captured!.headers['Authorization'], 'Bearer nvapi-test');
    expect(models.single.id, 'meta/llama-3.1-8b-instruct');
    expect(models.single.provider, ApiProvider.nvidia);
  });

  test('translates NVIDIA catalog HTTP failures to a provider exception', () {
    final gateway = NvidiaModelCatalogGateway(
      httpClient: MockClient((_) async => http.Response('', 401)),
    );

    expect(
      () => gateway.listModels(_server()),
      throwsA(isA<NvidiaApiException>()),
    );
  });
}

ServerProfile _server() => ServerProfile(
  id: 'nvidia',
  name: 'NVIDIA',
  protocol: 'https',
  host: 'integrate.api.nvidia.com',
  port: 443,
  basePath: '/v1',
  headers: const {'Authorization': 'Bearer nvapi-test'},
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  provider: ApiProvider.nvidia,
);
