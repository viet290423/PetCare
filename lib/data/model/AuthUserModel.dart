import '../../domain/entity/AuthUser.dart';

class AuthUserModel extends AuthUser {
  AuthUserModel({
    required super.uid,
    required super.email,
    required super.role,
    super.name,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email, 'role': role, 'name': name};
  }
}
