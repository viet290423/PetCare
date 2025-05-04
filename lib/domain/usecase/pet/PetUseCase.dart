import '../../../data/model/PetModel.dart';
import '../../repository/PetRepository.dart';

class PetUseCase {
  final PetRepository repository;

  PetUseCase(this.repository);

  Future<List<PetModel>> call() async {
    return await repository.getPets();
  }
}