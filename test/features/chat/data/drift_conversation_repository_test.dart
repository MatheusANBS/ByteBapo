import 'package:byte_papo/core/database/app_database.dart'
    hide ChatMessage, Conversation;
import 'package:byte_papo/features/chat/data/repositories/drift_conversation_repository.dart';
import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';
import 'package:byte_papo/features/chat/domain/entities/conversation.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftConversationRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftConversationRepository(database: database);
  });

  tearDown(() => database.close());

  test('stores conversations ordered by most recently updated', () async {
    final older = _conversation(id: 'older', updatedAt: DateTime.utc(2026, 1));
    final newer = _conversation(id: 'newer', updatedAt: DateTime.utc(2026, 2));

    await repository.saveConversation(newer);
    await repository.saveConversation(older);

    final conversations = await repository.listConversations();

    expect(conversations.map((conversation) => conversation.id), [
      'newer',
      'older',
    ]);
    expect(conversations.first.serverNameSnapshot, 'Servidor local');
    expect(conversations.first.providerSnapshot, 'ollama');
    expect(conversations.first.characterNameSnapshot, 'Ada');
  });

  test(
    'searches conversations by snapshots, model and message content',
    () async {
      final titleMatch = _conversation(
        id: 'title',
        title: 'Planejamento da viagem',
        updatedAt: DateTime.utc(2026, 1),
      );
      final modelMatch = _conversation(
        id: 'model',
        model: 'nvidia/nemotron',
        updatedAt: DateTime.utc(2026, 2),
      );
      final serverMatch = _conversation(
        id: 'server',
        serverNameSnapshot: 'NVIDIA Cloud',
        updatedAt: DateTime.utc(2026, 3),
      );
      final characterMatch = _conversation(
        id: 'character',
        characterNameSnapshot: 'Grace Hopper',
        updatedAt: DateTime.utc(2026, 4),
      );
      final contentMatch = _conversation(
        id: 'content',
        updatedAt: DateTime.utc(2026, 5),
      );

      for (final conversation in [
        titleMatch,
        modelMatch,
        serverMatch,
        characterMatch,
        contentMatch,
      ]) {
        await repository.saveConversation(conversation);
      }
      await repository.saveMessage(
        _message(
          conversationId: contentMatch.id,
          content: 'A resposta menciona criptografia assimétrica.',
        ),
      );

      expect(
        (await repository.listConversationsPage(
          query: 'viagem',
        )).map((conversation) => conversation.id),
        ['title'],
      );
      expect(
        (await repository.listConversationsPage(
          query: 'nemotron',
        )).map((conversation) => conversation.id),
        ['model'],
      );
      expect(
        (await repository.listConversationsPage(
          query: 'cloud',
        )).map((conversation) => conversation.id),
        ['server'],
      );
      expect(
        (await repository.listConversationsPage(
          query: 'hopper',
        )).map((conversation) => conversation.id),
        ['character'],
      );
      expect(
        (await repository.listConversationsPage(
          query: 'criptografia',
        )).map((conversation) => conversation.id),
        ['content'],
      );
    },
  );

  test('paginates matching conversations by most recently updated', () async {
    for (var index = 1; index <= 3; index++) {
      await repository.saveConversation(
        _conversation(
          id: 'conversation-$index',
          title: 'Consulta $index',
          updatedAt: DateTime.utc(2026, 1, index),
        ),
      );
    }

    final page = await repository.listConversationsPage(
      query: 'consulta',
      limit: 1,
      offset: 1,
    );

    expect(page.map((conversation) => conversation.id), ['conversation-2']);
  });

  test('upserts conversations and messages preserving tool calls', () async {
    final conversation = _conversation();
    final updatedConversation = Conversation(
      id: conversation.id,
      title: 'Título atualizado',
      serverProfileId: null,
      model: conversation.model,
      createdAt: conversation.createdAt,
      updatedAt: DateTime.utc(2026, 3),
    );
    final message = _message();

    await repository.saveConversation(conversation);
    await repository.saveConversation(updatedConversation);
    await repository.saveMessage(message);
    await repository.saveMessage(
      ChatMessage(
        id: message.id,
        conversationId: message.conversationId,
        role: message.role,
        content: 'Resposta atualizada',
        createdAt: message.createdAt,
        updatedAt: DateTime.utc(2026, 3),
        toolCalls: message.toolCalls,
      ),
    );

    expect(
      (await repository.listConversations()).single.title,
      'Título atualizado',
    );
    final messages = await repository.listMessages(conversation.id);
    expect(messages.single.content, 'Resposta atualizada');
    expect(messages.single.toolCalls, hasLength(1));
    expect(messages.single.toolCalls!.single.name, 'weather');
  });

  test(
    'lists messages chronologically and deletes conversation messages by cascade',
    () async {
      final conversation = _conversation();
      await repository.saveConversation(conversation);
      await repository.saveMessage(
        _message(id: 'later', createdAt: DateTime.utc(2026, 2)),
      );
      await repository.saveMessage(
        _message(id: 'earlier', createdAt: DateTime.utc(2026, 1)),
      );

      expect(
        (await repository.listMessages(
          conversation.id,
        )).map((message) => message.id),
        ['earlier', 'later'],
      );

      await repository.removeConversation(conversation.id);

      expect(await repository.listConversations(), isEmpty);
      expect(await repository.listMessages(conversation.id), isEmpty);
    },
  );

  test('removes only messages from the requested conversation', () async {
    final first = _conversation(id: 'first');
    final second = _conversation(id: 'second');
    await repository.saveConversation(first);
    await repository.saveConversation(second);
    await repository.saveMessage(_message(conversationId: first.id));
    await repository.saveMessage(
      _message(id: 'second-message', conversationId: second.id),
    );

    await repository.removeMessages(first.id);

    expect(await repository.listMessages(first.id), isEmpty);
    expect(
      (await repository.listMessages(second.id)).single.id,
      'second-message',
    );
  });
}

Conversation _conversation({
  String id = 'conversation-1',
  String title = 'Conversa',
  String model = 'qwen3',
  String? serverNameSnapshot = 'Servidor local',
  String? characterNameSnapshot = 'Ada',
  DateTime? updatedAt,
}) {
  final createdAt = DateTime.utc(2026, 1, 1);
  return Conversation(
    id: id,
    title: title,
    serverProfileId: null,
    serverNameSnapshot: serverNameSnapshot,
    providerSnapshot: 'ollama',
    characterNameSnapshot: characterNameSnapshot,
    model: model,
    createdAt: createdAt,
    updatedAt: updatedAt ?? createdAt,
  );
}

ChatMessage _message({
  String id = 'message-1',
  String conversationId = 'conversation-1',
  String content = 'Resposta',
  DateTime? createdAt,
}) {
  final timestamp = createdAt ?? DateTime.utc(2026, 1, 1);
  return ChatMessage(
    id: id,
    conversationId: conversationId,
    role: ChatRole.assistant,
    content: content,
    createdAt: timestamp,
    updatedAt: timestamp,
    toolCalls: const [
      ToolCall(
        id: 'call-1',
        name: 'weather',
        arguments: '{"city":"São Paulo"}',
      ),
    ],
  );
}
