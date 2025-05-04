// lib/features/authentication/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:petcare/data/source/AuthUserDataSource.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entity/AuthUser.dart';
import '../../domain/repository/AuthRepository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthUserDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, AuthUser>> signUp({
    required String email,
    required String password,
    required String role,
    String? name,
  }) async {
    try {
      final user = await dataSource.signUp(
        email: email,
        password: password,
        role: role,
        name: name,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await dataSource.signIn(
        email: email,
        password: password,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> getCurrentUser() async {
    try {
      final user = await dataSource.getCurrentUser();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await dataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}