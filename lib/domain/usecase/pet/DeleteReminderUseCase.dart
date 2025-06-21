import 'package:petcare/domain/repository/PetRepository.dart';

class DeleteReminderUseCase {
  final PetRepository repository;

  DeleteReminderUseCase(this.repository);

  Future<void> call(String reminderId) {
    return repository.deleteReminder(reminderId);
  }
}
