import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../core/error/exceptions.dart';
import '../model/AuthUserModel.dart';

abstract class AuthUserDataSource {
  Future<AuthUserModel> signUp({
    required String email,
    required String password,
    required String role,
    String? name,
  });

  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  });

  Future<AuthUserModel> getCurrentUser();

  Future<void> signOut();
}

class AuthDataSourceImpl implements AuthUserDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<AuthUserModel> signUp({
    required String email,
    required String password,
    required String role,
    String? name,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw ServerException(message: 'Không thể tạo tài khoản. Vui lòng thử lại.');
      }

      final userData = AuthUserModel(
        uid: user.uid,
        email: email,
        role: role,
        name: name,
      );

      await firestore.collection('users').doc(user.uid).set(userData.toJson());

      return userData;
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email đã được sử dụng. Vui lòng chọn email khác.';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ. Vui lòng kiểm tra lại.';
          break;
        case 'weak-password':
          message = 'Mật khẩu quá yếu. Vui lòng sử dụng mật khẩu mạnh hơn.';
          break;
        default:
          message = e.message ?? 'Đăng ký thất bại. Vui lòng thử lại.';
      }
      throw ServerException(message: message);
    } catch (e) {
      throw ServerException(message: 'Đã có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw ServerException(message: 'Không thể đăng nhập. Vui lòng thử lại.');
      }

      final doc = await firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        throw ServerException(message: 'Dữ liệu người dùng không tồn tại.');
      }

      return AuthUserModel.fromJson(doc.data()!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email chưa được đăng ký. Vui lòng đăng ký tài khoản.';
          break;
        case 'wrong-password':
          message = 'Mật khẩu không đúng. Vui lòng kiểm tra lại.';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ. Vui lòng kiểm tra lại.';
          break;
        default:
          message = e.message ?? 'Đăng nhập thất bại. Vui lòng thử lại.';
      }
      throw ServerException(message: message);
    } catch (e) {
      throw ServerException(message: 'Đã có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  @override
  Future<AuthUserModel> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException(message: 'Không có người dùng nào đang đăng nhập.');
      }

      final doc = await firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        throw ServerException(message: 'Dữ liệu người dùng không tồn tại.');
      }

      return AuthUserModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException(message: 'Không thể lấy thông tin người dùng.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw ServerException(message: 'Đăng xuất thất bại. Vui lòng thử lại.');
    }
  }
}
