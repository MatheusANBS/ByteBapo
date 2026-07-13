import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/errors/app_exception.dart';
import '../../../chat/domain/entities/chat_message.dart';
import '../../../chat/domain/entities/generation_options.dart';
import '../../../servers/domain/entities/server_profile.dart';
import '../../domain/chat_completion_gateway.dart';
import 'ollama_ndjson_parser.dart';

class OllamaChatCompletionGateway implements ChatCompletionGateway {
  OllamaChatCompletionGateway({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  @override
  Stream<ChatChunk> streamChat({
    required ServerProfile server,
    required String model,
    required List<ChatMessage> messages,
    GenerationOptions options = const GenerationOptions(),
  }) async* {
    final request = http.Request('POST', server.resolve('api/chat'))
      ..headers.addAll(server.headers)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'model': model,
        'messages': messages.map(_ollamaMessageJson).toList(),
        'stream': options.stream,
        if (options.thinking != ThinkingMode.modelDefault)
          'think': options.thinking.ollamaValue,
        if (options.toOllamaOptionsJson().isNotEmpty)
          'options': options.toOllamaOptionsJson(),
      });
    final http.StreamedResponse response;
    try {
      response = await _httpClient.send(request);
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
        OllamaApiFailure(_ollamaChatHttpMessage(response.statusCode)),
      );
    }
    yield* OllamaNdjsonParser.parse(response.stream);
  }
}

Map<String, String> _ollamaMessageJson(ChatMessage message) => {
  'role': message.role.name,
  'content': message.content,
};

String _ollamaChatHttpMessage(int statusCode) {
  if (statusCode == 404) {
    return 'O endpoint ou modelo Ollama nao foi encontrado.';
  }
  if (statusCode >= 500) {
    return 'O servidor Ollama esta indisponivel no momento.';
  }
  return 'O servidor Ollama retornou uma resposta inesperada.';
}
