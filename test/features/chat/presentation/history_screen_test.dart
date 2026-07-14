import 'package:byte_papo/features/chat/domain/entities/chat_character.dart';
import 'package:byte_papo/features/chat/domain/entities/chat_message.dart';
import 'package:byte_papo/features/chat/domain/entities/conversation.dart';
import 'package:byte_papo/features/chat/domain/repositories/conversation_repository.dart';
import 'package:byte_papo/features/chat/presentation/history_screen.dart';
import 'package:byte_papo/features/chat/presentation/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('searches conversation history using ten-item pages', (
    tester,
  ) async {
    final repository = _HistoryRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationRepositoryProvider.overrideWithValue(repository),
          charactersProvider.overrideWith((ref) async => <ChatCharacter>[]),
        ],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.requests, contains((query: null, limit: 10, offset: 0)));
    expect(find.text('Primeira conversa'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'segunda');
    await tester.pumpAndSettle();

    expect(
      repository.requests,
      contains((query: 'segunda', limit: 10, offset: 0)),
    );
    expect(find.text('Segunda conversa'), findsOneWidget);
    expect(find.text('Primeira conversa'), findsNothing);
  });

  testWidgets('asks for confirmation before deleting a conversation', (
    tester,
  ) async {
    final repository = _HistoryRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationRepositoryProvider.overrideWithValue(repository),
          charactersProvider.overrideWith((ref) async => <ChatCharacter>[]),
        ],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Acoes').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Excluir conversa?'), findsOneWidget);
    expect(repository.deletedIds, isEmpty);

    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(repository.deletedIds, ['first']);
  });
}

class _HistoryRepository implements ConversationRepository {
  final requests = <({String? query, int limit, int offset})>[];
  final deletedIds = <String>[];

  @override
  Future<List<Conversation>> listConversations() => listConversationsPage();

  @override
  Future<List<Conversation>> listConversationsPage({
    String? query,
    int limit = 50,
    int offset = 0,
  }) async {
    requests.add((query: query, limit: limit, offset: offset));
    final items = [
      _conversation('first', 'Primeira conversa'),
      _conversation('second', 'Segunda conversa'),
    ];
    return query == 'segunda' ? [items.last] : items;
  }

  @override
  Future<void> removeConversation(String id) async => deletedIds.add(id);

  @override
  Future<List<ChatMessage>> listMessages(String conversationId) async => [];

  @override
  Future<void> removeMessages(String conversationId) async {}

  @override
  Future<void> saveConversation(Conversation conversation) async {}

  @override
  Future<void> saveMessage(ChatMessage message) async {}

  @override
  Future<void> removeMessage(String messageId) async {}
}

Conversation _conversation(String id, String title) => Conversation(
  id: id,
  title: title,
  serverProfileId: 'server',
  model: 'model',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);
