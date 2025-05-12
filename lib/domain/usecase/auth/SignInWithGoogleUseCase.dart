import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entity/AuthUser.dart';
import '../../repository/AuthRepository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<Either<Failure, AuthUser>> call() async => repository.signInWithGoogle();
}