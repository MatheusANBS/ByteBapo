import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';
import 'package:byte_papo/features/chat/domain/entities/conversation.dart';
import 'package:byte_papo/features/chat/domain/entities/generation_options.dart';
import 'package:byte_papo/features/chat/domain/repositories/conversation_repository.dart';
import 'package:byte_papo/features/providers/domain/entities/available_model.dart';
import 'package:byte_papo/features/providers/domain/chat_completion_gateway.dart';
import 'package:byte_papo/features/providers/domain/model_catalog_gateway.dart';
import 'package:byte_papo/features/providers/domain/provider_gateway_resolver.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:byte_papo/shared/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sending a message refreshes the paged conversation history', () async {
    final repository = _MemoryConversationRepository();
    final server = ServerProfile.create(
      id: 'server-1',
      name: 'Local',
      input: 'http://127.0.0.1:11434',
    );
    final container = ProviderContainer(
      overrides: [
        conversationRepositoryProvider.overrideWithValue(repository),
        activeServerProvider.overrideWithValue(AsyncValue.data(server)),
        selectedModelProvider.overrideWithValue(
          const AsyncValue.data('qwen3:latest'),
        ),
        providerGatewayResolverProvider.overrideWithValue(
          ProviderGatewayResolver(
            ollama: ProviderGatewayBundle(
              _UnusedCatalogGateway(),
              _ChatGateway(),
            ),
            nvidia: ProviderGatewayBundle(
              _UnusedCatalogGateway(),
              _ChatGateway(),
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    const page = ConversationHistoryPage();

    expect(
      await container.read(conversationHistoryPageProvider(page).future),
      isEmpty,
    );

    final controller = container.read(chatControllerProvider(null))!;
    await controller.send('Oi');
    await Future<void>.delayed(Duration.zero);

    expect(
      (await container.read(
        conversationHistoryPageProvider(page).future,
      )).map((conversation) => conversation.title),
      ['Oi'],
    );
  });
}

class _MemoryConversationRepository implements ConversationRepository {
  final conversations = <String, Conversation>{};
  final messages = <ChatMessage>[];

  @override
  Future<List<Conversation>> listConversations() async {
    return conversations.values.toList()
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
  }

  @override
  Future<List<Conversation>> listConversationsPage({
    String? query,
    int limit = 50,
    int offset = 0,
  }) async {
    final items = await listConversations();
    return items.skip(offset).take(limit).toList(growable: false);
  }

  @override
  Future<void> saveConversation(Conversation conversation) async {
    conversations[conversation.id] = conversation;
  }

  @override
  Future<void> removeConversation(String id) async {
    conversations.remove(id);
  }

  @override
  Future<List<ChatMessage>> listMessages(String conversationId) async {
    return [
      for (final message in messages)
        if (message.conversationId == conversationId) message,
    ];
  }

  @override
  Future<void> saveMessage(ChatMessage message) async {
    messages.removeWhere((item) => item.id == message.id);
    messages.add(message);
  }

  @override
  Future<void> removeMessage(String messageId) async {
    messages.removeWhere((message) => message.id == messageId);
  }

  @override
  Future<void> removeMessages(String conversationId) async {
    messages.removeWhere((message) => message.conversationId == conversationId);
  }
}

class _ChatGateway implements ChatCompletionGateway {
  @override
  Stream<ChatChunk> streamChat({
    required ServerProfile server,
    required String model,
    required List<ChatMessage> messages,
    GenerationOptions options = const GenerationOptions(),
  }) {
    return Stream.value(
      const ChatChunk(kind: ChatChunkKind.content, text: 'Ola!'),
    );
  }
}

class _UnusedCatalogGateway implements ModelCatalogGateway {
  @override
  Future<List<AvailableModel>> listModels(ServerProfile server) {
    throw UnimplementedError();
  }
}
