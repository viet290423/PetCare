import 'package:dartz/dartz.dart';
import '../../../data/model/HealthMetricsModel.dart';
import '../../repository/PetRepository.dart';

class GetHealthMetricsUseCase {
  final PetRepository repository;

  GetHealthMetricsUseCase(this.repository);

  Future<Either<String, List<HealthMetricsModel>>> call(String petId) async {
    try {
      final metrics = await repository.getHealthMetrics(petId);
      return Right(metrics);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
