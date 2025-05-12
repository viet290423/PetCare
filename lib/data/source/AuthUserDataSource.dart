import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<AuthUserModel> signInWithGoogle();

  Future<AuthUserModel> signInWithFacebook();

  Future<AuthUserModel> getCurrentUser();

  Future<void> signOut();
}

class AuthUserDataSourceImpl implements AuthUserDataSource {
  final SupabaseClient client;

  AuthUserDataSourceImpl(this.client);

  @override
  Future<AuthUserModel> signUp({
    required String email,
    required String password,
    required String role,
    String? name,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'role': role, 'name': name},
      );

      final user = response.user;
      if (user == null)
        throw ServerException(message: 'Không thể tạo tài khoản.');

      return AuthUserModel(
        uid: user.id,
        email: user.email ?? '',
        role: role,
        name: name,
      );
    } catch (e) {
      throw ServerException(message: 'Đăng ký thất bại: ${e.toString()}');
    }
  }

  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      final metadata = user?.userMetadata ?? {};
      return AuthUserModel(
        uid: user!.id,
        email: user.email!,
        role: metadata['role'] ?? 'user',
        name: metadata['name'],
      );
    } catch (e) {
      throw ServerException(message: 'Đăng nhập thất bại: ${e.toString()}');
    }
  }

  @override
  Future<AuthUserModel> signInWithGoogle() async {
    try {
      const webClientId = '521870006732-ncuognbde5qtvmjg7cdn59fcfc18b6ol.apps.googleusercontent.com';
      const iosClientId = '521870006732-vnvobl9s8vt313l8i6hj7sak461d4q08.apps.googleusercontent.com';

      final googleSignIn = GoogleSignIn(
        clientId: iosClientId, // chỉ cần nếu dùng iOS
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw ServerException(message: 'Người dùng huỷ đăng nhập.');

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        throw ServerException(message: 'Không lấy được token từ Google.');
      }

      final authResponse = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = authResponse.user;
      if (user == null) throw ServerException(message: 'Đăng nhập thất bại.');

      return AuthUserModel(
        uid: user.id,
        email: user.email ?? '',
        name: user.userMetadata?['full_name'],
        role: '', // nếu có lưu role riêng thì nên gọi tiếp Supabase.from('users')...
      );
    } catch (e) {
      throw ServerException(message: 'Lỗi Google OAuth: $e');
    }
  }

  @override
  Future<AuthUserModel> signInWithFacebook() async {
    try {
      // // Đăng nhập với Facebook SDK
      // final LoginResult result = await FacebookAuth.instance.login(
      //   permissions: ['email', 'public_profile'],
      // );
      //
      // if (result.status != LoginStatus.success) {
      //   throw ServerException(message: 'Đăng nhập Facebook thất bại: ${result.status}');
      // }
      //
      // // Lấy access token từ Facebook
      // final accessToken = result.accessToken?.tokenString;
      // if (accessToken == null) {
      //   throw ServerException(message: 'Không lấy được token từ Facebook.');
      // }

      // Lấy user data từ Facebook
      final userData = await FacebookAuth.instance.getUserData(fields: "name,email,picture");

      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: kIsWeb ? null : 'io.supabase.flutter://login-callback',
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
      // Chờ Supabase xử lý callback và lấy lại thông tin user
      final user = client.auth.currentUser;
      if (user == null) {
        throw ServerException(message: 'Đăng nhập thất bại.');
      }

      return AuthUserModel(
        uid: user.id,
        email: user.email ?? '',
        name: user.userMetadata?['full_name'] ?? 'Facebook User',
        role: '', // bạn có thể xử lý logic role sau
      );
    } catch (e) {
      // Ghi log chi tiết hơn để debug
      print('Chi tiết lỗi Facebook OAuth: $e');
      throw ServerException(message: 'Lỗi Facebook OAuth: $e');
    }
  }
  //
  // @override
  // Future<AuthUserModel> signInWithFacebook() async {
  //   try {
  //     await Supabase.instance.client.auth.signInWithOAuth(
  //       OAuthProvider.facebook,
  //       redirectTo: kIsWeb ? null : 'io.supabase.flutter://login-callback',
  //       authScreenLaunchMode: LaunchMode.platformDefault,
  //     );
  //     // Chờ Supabase xử lý callback và lấy lại thông tin user
  //     final user = client.auth.currentUser;
  //     if (user == null) {
  //       throw ServerException(message: 'Đăng nhập thất bại.');
  //     }
  //
  //     return AuthUserModel(
  //       uid: user.id,
  //       email: user.email ?? '',
  //       name: user.userMetadata?['full_name'] ?? 'Facebook User',
  //       role: '', // bạn có thể xử lý logic role sau
  //     );
  //   } catch (e) {
  //     throw ServerException(message: 'Lỗi Facebook OAuth: $e');
  //   }
  // }

  @override
  Future<AuthUserModel> getCurrentUser() async {
    final user = client.auth.currentUser;
    if (user == null) throw ServerException(message: 'Chưa đăng nhập.');

    final metadata = user.userMetadata ?? {};
    return AuthUserModel(
      uid: user.id,
      email: user.email!,
      role: metadata['role'] ?? 'user',
      name: metadata['name'],
    );
  }

  @override
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
