import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entity/AuthUser.dart';
import '../../repository/AuthRepository.dart';

class SignInWithFacebookUseCase {
  final AuthRepository repository;

  SignInWithFacebookUseCase(this.repository);

  Future<Either<Failure, AuthUser>> call() => repository.signInWithFacebook();
}
