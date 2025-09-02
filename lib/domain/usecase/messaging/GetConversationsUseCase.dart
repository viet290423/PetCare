import '../../entity/Conversation.dart';
import '../../repository/MessagingRepository.dart';

class GetConversationsUseCase {
  final MessagingRepository repository;
  GetConversationsUseCase(this.repository);

  Future<List<Conversation>> call() => repository.getConversations();
}


