import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:byte_papo/core/network/api_client.dart';
import 'package:byte_papo/features/chat/data/repositories/conversation_repository_impl.dart';
import 'package:byte_papo/features/chat/presentation/chat_controller.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('send notifies listeners that conversation history changed', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    var historyChangedCount = 0;
    final controller = ChatController(
      apiClient: ApiClient(
        httpClient: MockClient.streaming((request, bodyStream) async {
          return http.StreamedResponse(
            Stream.fromIterable([
              utf8.encode(
                '{"message":{"content":"Ola!"},"done":false}\n{"done":true}\n',
              ),
            ]),
            200,
          );
        }),
      ),
      conversationRepository: ConversationRepositoryImpl(
        preferences: preferences,
      ),
      server: ServerProfile.create(
        id: 'server-1',
        name: 'Local',
        input: 'http://127.0.0.1:11434',
      ),
      model: 'qwen3:latest',
      onConversationChanged: () => historyChangedCount += 1,
    );

    await controller.send('Oi');
    await Future<void>.delayed(Duration.zero);

    expect(historyChangedCount, greaterThan(0));
  });
}
