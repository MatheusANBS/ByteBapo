import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  const ConversationRepositoryImpl({required this.preferences});

  static const _conversationsKey = 'chat.conversations.v1';
  static const _messagesKey = 'chat.messages.v1';

  final SharedPreferences preferences;

  @override
  Future<List<Conversation>> listConversations() async {
    final raw = preferences.getStringList(_conversationsKey) ?? const [];
    final conversations = raw
        .map(
          (item) =>
              Conversation.fromJson(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList();
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return conversations;
  }

  @override
  Future<void> saveConversation(Conversation conversation) async {
    final conversations = await listConversations();
    final index = conversations.indexWhere(
      (item) => item.id == conversation.id,
    );
    final next = [...conversations];
    if (index == -1) {
      next.add(conversation);
    } else {
      next[index] = conversation;
    }
    await preferences.setStringList(
      _conversationsKey,
      next.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  @override
  Future<void> removeConversation(String id) async {
    final conversations = await listConversations();
    await preferences.setStringList(
      _conversationsKey,
      conversations
          .where((conversation) => conversation.id != id)
          .map((item) => jsonEncode(item.toJson()))
          .toList(),
    );
    await removeMessages(id);
  }

  @override
  Future<List<ChatMessage>> listMessages(String conversationId) async {
    final allMessages = await _readAllMessages();
    final messages = allMessages
        .where((message) => message.conversationId == conversationId)
        .toList();
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }

  @override
  Future<void> saveMessage(ChatMessage message) async {
    final messages = await _readAllMessages();
    final index = messages.indexWhere((item) => item.id == message.id);
    final next = [...messages];
    if (index == -1) {
      next.add(message);
    } else {
      next[index] = message;
    }
    await _writeAllMessages(next);
  }

  @override
  Future<void> removeMessages(String conversationId) async {
    final messages = await _readAllMessages();
    await _writeAllMessages(
      messages
          .where((message) => message.conversationId != conversationId)
          .toList(growable: false),
    );
  }

  Future<List<ChatMessage>> _readAllMessages() async {
    final raw = preferences.getStringList(_messagesKey) ?? const [];
    return raw
        .map(
          (item) =>
              ChatMessage.fromJson(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> _writeAllMessages(List<ChatMessage> messages) async {
    await preferences.setStringList(
      _messagesKey,
      messages.map((message) => jsonEncode(message.toJson())).toList(),
    );
  }
}
