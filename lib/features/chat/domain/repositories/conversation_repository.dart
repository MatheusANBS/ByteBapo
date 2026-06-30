import '../entities/chat_message.dart';
import '../entities/conversation.dart';

abstract class ConversationRepository {
  Future<List<Conversation>> listConversations();

  Future<void> saveConversation(Conversation conversation);

  Future<void> removeConversation(String id);

  Future<List<ChatMessage>> listMessages(String conversationId);

  Future<void> saveMessage(ChatMessage message);

  Future<void> removeMessages(String conversationId);
}
