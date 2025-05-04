import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repository/PetRepository.dart';
import '../model/HealthStatusModel.dart';
import '../model/PetModel.dart';

class PetRepositoryImpl implements PetRepository {
  final FirebaseFirestore _firestore;

  PetRepositoryImpl(this._firestore);

  @override
  Future<List<PetModel>> getPets() async {
    final snapshot = await _firestore.collection('pets').get();
    return snapshot.docs.map((doc) => PetModel.fromJson(doc.data())).toList();
  }

  @override
  Future<HealthStatusModel> getHealthStatus(String petId) async {
    final snapshot = await _firestore
        .collection('pets')
        .doc(petId)
        .collection('health')
        .orderBy('lastVaccination', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return HealthStatusModel.fromJson(snapshot.docs.first.data());
    }
    return HealthStatusModel(weight: 0, lastVaccination: DateTime.now(), note: '');
  }

  @override
  Future<List<Map<String, dynamic>>> getProductSuggestions() async {
    final snapshot = await _firestore.collection('products').limit(2).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}