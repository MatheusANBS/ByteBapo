import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../features/chat/domain/entities/chat_message.dart';
import '../../features/chat/domain/entities/generation_options.dart';
import '../../features/models/domain/entities/ollama_model.dart';
import '../../features/servers/domain/entities/server_profile.dart';
import '../errors/app_exception.dart';
import 'ollama_endpoints.dart';
import 'ollama_stream_parser.dart';

class OllamaApiClient {
  OllamaApiClient({http.Client? httpClient, Duration? timeout})
    : _httpClient = httpClient ?? http.Client(),
      _timeout = timeout ?? const Duration(seconds: 30);

  final http.Client _httpClient;
  final Duration _timeout;

  Future<List<OllamaModel>> listModels(ServerProfile server) async {
    final response = await _guardHttp(
      () => _httpClient
          .get(server.resolve(OllamaEndpoints.tags), headers: server.headers)
          .timeout(_timeout),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OllamaApiException(_failureForStatus(response.statusCode));
    }

    try {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final models = payload['models'];
      if (models is! List) {
        return const [];
      }
      return models
          .whereType<Map<String, dynamic>>()
          .map(OllamaModel.fromJson)
          .toList(growable: false);
    } on FormatException catch (error) {
      throw OllamaApiException(const OllamaApiFailure(), error);
    } on TypeError catch (error) {
      throw OllamaApiException(const OllamaApiFailure(), error);
    }
  }

  Stream<OllamaChatChunk> streamChat({
    required ServerProfile server,
    required String model,
    required List<ChatMessage> messages,
    GenerationOptions options = const GenerationOptions(),
  }) async* {
    final request = http.Request('POST', server.resolve(OllamaEndpoints.chat));
    request.headers.addAll(server.headers);
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'model': model,
      'messages': messages.map((message) => message.toOllamaJson()).toList(),
      'stream': options.stream,
      if (options.thinking != ThinkingMode.modelDefault)
        'think': options.thinking.ollamaValue,
      if (options.toOllamaOptionsJson().isNotEmpty)
        'options': options.toOllamaOptionsJson(),
    });

    final response = await _guardHttp(() => _httpClient.send(request));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OllamaApiException(_failureForStatus(response.statusCode));
    }

    yield* OllamaStreamParser.parseChatChunks(response.stream);
  }

  Stream<String> streamChatTokens({
    required ServerProfile server,
    required String model,
    required List<ChatMessage> messages,
    GenerationOptions options = const GenerationOptions(),
  }) {
    return streamChat(
          server: server,
          model: model,
          messages: messages,
          options: options,
        )
        .where((chunk) => chunk.kind == OllamaChatChunkKind.content)
        .map((chunk) => chunk.text);
  }

  Future<T> _guardHttp<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on TimeoutException catch (error) {
      throw OllamaApiException(const TimeoutFailure(), error);
    } on SocketException catch (error) {
      throw OllamaApiException(const NetworkFailure(), error);
    } on HandshakeException catch (error) {
      throw OllamaApiException(const CleartextBlockedFailure(), error);
    } on http.ClientException catch (error) {
      throw OllamaApiException(const NetworkFailure(), error);
    }
  }

  AppFailure _failureForStatus(int statusCode) {
    if (statusCode == 404) {
      return const OllamaApiFailure(
        'Servidor respondeu, mas nao parece ser uma API Ollama valida.',
      );
    }
    if (statusCode == 400 || statusCode == 404) {
      return const OllamaApiFailure(
        'Modelo nao encontrado no servidor. Escolha outro modelo ou instale no Ollama.',
      );
    }
    return OllamaApiFailure('Ollama retornou HTTP $statusCode.');
  }
}
