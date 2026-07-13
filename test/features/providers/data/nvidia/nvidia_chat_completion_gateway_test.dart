import 'dart:convert';

import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';
import 'package:byte_papo/features/chat/domain/entities/generation_options.dart';
import 'package:byte_papo/features/providers/data/nvidia/nvidia_chat_completion_gateway.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test(
    'sends OpenAI payload to NVIDIA chat completions and parses SSE',
    () async {
      http.BaseRequest? captured;
      final gateway = NvidiaChatCompletionGateway(
        httpClient: _StreamClient((request) {
          captured = request;
          return 'data: {"choices":[{"delta":{"content":"Oi"}}]}\n\n'
              'data: [DONE]\n\n';
        }),
      );

      final chunks = await gateway
          .streamChat(
            server: _server(),
            model: 'meta/llama-3.1-8b-instruct',
            messages: [_message()],
            options: const GenerationOptions(temperature: 0.3, stream: true),
          )
          .toList();

      expect(captured!.url.path, '/v1/chat/completions');
      expect(captured!.headers['Accept'], 'text/event-stream');
      final body =
          jsonDecode((captured! as http.Request).body) as Map<String, dynamic>;
      expect(body['model'], 'meta/llama-3.1-8b-instruct');
      expect(body['messages'], [
        {'role': 'user', 'content': 'Olá'},
      ]);
      expect(body['temperature'], 0.3);
      expect(body.containsKey('num_ctx'), isFalse);
      expect(chunks.single.text, 'Oi');
    },
  );
}

class _StreamClient extends http.BaseClient {
  _StreamClient(this.response);

  final String Function(http.BaseRequest request) response;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.value(utf8.encode(response(request))),
      200,
      headers: const {'content-type': 'text/event-stream'},
    );
  }
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

ChatMessage _message() => ChatMessage(
  id: 'message',
  conversationId: 'conversation',
  role: ChatRole.user,
  content: 'Olá',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);
