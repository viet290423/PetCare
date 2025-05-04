import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entity/AuthUser.dart';
import '../../repository/AuthRepository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, AuthUser>> call({
    required String email,
    required String password,
  }) async {
    return await repository.signIn(email: email, password: password);
  }
}
