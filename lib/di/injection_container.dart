// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcare/data/repository/PetRepositoryImpl.dart';
import 'package:petcare/data/repository/ServiceRepositoryImpl.dart';
import 'package:petcare/data/repository/DoctorRepositoryImpl.dart';
import 'package:petcare/data/repository/CommunityRepositoryImpl.dart';
import 'package:petcare/data/source/AuthUserDataSource.dart';
import 'package:petcare/data/source/PetDataSource.dart';
import 'package:petcare/data/source/ServiceDataSource.dart';
import 'package:petcare/data/source/DoctorDataSource.dart';
import 'package:petcare/data/source/CommunityDataSource.dart';
import 'package:petcare/domain/repository/PetRepository.dart';
import 'package:petcare/domain/repository/ServiceRepository.dart';
import 'package:petcare/domain/repository/DoctorRepository.dart';
import 'package:petcare/domain/repository/CommunityRepository.dart';
import 'package:petcare/domain/usecase/auth/SignInWithFacebookUseCase.dart';
import 'package:petcare/domain/usecase/auth/SignInWithGoogleUseCase.dart';
import 'package:petcare/domain/usecase/doctor/GetDoctorByUserIdUseCase.dart';
import 'package:petcare/domain/usecase/pet/AddAppointmentUseCase.dart';
import 'package:petcare/domain/usecase/pet/AddPetUseCase.dart';
import 'package:petcare/domain/usecase/pet/AddReminderUseCase.dart';
import 'package:petcare/domain/usecase/pet/DeleteReminderUseCase.dart';
import 'package:petcare/domain/usecase/pet/GetRemindersByPetUseCase.dart';
import 'package:petcare/domain/usecase/pet/PetUseCase.dart';
import 'package:petcare/domain/usecase/pet/UpdatePetUseCase.dart';
import 'package:petcare/domain/usecase/pet/GetMedicalRecordsUseCase.dart';
import 'package:petcare/domain/usecase/pet/GetHealthMetricsUseCase.dart';
import 'package:petcare/domain/usecase/pet/GetVaccinationRecordsUseCase.dart';
import 'package:petcare/domain/usecase/pet/AddMedicalRecordUseCase.dart';
import 'package:petcare/domain/usecase/pet/AddHealthMetricsUseCase.dart';
import 'package:petcare/domain/usecase/pet/AddVaccinationRecordUseCase.dart';
import 'package:petcare/domain/usecase/service/AddServiceUseCase.dart';
import 'package:petcare/domain/usecase/service/GetServiceUseCase.dart';
import 'package:petcare/domain/usecase/doctor/GetDoctorsByServiceUseCase.dart';
import 'package:petcare/domain/usecase/doctor/GetAvailableTimeSlotsUseCase.dart';
import 'package:petcare/domain/usecase/community/GetPostsUseCase.dart';
import 'package:petcare/domain/usecase/community/CreatePostUseCase.dart';
import 'package:petcare/domain/usecase/community/LikePostUseCase.dart';
import 'package:petcare/domain/usecase/community/CreateCommentUseCase.dart';
import 'package:petcare/domain/usecase/community/GetPostCommentsUseCase.dart';
import 'package:petcare/domain/usecase/community/UploadMediaUseCase.dart';
import 'package:petcare/presentation/provider/CommunityProvider.dart';
import 'package:petcare/presentation/ui/doctor/AppointmentViewModel.dart';
import 'package:petcare/presentation/ui/pet/PetViewModel.dart';
import 'package:petcare/presentation/ui/user/homeScreen/UserHomeViewModel.dart';
import 'package:petcare/presentation/ui/user/serviceScreen/ServiceViewModel.dart';
import 'package:petcare/presentation/ui/doctor/homeScreen/DoctorViewModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petcare/data/source/MessagingDataSource.dart';
import 'package:petcare/domain/repository/MessagingRepository.dart';
import 'package:petcare/data/repository/MessagingRepositoryImpl.dart';
import 'package:petcare/domain/usecase/messaging/GetConversationsUseCase.dart';
import 'package:petcare/domain/usecase/messaging/GetOrCreateConversationUseCase.dart';
import 'package:petcare/domain/usecase/messaging/GetMessagesUseCase.dart';
import 'package:petcare/domain/usecase/messaging/SendMessageUseCase.dart';
import 'package:petcare/domain/usecase/messaging/MarkAsReadUseCase.dart';
import 'package:petcare/presentation/provider/MessagingProvider.dart';

import '../data/repository/AuthUserRepositoryImpl.dart';
import '../domain/repository/AuthRepository.dart';
import '../domain/usecase/auth/GetCurrentUserUseCase.dart';
import '../domain/usecase/auth/SignInUseCase.dart';
import '../domain/usecase/auth/SignOutUseCase.dart';
import '../domain/usecase/auth/SignUpUseCase.dart';
import '../domain/usecase/doctor/GetAllDoctorUseCase.dart';
import '../presentation/provider/AuthProvider.dart';
import '../presentation/ui/auth/AuthViewModel.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => firebase_auth.FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Data sources
  sl.registerLazySingleton<AuthUserDataSource>(
    () => AuthUserDataSourceImpl(Supabase.instance.client),
  );
  sl.registerLazySingleton<PetDataSource>(
    () => PetDataSourceImpl(Supabase.instance.client),
  );
  sl.registerLazySingleton<ServiceDataSource>(
    () => ServiceDataSourceImpl(Supabase.instance.client),
  );
  sl.registerLazySingleton<DoctorDataSource>(
    () => DoctorDataSourceImpl(Supabase.instance.client),
  );
  sl.registerLazySingleton<CommunityDataSource>(
    () => CommunityDataSourceImpl(Supabase.instance.client),
  );
  sl.registerLazySingleton<MessagingDataSource>(
    () => MessagingDataSourceImpl(Supabase.instance.client),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<PetRepository>(() => PetRepositoryImpl(sl()));
  sl.registerLazySingleton<ServiceRepository>(
    () => ServiceRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<DoctorRepository>(() => DoctorRepositoryImpl(sl()));
  sl.registerLazySingleton<CommunityRepository>(
    () => CommunityRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<MessagingRepository>(
    () => MessagingRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithFacebookUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => PetUseCase(sl()));
  sl.registerLazySingleton(() => AddPetUseCase(sl()));
  sl.registerLazySingleton(() => AddReminderUseCase(sl()));
  sl.registerLazySingleton(() => DeleteReminderUseCase(sl()));
  sl.registerLazySingleton(() => GetRemindersByPetUseCase(sl()));
  sl.registerLazySingleton(() => AddServiceUseCase(sl()));
  sl.registerLazySingleton(() => GetServicesUseCase(sl()));
  sl.registerLazySingleton(() => AddAppointmentUseCase(sl()));
  sl.registerLazySingleton(() => GetAllDoctorUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorByUserIdUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorsByServiceUseCase(sl()));
  sl.registerLazySingleton(() => GetAvailableTimeSlotsUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePetUseCase(sl()));

  // Records use cases
  sl.registerLazySingleton(() => GetMedicalRecordsUseCase(sl()));
  sl.registerLazySingleton(() => GetHealthMetricsUseCase(sl()));
  sl.registerLazySingleton(() => GetVaccinationRecordsUseCase(sl()));
  sl.registerLazySingleton(() => AddMedicalRecordUseCase(sl()));
  sl.registerLazySingleton(() => AddHealthMetricsUseCase(sl()));
  sl.registerLazySingleton(() => AddVaccinationRecordUseCase(sl()));

  // Community use cases
  sl.registerLazySingleton(() => GetPostsUseCase(sl()));
  sl.registerLazySingleton(() => CreatePostUseCase(sl()));
  sl.registerLazySingleton(() => LikePostUseCase(sl()));
  sl.registerLazySingleton(() => CreateCommentUseCase(sl()));
  sl.registerLazySingleton(() => GetPostCommentsUseCase(sl()));
  sl.registerLazySingleton(() => UploadMediaUseCase(sl()));

  // Messaging use cases
  sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
  sl.registerLazySingleton(() => GetOrCreateConversationUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsReadUseCase(sl()));

  // Provider
  sl.registerLazySingleton(
    () => AuthProvider(
      signUpUseCase: sl(),
      signInUseCase: sl(),
      getCurrentUserUseCase: sl(),
      signOutUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => CommunityProvider(
      getPostsUseCase: sl(),
      createPostUseCase: sl(),
      likePostUseCase: sl(),
      createCommentUseCase: sl(),
      getPostCommentsUseCase: sl(),
      uploadMediaUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => MessagingProvider(
      getConversationsUseCase: sl(),
      getOrCreateConversationUseCase: sl(),
      getMessagesUseCase: sl(),
      sendMessageUseCase: sl(),
      markAsReadUseCase: sl(),
    ),
  );

  // ViewModel
  sl.registerLazySingleton(
    () => AuthViewModel(
      signUpUseCase: sl(),
      signInUseCase: sl(),
      getCurrentUserUseCase: sl(),
      getDoctorByUserIdUseCase: sl(),
      signOutUseCase: sl(),
      signInWithGoogleUseCase: sl(),
      signInWithFacebookUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => UserHomeViewModel(
      getPetData: sl(),
      getRemindersByPetUseCase: sl(),
      deleteReminderUseCase: sl(),
      updatePetUseCase: sl(),
      getMedicalRecordsUseCase: sl(),
      getHealthMetricsUseCase: sl(),
      getVaccinationRecordsUseCase: sl(),
      addMedicalRecordUseCase: sl(),
      addHealthMetricsUseCase: sl(),
      addVaccinationRecordUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => PetViewModel(
      addPetUseCase: sl(),
      petUseCase: sl(),
      addReminderUseCase: sl(),
      deleteReminderUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ServicesViewModel(
      getServicesUseCase: sl(),
      addAppointmentUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => DoctorViewModel(
      getAllDoctorUseCase: sl(),
      getDoctorsByServiceUseCase: sl(),
      getAvailableTimeSlotsUseCase: sl(),
    ),
  );

  sl.registerFactory(() => AppointmentViewModel());
}
