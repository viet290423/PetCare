// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcare/data/repository/PetRepositoryImpl.dart';
import 'package:petcare/data/source/AuthUserDataSource.dart';
import 'package:petcare/domain/repository/PetRepository.dart';
import 'package:petcare/domain/usecase/pet/AddPetUseCase.dart';
import 'package:petcare/domain/usecase/pet/PetUseCase.dart';
import 'package:petcare/presentation/ui/pet/PetViewModel.dart';
import 'package:petcare/presentation/ui/user/UserHomeViewModel.dart';

import '../data/repository/AuthUserRepositoryImpl.dart';
import '../domain/repository/AuthRepository.dart';
import '../domain/usecase/auth/GetCurrentUserUseCase.dart';
import '../domain/usecase/auth/SignInUseCase.dart';
import '../domain/usecase/auth/SignOutUseCase.dart';
import '../domain/usecase/auth/SignUpUseCase.dart';
import '../presentation/provider/AuthProvider.dart';
import '../presentation/ui/auth/AuthViewModel.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => firebase_auth.FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Data sources
  sl.registerLazySingleton<AuthUserDataSource>(
        () => AuthDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PetRepository>(
        () => PetRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => PetUseCase(sl()));
  sl.registerLazySingleton(() => AddPetUseCase(sl()));

  // Provider
  sl.registerLazySingleton(() => AuthProvider(
    signUpUseCase: sl(),
    signInUseCase: sl(),
    getCurrentUserUseCase: sl(),
    signOutUseCase: sl(),
  ));

  // ViewModel
  sl.registerFactory(() => AuthViewModel(
    signUpUseCase: sl(),
    signInUseCase: sl(),
    getCurrentUserUseCase: sl(),
    signOutUseCase: sl(),
  ));

  sl.registerFactory(() => UserHomeViewModel(
    getPetData: sl()
  ));

  sl.registerFactory(() => PetViewModel(
     addPetUseCase: sl(),
    petUseCase: sl()
  ));
}