import '../../../data/model/PetModel.dart';
import '../../repository/PetRepository.dart';

class UpdatePetUseCase {
  final PetRepository repository;
  UpdatePetUseCase(this.repository);

  Future<void> call(PetModel pet) async {
    await repository.updatePet(pet);
  }
}
