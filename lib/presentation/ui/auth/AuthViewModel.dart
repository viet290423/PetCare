import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petcare/domain/usecase/auth/SignInWithFacebookUseCase.dart';
import 'package:petcare/domain/usecase/auth/SignInWithGoogleUseCase.dart';

import '../../../core/error/failures.dart';
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
  final SignOutUseCase signOutUseCase;

  AuthViewModel({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.signInWithGoogleUseCase,
    required this.signInWithFacebookUseCase,
    required this.getCurrentUserUseCase,
    required this.signOutUseCase,
  });

  AuthUser? _user;
  bool _isLoading = false;
  String? _error;

  AuthUser? get user => _user;
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
    // Kiểm tra dữ liệu đầu vào
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
          (user) {
        _error = null;
        _user = user;
      },
    );

    _isLoading = false;
    notifyListeners();
  }



  Future<void> signOutUser() async {
    _setLoading(true);
    final result = await signOutUseCase();
    result.fold(
          (failure) => _setError(failure.message),
          (_) => _setUser(null),
    );
    _setLoading(false);
  }

  Future<void> checkCurrentUser() async {
    _setLoading(true);
    final result = await getCurrentUserUseCase();
    result.fold(
          (_) => _setUser(null),
          (user) => _setUser(user),
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
  // Future<bool> signInWithGoogle({required String role}) async {
  //   _setLoading(true);
  //   _setError(null);
  //
  //   try {
  //     final googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) {
  //       _setError('Người dùng huỷ đăng nhập Google.');
  //       return false;
  //     }
  //
  //     final googleAuth = await googleUser.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  //     final firebaseUser = userCredential.user;
  //     if (firebaseUser == null) {
  //       _setError('Không thể lấy người dùng từ Google.');
  //       return false;
  //     }
  //
  //     final email = firebaseUser.email ?? 'google_${firebaseUser.uid}@example.com';
  //     final name = firebaseUser.displayName ?? 'Người dùng Google';
  //     final firestoreUser = await FirebaseUserHelper.getUserByUid(firebaseUser.uid);
  //
  //     if (firestoreUser != null) {
  //       _setUser(firestoreUser);
  //     } else {
  //       final newUser = AuthUser(
  //         uid: firebaseUser.uid,
  //         email: email,
  //         role: role,
  //         name: name,
  //       );
  //       await FirebaseUserHelper.saveUser(newUser);
  //       _setUser(newUser);
  //     }
  //     return true;
  //   } catch (e) {
  //     _setError('Lỗi đăng nhập Google: $e');
  //     return false;
  //   } finally {
  //     _setLoading(false);
  //   }
  // }
  //
  // Future<bool> signInWithFacebook({required String role}) async {
  //   _setLoading(true);
  //   _setError(null);
  //
  //   try {
  //     final result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
  //     if (result.status != LoginStatus.success) {
  //       _setError('Đăng nhập Facebook thất bại.');
  //       return false;
  //     }
  //
  //     final token = result.accessToken?.tokenString;
  //     if (token == null) {
  //       _setError('Không thể lấy token Facebook.');
  //       return false;
  //     }
  //
  //     final credential = FacebookAuthProvider.credential(token);
  //
  //     try {
  //       final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  //       final firebaseUser = userCredential.user;
  //       if (firebaseUser == null) throw Exception('Firebase user null');
  //
  //       final fbData = await FacebookAuth.instance.getUserData();
  //       final email = firebaseUser.email ?? 'fb_${firebaseUser.uid}@example.com';
  //       final name = fbData['name'] ?? firebaseUser.displayName ?? 'Người dùng Facebook';
  //
  //       final firestoreUser = await FirebaseUserHelper.getUserByUid(firebaseUser.uid);
  //       if (firestoreUser != null) {
  //         _setUser(firestoreUser);
  //       } else {
  //         final newUser = AuthUser(
  //           uid: firebaseUser.uid,
  //           email: email,
  //           role: role,
  //           name: name,
  //         );
  //         await FirebaseUserHelper.saveUser(newUser);
  //         _setUser(newUser);
  //       }
  //
  //       return true;
  //     } on FirebaseAuthException catch (e) {
  //       if (e.code == 'account-exists-with-different-credential') {
  //         _pendingCredential = e.credential;
  //         _setError('Email đã dùng với Google. Vui lòng đăng nhập bằng Google để liên kết.');
  //         return false;
  //       }
  //       rethrow;
  //     }
  //   } catch (e) {
  //     _setError('Lỗi Facebook: $e');
  //     return false;
  //   } finally {
  //     _setLoading(false);
  //   }
  // }
  //
  // Future<bool> linkPendingCredentialWithGoogle() async {
  //   _setLoading(true);
  //
  //   try {
  //     final googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) {
  //       _setError('Huỷ đăng nhập Google.');
  //       return false;
  //     }
  //
  //     final googleAuth = await googleUser.authentication;
  //     final googleCredential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     final googleUserCredential = await FirebaseAuth.instance.signInWithCredential(googleCredential);
  //     final firebaseUser = googleUserCredential.user;
  //
  //     if (_pendingCredential != null && firebaseUser != null) {
  //       await firebaseUser.linkWithCredential(_pendingCredential!);
  //       _pendingCredential = null;
  //     }
  //
  //     final firestoreUser = await FirebaseUserHelper.getUserByUid(firebaseUser!.uid);
  //     if (firestoreUser != null) {
  //       _setUser(firestoreUser);
  //     } else {
  //       final newUser = AuthUser(
  //         uid: firebaseUser.uid,
  //         email: firebaseUser.email!,
  //         role: 'user',
  //         name: firebaseUser.displayName ?? 'Người dùng',
  //       );
  //       await FirebaseUserHelper.saveUser(newUser);
  //       _setUser(newUser);
  //     }
  //
  //     return true;
  //   } catch (e) {
  //     _setError('Lỗi khi liên kết tài khoản: $e');
  //     return false;
  //   } finally {
  //     _setLoading(false);
  //   }
  // }
}
