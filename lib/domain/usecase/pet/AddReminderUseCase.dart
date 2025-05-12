import 'package:petcare/domain/repository/PetRepository.dart';

import '../../../data/model/ReminderModel.dart';

class AddReminderUseCase {
  final PetRepository repository;

  AddReminderUseCase(this.repository);

  Future<void> call(ReminderModel reminder) {
    return repository.addReminder(reminder);
  }
}
