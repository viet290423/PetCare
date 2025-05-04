import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/AuthUser.dart';

class FirebaseUserHelper {
  static final _collection = FirebaseFirestore.instance.collection('users');

  /// Tìm user theo UID
  static Future<AuthUser?> getUserByUid(String uid) async {
    try {
      final doc = await _collection.doc(uid).get();
      if (!doc.exists) return null;
      return AuthUser.fromMap(doc.data()!);
    } catch (e) {
      print('[FirebaseUserHelper] Lỗi khi lấy user: $e');
      return null;
    }
  }

  /// Lưu user với uid làm document ID
  static Future<void> saveUser(AuthUser user) async {
    try {
      await _collection.doc(user.uid).set(user.toMap());
      print('[FirebaseUserHelper] Đã lưu user: ${user.uid}');
    } catch (e) {
      print('[FirebaseUserHelper] Lỗi khi lưu user: $e');
    }
  }
}
