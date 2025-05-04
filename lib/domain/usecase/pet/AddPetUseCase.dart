import '../../../data/model/PetModel.dart';
import '../../repository/PetRepository.dart';

class AddPetUseCase {
  final PetRepository repository;

  AddPetUseCase(this.repository);

  Future<void> call(PetModel pet) async {
    await repository.addPet(pet);
  }
}
