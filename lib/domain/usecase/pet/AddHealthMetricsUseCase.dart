import 'package:dartz/dartz.dart';
import '../../../data/model/HealthMetricsModel.dart';
import '../../repository/PetRepository.dart';

class AddHealthMetricsUseCase {
  final PetRepository repository;

  AddHealthMetricsUseCase(this.repository);

  Future<Either<String, void>> call(HealthMetricsModel metrics) async {
    try {
      await repository.addHealthMetrics(metrics);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
