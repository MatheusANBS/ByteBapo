import 'package:flutter_test/flutter_test.dart';
import 'package:byte_papo/features/chat/data/repositories/conversation_repository_impl.dart';
import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';
import 'package:byte_papo/features/chat/domain/entities/generation_options.dart';
import 'package:byte_papo/features/chat/presentation/chat_controller.dart';
import 'package:byte_papo/features/providers/domain/chat_completion_gateway.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('send notifies listeners that conversation history changed', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    var historyChangedCount = 0;
    final controller = ChatController(
      chatGateway: _ChatGateway(),
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

  test('send persists tool calls emitted by the provider gateway', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = ChatController(
      chatGateway: _ChatGateway(
        chunks: const [
          ChatChunk(
            kind: ChatChunkKind.toolCall,
            text: '',
            toolCall: ToolCallDelta(
              index: 0,
              id: 'call-1',
              name: 'weather',
              arguments: '{"city":"Sao Paulo"}',
            ),
          ),
        ],
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
    );

    await controller.send('Como esta o tempo?');
    await Future<void>.delayed(Duration.zero);

    final toolCalls = controller.messages.last.toolCalls;
    expect(toolCalls, hasLength(1));
    expect(toolCalls!.single.name, 'weather');
    expect(toolCalls.single.arguments, '{"city":"Sao Paulo"}');
  });
}

class _ChatGateway implements ChatCompletionGateway {
  _ChatGateway({
    this.chunks = const [ChatChunk(kind: ChatChunkKind.content, text: 'Ola!')],
  });

  final List<ChatChunk> chunks;

  @override
  Stream<ChatChunk> streamChat({
    required ServerProfile server,
    required String model,
    required List<ChatMessage> messages,
    GenerationOptions options = const GenerationOptions(),
  }) => Stream.fromIterable(chunks);
}
