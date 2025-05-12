import 'package:dartz/dartz.dart';

import '../../../data/model/PetModel.dart';
import '../../repository/PetRepository.dart';

class AddPetUseCase {
  final PetRepository repository;

  AddPetUseCase(this.repository);

  Future<Either<String, void>> call(PetModel pet) async {
    try {
      await repository.addPet(pet);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
