import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/errors/app_exception.dart';
import '../../../servers/domain/entities/server_profile.dart';
import '../../domain/entities/available_model.dart';
import '../../domain/model_catalog_gateway.dart';

class NvidiaModelCatalogGateway implements ModelCatalogGateway {
  NvidiaModelCatalogGateway({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  @override
  Future<List<AvailableModel>> listModels(ServerProfile server) async {
    final http.Response response;
    try {
      response = await _httpClient.get(
        server.resolve('models'),
        headers: server.headers,
      );
    } on TimeoutException catch (error) {
      throw NvidiaApiException(const TimeoutFailure(), error);
    } on SocketException catch (error) {
      throw NvidiaApiException(
        const NetworkFailure('Nao consegui conectar a API NVIDIA.'),
        error,
      );
    } on HandshakeException catch (error) {
      throw NvidiaApiException(
        const NvidiaApiFailure('A conexao TLS com a NVIDIA falhou.'),
        error,
      );
    } on http.ClientException catch (error) {
      throw NvidiaApiException(
        const NetworkFailure('Nao consegui conectar a API NVIDIA.'),
        error,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NvidiaApiException(
        NvidiaApiFailure(_nvidiaHttpMessage(response.statusCode)),
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

String _nvidiaHttpMessage(int statusCode) {
  if (statusCode == 401) {
    return 'A chave da API NVIDIA nao foi aceita.';
  }
  if (statusCode == 403) {
    return 'Sua conta NVIDIA nao tem permissao para isso.';
  }
  if (statusCode == 404) {
    return 'O endpoint ou modelo NVIDIA nao foi encontrado.';
  }
  if (statusCode == 429) {
    return 'O limite da API NVIDIA foi atingido.';
  }
  if (statusCode >= 500) {
    return 'A API NVIDIA esta indisponivel no momento.';
  }
  return 'A API NVIDIA retornou um erro.';
}
