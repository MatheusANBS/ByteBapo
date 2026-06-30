import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ollama_mobile_client/core/network/ollama_api_client.dart';
import 'package:ollama_mobile_client/core/network/ollama_stream_parser.dart';
import 'package:ollama_mobile_client/features/chat/domain/entities/chat_message.dart';
import 'package:ollama_mobile_client/features/chat/domain/entities/generation_options.dart';
import 'package:ollama_mobile_client/features/servers/domain/entities/server_profile.dart';

void main() {
  test('streamChat sends think and streams thinking before content', () async {
    late Map<String, dynamic> requestBody;
    final client = OllamaApiClient(
      httpClient: MockClient.streaming((request, bodyStream) async {
        requestBody =
            jsonDecode((request as http.Request).body) as Map<String, dynamic>;
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode('{"message":{"thinking":"Pensando"},"done":false}\n'),
            utf8.encode('{"message":{"content":"Resposta"},"done":false}\n'),
            utf8.encode('{"done":true}\n'),
          ]),
          200,
        );
      }),
    );

    final chunks = await client
        .streamChat(
          server: _server(),
          model: 'qwen3',
          messages: [_userMessage()],
          options: const GenerationOptions(
            stream: true,
            thinking: ThinkingMode.high,
          ),
        )
        .toList();

    expect(requestBody['think'], 'high');
    expect(chunks[0].kind, OllamaChatChunkKind.thinking);
    expect(chunks[0].text, 'Pensando');
    expect(chunks[1].kind, OllamaChatChunkKind.content);
    expect(chunks[1].text, 'Resposta');
  });

  test(
    'streamChat does not time out while waiting for cold model start',
    () async {
      final client = OllamaApiClient(
        timeout: const Duration(milliseconds: 1),
        httpClient: MockClient.streaming((request, bodyStream) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return http.StreamedResponse(
            Stream.fromIterable([
              utf8.encode('{"message":{"content":"Acordei"},"done":false}\n'),
              utf8.encode('{"done":true}\n'),
            ]),
            200,
          );
        }),
      );

      final chunks = await client
          .streamChat(
            server: _server(),
            model: 'qwen3',
            messages: [_userMessage()],
          )
          .toList();

      expect(chunks.single.text, 'Acordei');
    },
  );
}

ServerProfile _server() {
  return ServerProfile.create(
    id: 'server-1',
    name: 'Local',
    input: 'http://127.0.0.1:11434',
  );
}

ChatMessage _userMessage() {
  final now = DateTime.utc(2026);
  return ChatMessage(
    id: 'message-1',
    conversationId: 'conversation-1',
    role: ChatRole.user,
    content: 'Oi',
    createdAt: now,
    updatedAt: now,
  );
}
