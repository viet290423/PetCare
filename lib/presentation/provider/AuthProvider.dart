import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/source/FirebaseUserHelperDataSource.dart';
import '../../domain/entity/AuthUser.dart';
import '../../domain/usecase/auth/GetCurrentUserUseCase.dart';
import '../../domain/usecase/auth/SignInUseCase.dart';
import '../../domain/usecase/auth/SignOutUseCase.dart';
import '../../domain/usecase/auth/SignUpUseCase.dart';

class AuthProvider with ChangeNotifier {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignOutUseCase signOutUseCase;

  AuthProvider({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.getCurrentUserUseCase,
    required this.signOutUseCase,
  });

  AuthUser? _user;

  AuthUser? get user => _user;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _error;

  String? get error => _error;

  AuthCredential? _pendingCredential;

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> signUpUser({
    required String email,
    required String password,
    required String role,
    String? name,
    required BuildContext context,
  }) async {
    // Kiểm tra dữ liệu đầu vào
    if (email.isEmpty || password.isEmpty || name == null || name.isEmpty) {
      _error = 'Vui lòng điền đầy đủ thông tin (tên, email, mật khẩu).';
      _showError(context, _error!);
      notifyListeners();
      return;
    }

    if (!_isValidEmail(email)) {
      _error = 'Email không hợp lệ. Vui lòng kiểm tra lại.';
      _showError(context, _error!);
      notifyListeners();
      return;
    }

    if (password.length < 6) {
      _error = 'Mật khẩu phải có ít nhất 6 ký tự.';
      _showError(context, _error!);
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await signUpUseCase(
      email: email,
      password: password,
      role: role,
      name: name,
    );

    result.fold(
      (failure) {
        _error = failure.message ?? 'Đăng ký thất bại. Vui lòng thử lại.';
        _showError(context, _error!);
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

  Future<void> signInUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // Kiểm tra dữ liệu đầu vào
    if (email.isEmpty || password.isEmpty) {
      _error = 'Vui lòng điền đầy đủ email và mật khẩu.';
      _showError(context, _error!);
      notifyListeners();
      return;
    }

    if (!_isValidEmail(email)) {
      _error = 'Email không hợp lệ. Vui lòng kiểm tra lại.';
      _showError(context, _error!);
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await signInUseCase(email: email, password: password);

    result.fold(
      (failure) {
        _error = failure.message ?? 'Đăng nhập thất bại. Vui lòng thử lại.';
        _showError(context, _error!);
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

  Future<bool> signInWithFacebook({required String role}) async {
    try {
      print('Bắt đầu đăng nhập bằng Facebook...');
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Đăng nhập bằng Facebook
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );
      print(
        'Kết quả đăng nhập từ Facebook: ${result.status}, message: ${result.message}',
      );

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken?.tokenString;
        if (accessToken == null) {
          print('Không thể lấy access token từ Facebook.');
          _error = 'Không thể lấy access token từ Facebook.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        print('Access token: $accessToken');

        // Tạo credential từ access token của Facebook
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken,
        );
        print('Credential tạo thành công');

        // Đăng nhập vào Firebase với credential
        final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
        UserCredential userCredential;

        try {
          userCredential = await firebaseAuth.signInWithCredential(credential);
          print('Đăng nhập Firebase thành công: ${userCredential.user?.email}');
        } catch (e) {
          if (e is FirebaseAuthException &&
              e.code == 'account-exists-with-different-credential') {
            _pendingCredential = e.credential;
            final String email = e.email ?? '';

            _error =
                'Email $email đã được dùng với Google. Vui lòng đăng nhập bằng Google để liên kết.';
            _isLoading = false;
            notifyListeners();
            return false;
          } else {
            _error = 'Đăng nhập thất bại: $e';
            _isLoading = false;
            notifyListeners();
            return false;
          }
        }

        final firebaseUser = userCredential.user;
        if (firebaseUser == null) {
          print('Không lấy được tài khoản từ Firebase.');
          _error = 'Không lấy được tài khoản từ Firebase.';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Lấy dữ liệu từ Facebook
        final fbData = await FacebookAuth.instance.getUserData();
        final String email =
            firebaseUser.email ?? 'fb_${firebaseUser.uid}@example.com';
        final String name =
            fbData['name'] ?? firebaseUser.displayName ?? 'Người dùng Facebook';
        print('Email: $email, Name: $name');

        final firestoreUser = await FirebaseUserHelper.getUserByUid(
          firebaseUser.uid,
        );
        if (firestoreUser != null) {
          print('User đã tồn tại trong Firestore: ${firestoreUser.email}');
          _user = firestoreUser;
        } else {
          final newUser = AuthUser(
            uid: firebaseUser.uid,
            email: email,
            role: role,
            name: name,
          );
          await FirebaseUserHelper.saveUser(newUser);
          print('Tạo mới user Firestore: ${newUser.email}');
          _user = newUser;
        }

        _isLoading = false;
        notifyListeners();
        return _user != null;
      } else {
        print('Đăng nhập Facebook thất bại: ${result.message}');
        _error = result.message ?? 'Đăng nhập Facebook thất bại.';
        _user = null;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Lỗi tổng quát: $e');
      _error = 'Lỗi: $e';
      _user = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle({required String role}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _error = 'Người dùng đã huỷ đăng nhập bằng Google.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        _error = 'Không lấy được thông tin người dùng từ Google.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final email =
          firebaseUser.email ?? 'google_${firebaseUser.uid}@example.com';
      final name = firebaseUser.displayName ?? 'Người dùng Google';

      // Check Firestore theo UID
      final firestoreUser = await FirebaseUserHelper.getUserByUid(
        firebaseUser.uid,
      );
      if (firestoreUser != null) {
        _user = firestoreUser;
      } else {
        final newUser = AuthUser(
          uid: firebaseUser.uid,
          email: email,
          role: role,
          name: name,
        );
        await FirebaseUserHelper.saveUser(newUser);
        _user = newUser;
      }

      return _user != null;
    } catch (e) {
      _error = 'Lỗi đăng nhập Google: $e';
      _user = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) {
        _user = null;
      },
      (user) {
        _user = user;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOutUser() async {
    _isLoading = true;
    notifyListeners();

    final result = await signOutUseCase();
    result.fold(
      (failure) {
        _error = failure.message ?? 'Đăng xuất thất bại. Vui lòng thử lại.';
      },
      (_) {
        _error = null;
        _user = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<bool> linkPendingCredentialWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _error = 'Hủy đăng nhập bằng Google.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập lại bằng Google
      final googleUserCredential = await FirebaseAuth.instance
          .signInWithCredential(googleCredential);
      final firebaseUser = googleUserCredential.user;

      // 🔗 Liên kết Facebook Credential nếu có
      if (_pendingCredential != null && firebaseUser != null) {
        await firebaseUser.linkWithCredential(_pendingCredential!);
        print('✅ Liên kết Facebook vào tài khoản Google thành công!');
        _pendingCredential = null;
      }

      // Lấy hoặc tạo user từ Firestore
      final firestoreUser = await FirebaseUserHelper.getUserByUid(
        firebaseUser!.uid,
      );
      if (firestoreUser != null) {
        _user = firestoreUser;
      } else {
        final newUser = AuthUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          role: 'user',
          name: firebaseUser.displayName ?? 'Người dùng',
        );
        await FirebaseUserHelper.saveUser(newUser);
        _user = newUser;
      }

      return true;
    } catch (e) {
      _error = 'Lỗi khi liên kết tài khoản: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
