class AuthUser {
  final String uid;
  final String email;
  final String role;
  final String? name;

  AuthUser({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid' : uid,
      'email': email,
      'role': role,
      'name': name,
    };
  }

  factory AuthUser.fromMap(Map<String, dynamic> map) {
    return AuthUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      name: map['name'] ?? '',
    );
  }
}