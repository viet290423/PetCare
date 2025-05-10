import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petcare/data/model/PetModel.dart';
import 'package:petcare/domain/usecase/pet/PetUseCase.dart';


class UserHomeViewModel with ChangeNotifier {
  final PetUseCase getPetData;
  List<PetModel> _pets = [];
  bool _isLoading = false;
  String? _error;

  UserHomeViewModel({required this.getPetData});

  List<PetModel> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Future<void> fetchPets() async {
  //   _isLoading = true;
  //   notifyListeners();
  //
  //   try {
  //     _pets = await getPetData();
  //     _error = null;
  //   } catch (e) {
  //     _error = e.toString();
  //   }
  //
  //   _isLoading = false;
  //   notifyListeners();
  // }

  Future<void> fetchPets() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('pets')
        .get();

    _pets = querySnapshot.docs
        .map((doc) => PetModel.fromJson(doc.data()))
        .toList();
    notifyListeners();
  }

}