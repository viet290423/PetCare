import '../../entity/Message.dart';
import '../../repository/MessagingRepository.dart';

class GetMessagesUseCase {
  final MessagingRepository repository;
  GetMessagesUseCase(this.repository);

  Future<List<Message>> call(String conversationId, {int page = 0, int limit = 50}) =>
      repository.getMessages(conversationId, page: page, limit: limit);
}


