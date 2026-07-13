import 'dart:convert';

import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';
import 'package:byte_papo/features/chat/domain/entities/generation_options.dart';
import 'package:byte_papo/features/providers/data/ollama/ollama_chat_completion_gateway.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('sends Ollama options and parses NDJSON chat chunks', () async {
    http.BaseRequest? captured;
    final gateway = OllamaChatCompletionGateway(
      httpClient: _StreamClient((request) {
        captured = request;
        return '{"message":{"thinking":"pensando"},"done":false}\n'
            '{"message":{"content":"Oi"},"done":false}\n'
            '{"done":true}\n';
      }),
    );

    final chunks = await gateway
        .streamChat(
          server: _server(),
          model: 'llama3.2',
          messages: [_message()],
          options: const GenerationOptions(
            numCtx: 4096,
            thinking: ThinkingMode.enabled,
          ),
        )
        .toList();

    expect(captured!.url.path, '/api/chat');
    final body =
        jsonDecode((captured! as http.Request).body) as Map<String, dynamic>;
    expect(body['think'], true);
    expect(body['options'], {'num_ctx': 4096});
    expect(body.containsKey('max_tokens'), isFalse);
    expect(chunks.map((chunk) => chunk.text), ['pensando', 'Oi']);
  });
}

class _StreamClient extends http.BaseClient {
  _StreamClient(this.response);
  final String Function(http.BaseRequest request) response;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(
        Stream.value(utf8.encode(response(request))),
        200,
        headers: const {'content-type': 'application/x-ndjson'},
      );
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
ChatMessage _message() => ChatMessage(
  id: 'message',
  conversationId: 'conversation',
  role: ChatRole.user,
  content: 'Olá',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);
