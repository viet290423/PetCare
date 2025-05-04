import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entity/AuthUser.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> signUp({
    required String email,
    required String password,
    required String role,
    String? name,
  });
  Future<Either<Failure, AuthUser>> signIn({
    required String email,
    required String password,
  });
  Future<Either<Failure, AuthUser>> getCurrentUser();
  Future<Either<Failure, void>> signOut();
}