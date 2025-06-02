import 'package:dartz/dartz.dart';

import '../../../data/model/ServiceModel.dart';
import '../../repository/ServiceRepository.dart';

class AddServiceUseCase {
  final ServiceRepository repository;

  AddServiceUseCase(this.repository);

  Future<Either<String, void>> call(ServiceModel service) async {
    try {
      await repository.addService(service);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
