import '../entity/Conversation.dart';
import '../entity/Message.dart';

abstract class MessagingRepository {
  Future<List<Conversation>> getConversations();
  Future<Conversation> getOrCreateConversation(String otherUserId);
  Future<List<Message>> getMessages(String conversationId, {int page = 0, int limit = 50});
  Future<Message> sendMessage({required String conversationId, required String content});
  Future<void> markAsRead(String messageId, String conversationId);
}


