import 'package:dartz/dartz.dart';

import '../../../data/model/ServiceModel.dart';
import '../../repository/ServiceRepository.dart';

class GetServicesUseCase {
  final ServiceRepository repository;

  GetServicesUseCase(this.repository);

  Future<Either<String, List<ServiceModel>>> call() async {
    try {
      final services = await repository.getServices();
      return Right(services);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
