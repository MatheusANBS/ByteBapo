import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/errors/app_exception.dart';
import '../../../servers/domain/entities/server_profile.dart';
import '../../domain/entities/available_model.dart';
import '../../domain/model_catalog_gateway.dart';

class OllamaModelCatalogGateway implements ModelCatalogGateway {
  OllamaModelCatalogGateway({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  @override
  Future<List<AvailableModel>> listModels(ServerProfile server) async {
    final http.Response response;
    try {
      response = await _httpClient.get(server.resolve('api/tags'));
    } on TimeoutException catch (error) {
      throw OllamaApiException(const TimeoutFailure(), error);
    } on SocketException catch (error) {
      throw OllamaApiException(const NetworkFailure(), error);
    } on HandshakeException catch (error) {
      throw OllamaApiException(
        const OllamaApiFailure('A conexao TLS com o Ollama falhou.'),
        error,
      );
    } on http.ClientException catch (error) {
      throw OllamaApiException(const NetworkFailure(), error);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OllamaApiException(
        OllamaApiFailure(_ollamaHttpMessage(response.statusCode)),
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

String _ollamaHttpMessage(int statusCode) {
  if (statusCode == 404) {
    return 'O endpoint ou modelo Ollama nao foi encontrado.';
  }
  if (statusCode >= 500) {
    return 'O servidor Ollama esta indisponivel no momento.';
  }
  return 'O servidor Ollama retornou uma resposta inesperada.';
}
