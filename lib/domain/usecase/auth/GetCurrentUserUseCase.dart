import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entity/AuthUser.dart';
import '../../repository/AuthRepository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, AuthUser>> call() async {
    return await repository.getCurrentUser();
  }
}
