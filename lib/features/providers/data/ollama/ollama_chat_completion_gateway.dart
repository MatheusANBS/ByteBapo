import 'dart:convert';

import 'package:http/http.dart' as http;

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
        'messages': messages.map((message) => message.toOllamaJson()).toList(),
        'stream': options.stream,
        if (options.thinking != ThinkingMode.modelDefault)
          'think': options.thinking.ollamaValue,
        if (options.toOllamaOptionsJson().isNotEmpty)
          'options': options.toOllamaOptionsJson(),
      });
    final response = await _httpClient.send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Ollama chat returned HTTP ${response.statusCode}.');
    }
    yield* OllamaNdjsonParser.parse(response.stream);
  }
}
