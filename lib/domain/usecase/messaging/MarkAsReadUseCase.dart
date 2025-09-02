import '../../repository/MessagingRepository.dart';

class MarkAsReadUseCase {
  final MessagingRepository repository;
  MarkAsReadUseCase(this.repository);

  Future<void> call(String messageId, String conversationId) =>
      repository.markAsRead(messageId, conversationId);
}


