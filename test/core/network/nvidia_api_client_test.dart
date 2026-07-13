import 'dart:convert';

import 'package:byte_papo/core/errors/app_exception.dart';
import 'package:byte_papo/core/network/api_client.dart';
import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';
import 'package:byte_papo/features/models/domain/entities/nvidia_model.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('lists NVIDIA models from v1 with bearer authentication', () async {
    late http.Request capturedRequest;
    final client = ApiClient(
      httpClient: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 'meta/llama-3.3-70b-instruct',
                'object': 'model',
                'created': 1,
                'owned_by': 'meta',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final models = await client.listNvidiaModels(_nvidiaServer());

    expect(capturedRequest.method, 'GET');
    expect(
      capturedRequest.url.toString(),
      'https://integrate.api.nvidia.com/v1/models',
    );
    expect(capturedRequest.headers['Authorization'], 'Bearer nvapi-test');
    expect(models, const [
      NvidiaModel(
        id: 'meta/llama-3.3-70b-instruct',
        object: 'model',
        created: 1,
        ownedBy: 'meta',
      ),
    ]);
  });

  test('streams NVIDIA chat from v1 using the selected model', () async {
    late http.Request capturedRequest;
    final client = ApiClient(
      httpClient: MockClient.streaming((request, bodyStream) async {
        capturedRequest = request as http.Request;
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode(
              'data: {"choices":[{"delta":{"content":"Olá"},"finish_reason":null}]}\n\n',
            ),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      }),
    );

    final tokens = await client
        .streamChatTokens(
          server: _nvidiaServer(),
          model: 'meta/llama-3.3-70b-instruct',
          messages: [_userMessage()],
        )
        .toList();
    final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;

    expect(capturedRequest.method, 'POST');
    expect(
      capturedRequest.url.toString(),
      'https://integrate.api.nvidia.com/v1/chat/completions',
    );
    expect(capturedRequest.headers['Authorization'], 'Bearer nvapi-test');
    expect(capturedRequest.headers['Accept'], 'text/event-stream');
    expect(body['model'], 'meta/llama-3.3-70b-instruct');
    expect(body['stream'], isTrue);
    expect(tokens, ['Olá']);
  });

  test('wraps NVIDIA transport failures as NvidiaApiException', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        throw http.ClientException('connection failed', request.url);
      }),
    );

    await expectLater(
      client.listNvidiaModels(_nvidiaServer()),
      throwsA(
        isA<NvidiaApiException>().having(
          (error) => error.message,
          'message',
          contains('NVIDIA'),
        ),
      ),
    );
  });

  test('reports NVIDIA authentication failures for HTTP 401', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async => http.Response('', 401)),
    );

    await expectLater(
      client.listNvidiaModels(_nvidiaServer()),
      throwsA(
        isA<NvidiaApiException>().having(
          (error) => error.message,
          'message',
          contains('API key'),
        ),
      ),
    );
  });

  test('reports missing NVIDIA endpoints for HTTP 404', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async => http.Response('', 404)),
    );

    await expectLater(
      client.listNvidiaModels(_nvidiaServer()),
      throwsA(
        isA<NvidiaApiException>().having(
          (error) => error.message,
          'message',
          contains('endpoint'),
        ),
      ),
    );
  });
}

ServerProfile _nvidiaServer() {
  return ServerProfile.create(
    id: 'nvidia-1',
    name: 'NVIDIA',
    input: 'https://integrate.api.nvidia.com:443',
    provider: ApiProvider.nvidia,
    apiKey: 'nvapi-test',
  );
}

ChatMessage _userMessage() {
  final now = DateTime.utc(2026, 7, 13);
  return ChatMessage(
    id: 'message-1',
    conversationId: 'conversation-1',
    role: ChatRole.user,
    content: 'Olá',
    createdAt: now,
    updatedAt: now,
  );
}
