import '../../entity/Message.dart';
import '../../repository/MessagingRepository.dart';

class SendMessageUseCase {
  final MessagingRepository repository;
  SendMessageUseCase(this.repository);

  Future<Message> call({required String conversationId, required String content}) =>
      repository.sendMessage(conversationId: conversationId, content: content);
}


