import 'package:flutter_test/flutter_test.dart';
import 'package:byte_papo/core/database/app_database.dart'
    hide ChatMessage, Conversation, ServerProfile;
import 'package:byte_papo/features/chat/data/repositories/drift_conversation_repository.dart';
import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';
import 'package:byte_papo/features/chat/domain/entities/generation_options.dart';
import 'package:byte_papo/features/chat/presentation/chat_controller.dart';
import 'package:byte_papo/features/providers/domain/chat_completion_gateway.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:drift/native.dart';

void main() {
  test('send notifies listeners that conversation history changed', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await _seedServer(database);
    var historyChangedCount = 0;
    final controller = ChatController(
      chatGateway: _ChatGateway(),
      conversationRepository: DriftConversationRepository(database: database),
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
    expect(controller.conversation!.serverNameSnapshot, 'Local');
    expect(controller.conversation!.providerSnapshot, 'ollama');
  });

  test('send persists tool calls emitted by the provider gateway', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await _seedServer(database);
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
      conversationRepository: DriftConversationRepository(database: database),
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

Future<void> _seedServer(AppDatabase database) {
  final now = DateTime.utc(2026);
  return database
      .into(database.serverProfiles)
      .insert(
        ServerProfilesCompanion.insert(
          id: 'server-1',
          name: 'Local',
          provider: 'ollama',
          protocol: 'http',
          host: '127.0.0.1',
          port: 11434,
          createdAt: now,
          updatedAt: now,
        ),
      );
}
