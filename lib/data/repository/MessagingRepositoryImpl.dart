import '../../domain/entity/Conversation.dart';
import '../../domain/entity/Message.dart';
import '../../domain/repository/MessagingRepository.dart';
import '../model/ConversationModel.dart';
import '../model/MessageModel.dart';
import '../source/MessagingDataSource.dart';

class MessagingRepositoryImpl implements MessagingRepository {
  final MessagingDataSource dataSource;

  MessagingRepositoryImpl(this.dataSource);

  @override
  Future<List<Conversation>> getConversations() async {
    final list = await dataSource.getConversations();
    return list;
  }

  @override
  Future<Conversation> getOrCreateConversation(String otherUserId) async {
    final conv = await dataSource.getOrCreateConversation(otherUserId);
    return conv;
  }

  @override
  Future<List<Message>> getMessages(String conversationId, {int page = 0, int limit = 50}) async {
    final list = await dataSource.getMessages(conversationId, page: page, limit: limit);
    return list;
  }

  @override
  Future<Message> sendMessage({required String conversationId, required String content}) async {
    final msg = await dataSource.sendMessage(conversationId: conversationId, content: content);
    return msg;
  }

  @override
  Future<void> markAsRead(String messageId, String conversationId) {
    return dataSource.markAsRead(messageId, conversationId);
  }
}


