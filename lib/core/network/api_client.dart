import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../features/chat/domain/entities/chat_message.dart';
import '../../features/chat/domain/entities/generation_options.dart';
import '../../features/models/domain/entities/nvidia_model.dart';
import '../../features/models/domain/entities/ollama_model.dart';
import '../../features/servers/domain/entities/server_profile.dart';
import '../errors/app_exception.dart';
import 'nvidia_endpoints.dart';
import 'ollama_endpoints.dart';
import 'stream_parser.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, Duration? timeout})
    : _httpClient = httpClient ?? http.Client(),
      _timeout = timeout ?? const Duration(seconds: 60);

  final http.Client _httpClient;
  final Duration _timeout;

  Future<List<OllamaModel>> listOllamaModels(ServerProfile server) async {
    final response = await _guardHttp(
      () => _httpClient
          .get(server.resolve(OllamaEndpoints.tags), headers: server.headers)
          .timeout(_timeout),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OllamaApiException(_ollamaFailureForStatus(response.statusCode));
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

  Future<List<NvidiaModel>> listNvidiaModels(ServerProfile server) async {
    final response = await _guardHttp(
      () => _httpClient
          .get(server.resolve(NvidiaEndpoints.models), headers: server.headers)
          .timeout(_timeout),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NvidiaApiException(_nvidiaFailureForStatus(response.statusCode));
    }

    try {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final data = payload['data'];
      if (data is! List) {
        return const [];
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(NvidiaModel.fromJson)
          .toList(growable: false);
    } on FormatException catch (error) {
      throw NvidiaApiException(const NvidiaApiFailure(), error);
    } on TypeError catch (error) {
      throw NvidiaApiException(const NvidiaApiFailure(), error);
    }
  }

  Stream<ChatChunk> streamChat({
    required ServerProfile server,
    required String model,
    required List<ChatMessage> messages,
    GenerationOptions options = const GenerationOptions(),
  }) async* {
    if (server.provider == ApiProvider.nvidia) {
      yield* _streamNvidiaChat(
        server: server,
        model: model,
        messages: messages,
        options: options,
      );
    } else {
      yield* _streamOllamaChat(
        server: server,
        model: model,
        messages: messages,
        options: options,
      );
    }
  }

  Stream<ChatChunk> _streamOllamaChat({
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
      throw OllamaApiException(_ollamaFailureForStatus(response.statusCode));
    }

    yield* StreamParser.parseChunks(response.stream);
  }

  Stream<ChatChunk> _streamNvidiaChat({
    required ServerProfile server,
    required String model,
    required List<ChatMessage> messages,
    GenerationOptions options = const GenerationOptions(),
  }) async* {
    final request = http.Request('POST', server.resolve(NvidiaEndpoints.chat));
    request.headers.addAll(server.headers);
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'text/event-stream';
    request.body = jsonEncode({
      'model': model,
      'messages': messages
          .map((message) => message.toOpenAIJson())
          .toList(),
      'stream': options.stream,
      'temperature': options.temperature,
      'top_p': options.topP,
      'max_tokens': options.maxTokens,
      if (options.stopSequences.isNotEmpty) 'stop': options.stopSequences,
      if (options.seed != null) 'seed': options.seed,
    });

    final response = await _guardHttp(() => _httpClient.send(request));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NvidiaApiException(_nvidiaFailureForStatus(response.statusCode));
    }

    yield* StreamParser.parseChunks(response.stream);
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
        .where((chunk) => chunk.kind == ChatChunkKind.content)
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

  AppFailure _ollamaFailureForStatus(int statusCode) {
    if (statusCode == 404) {
      return const OllamaApiFailure(
        'Servidor respondeu, mas não parece ser uma API Ollama válida.',
      );
    }
    if (statusCode == 400 || statusCode == 404) {
      return const OllamaApiFailure(
        'Modelo não encontrado no servidor. Escolha outro modelo ou instale no Ollama.',
      );
    }
    return OllamaApiFailure('Ollama retornou HTTP $statusCode.');
  }

  AppFailure _nvidiaFailureForStatus(int statusCode) {
    if (statusCode == 401) {
      return const NvidiaApiFailure(
        'API key inválida ou ausente. Verifique sua NVIDIA_API_KEY.',
      );
    }
    if (statusCode == 403) {
      return const NvidiaApiFailure(
        'Acesso negado. Verifique se sua API key tem permissão para este modelo.',
      );
    }
    if (statusCode == 404) {
      return const NvidiaApiFailure(
        'Modelo ou endpoint não encontrado. Verifique o model ID e a URL base.',
      );
    }
    if (statusCode == 429) {
      return const NvidiaApiFailure(
        'Limite de taxa excedido. Aguarde e tente novamente.',
      );
    }
    if (statusCode == 422) {
      return const NvidiaApiFailure(
        'Parâmetros inválidos. Verifique o modelo e as opções enviadas.',
      );
    }
    if (statusCode >= 500) {
      return const NvidiaApiFailure(
        'Erro interno do servidor NVIDIA. Tente novamente mais tarde.',
      );
    }
    return NvidiaApiFailure('NVIDIA API retornou HTTP $statusCode.');
  }
}