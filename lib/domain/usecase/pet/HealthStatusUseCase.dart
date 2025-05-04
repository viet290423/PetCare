import 'package:petcare/data/model/HealthStatusModel.dart';

import '../../repository/PetRepository.dart';

class HealthStatusUseCase {
  final PetRepository repository;

  HealthStatusUseCase(this.repository);

  Future<HealthStatusModel> call(String petId) async {
    return await repository.getHealthStatus(petId);
  }
}