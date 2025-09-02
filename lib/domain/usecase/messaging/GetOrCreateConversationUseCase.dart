import '../../entity/Conversation.dart';
import '../../repository/MessagingRepository.dart';

class GetOrCreateConversationUseCase {
  final MessagingRepository repository;
  GetOrCreateConversationUseCase(this.repository);

  Future<Conversation> call(String otherUserId) => repository.getOrCreateConversation(otherUserId);
}


