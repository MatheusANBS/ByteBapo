import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../chat/domain/entities/chat_message.dart';
import '../../../chat/domain/entities/generation_options.dart';
import '../../../servers/domain/entities/server_profile.dart';
import '../../domain/chat_completion_gateway.dart';
import 'nvidia_sse_parser.dart';

class NvidiaChatCompletionGateway implements ChatCompletionGateway {
  NvidiaChatCompletionGateway({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  @override
  Stream<ChatChunk> streamChat({
    required ServerProfile server,
    required String model,
    required List<ChatMessage> messages,
    GenerationOptions options = const GenerationOptions(),
  }) async* {
    final request = http.Request('POST', server.resolve('chat/completions'))
      ..headers.addAll(server.headers)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'text/event-stream'
      ..body = jsonEncode({
        'model': model,
        'messages': messages.map((message) => message.toOpenAIJson()).toList(),
        'stream': options.stream,
        if (options.temperature != null) 'temperature': options.temperature,
        if (options.topP != null) 'top_p': options.topP,
        if (options.maxTokens != null) 'max_tokens': options.maxTokens,
        if (options.stopSequences?.isNotEmpty ?? false)
          'stop': options.stopSequences,
        if (options.seed != null) 'seed': options.seed,
      });
    final response = await _httpClient.send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('NVIDIA chat returned HTTP ${response.statusCode}.');
    }
    yield* NvidiaSseParser.parse(response.stream);
  }
}
