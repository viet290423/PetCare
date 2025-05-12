import 'package:petcare/domain/repository/PetRepository.dart';

import '../../../data/model/ReminderModel.dart';

class GetRemindersByPetUseCase {
  final PetRepository repository;
  GetRemindersByPetUseCase(this.repository);
  Future<List<ReminderModel>> call(String petId) => repository.getRemindersByPet(petId);
}