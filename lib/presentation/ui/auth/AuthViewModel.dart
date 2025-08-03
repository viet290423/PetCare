import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petcare/domain/usecase/auth/SignInWithFacebookUseCase.dart';
import 'package:petcare/domain/usecase/auth/SignInWithGoogleUseCase.dart';
import 'package:petcare/domain/usecase/doctor/GetDoctorByUserIdUseCase.dart';

import '../../../core/error/failures.dart';
import '../../../data/model/DoctorModel.dart';
import '../../../data/source/FirebaseUserHelperDataSource.dart';
import '../../../domain/entity/AuthUser.dart';
import '../../../domain/usecase/auth/GetCurrentUserUseCase.dart';
import '../../../domain/usecase/auth/SignInUseCase.dart';
import '../../../domain/usecase/auth/SignOutUseCase.dart';
import '../../../domain/usecase/auth/SignUpUseCase.dart';

class AuthViewModel with ChangeNotifier {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignInWithFacebookUseCase signInWithFacebookUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GetDoctorByUserIdUseCase getDoctorByUserIdUseCase;
  final SignOutUseCase signOutUseCase;

  AuthViewModel({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.signInWithGoogleUseCase,
    required this.signInWithFacebookUseCase,
    required this.getCurrentUserUseCase,
    required this.getDoctorByUserIdUseCase,
    required this.signOutUseCase,
  });

  AuthUser? _user;
  DoctorModel? _doctor;
  bool _isLoading = false;
  String? _error;

  AuthUser? get user => _user;
  DoctorModel? get doctor => _doctor;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void _setUser(AuthUser? user) {
    _user = user;
    notifyListeners();
  }

  void _setDoctor(DoctorModel? doctor) {
    _doctor = doctor;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> signUpUser({
    required String email,
    required String password,
    required String role,
    required BuildContext context,
    required String name,
  }) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      _setError('Vui lòng điền đầy đủ thông tin.');
      return;
    }
    if (!_isValidEmail(email)) {
      _setError('Email không hợp lệ.');
      return;
    }
    if (password.length < 6) {
      _setError('Mật khẩu phải có ít nhất 6 ký tự.');
      return;
    }

    _setLoading(true);
    _setError(null);

    final result = await signUpUseCase(
      email: email,
      password: password,
      role: role,
      name: name,
    );

    result.fold(
      (failure) => _setError(failure.message),
      (user) => _setUser(user),
    );

    _setLoading(false);
  }

  Future<void> signInUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      _setError('Email hoặc mật khẩu không hợp lệ.');
      notifyListeners();
      return;
    }

    if (!_isValidEmail(email)) {
      _error = 'Email không hợp lệ. Vui lòng kiểm tra lại.';
      _setError(_error);
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await signInUseCase(email: email, password: password);

    result.fold(
      (failure) {
        _error = 'Đăng nhập thất bại. Vui lòng kiểm tra lại email và mật khẩu.';
        _setError(_error);
        _user = null;
      },
      (user) async {
        _error = null;
        _user = user;

        // Lấy thông tin bác sĩ nếu email có định dạng doctorpetcare.com
        if (email.toLowerCase().endsWith('@doctorpetcare.com')) {
          try {
            final doctor = await getDoctorByUserIdUseCase.execute(
              userId: user.uid,
            );
            _setDoctor(doctor);
          } catch (e) {
            _setDoctor(null);
          }
        }
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOutUser() async {
    _setLoading(true);
    final result = await signOutUseCase();
    result.fold((failure) => _setError(failure.message), (_) {
      _setUser(null);
      _setDoctor(null);
    });
    _setLoading(false);
  }

  Future<void> checkCurrentUser() async {
    _setLoading(true);
    final result = await getCurrentUserUseCase();
    result.fold(
      (_) {
        _setUser(null);
        _setDoctor(null);
      },
      (user) async {
        _setUser(user);

        // Nếu là doctor, lấy thông tin doctor với retry mechanism
        if (user.email.toLowerCase().endsWith('@doctorpetcare.com')) {
          // Retry mechanism - thử tối đa 3 lần
          int retryCount = 0;
          const maxRetries = 3;
          DoctorModel? doctor;

          while (retryCount < maxRetries && doctor == null) {
            try {
              doctor = await getDoctorByUserIdUseCase.execute(userId: user.uid);

              if (doctor != null) {
                _setDoctor(doctor);
                break; // Thành công, thoát khỏi vòng lặp
              } else {
                retryCount++;
                if (retryCount < maxRetries) {
                  await Future.delayed(Duration(seconds: 1));
                }
              }
            } catch (e) {
              retryCount++;
              if (retryCount < maxRetries) {
                await Future.delayed(Duration(seconds: 1));
              }
            }
          }

          if (doctor == null) {
            _setDoctor(null);
          }
        } else {
          _setDoctor(null);
        }
      },
    );
    _setLoading(false);
  }

  Future<Either<Failure, AuthUser>> signInWithGoogle() async {
    final result = await signInWithGoogleUseCase();
    result.fold(
      (failure) => _setError(failure.message),
      (user) => _setUser(user),
    );
    return result;
  }

  Future<Either<Failure, AuthUser>> signInWithFacebook() async {
    final result = await signInWithFacebookUseCase();
    result.fold(
      (failure) => _setError(failure.message),
      (user) => _setUser(user),
    );
    return result;
  }

  // Method để refresh thông tin doctor
  Future<void> refreshDoctorInfo() async {
    if (_user == null) return;

    if (_user!.email.toLowerCase().endsWith('@doctorpetcare.com')) {
      try {
        final doctor = await getDoctorByUserIdUseCase.execute(
          userId: _user!.uid,
        );
        _setDoctor(doctor);
      } catch (e) {
        _setDoctor(null);
      }
    }
  }
}
