import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../entity/AuthUser.dart';
import '../../repository/AuthRepository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, AuthUser>> call({
    required String email,
    required String password,
    required String role,
    String? name,
  }) async {
    return await repository.signUp(
      email: email,
      password: password,
      role: role,
      name: name,
    );
  }
}
