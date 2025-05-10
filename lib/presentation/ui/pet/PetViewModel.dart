import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;

import '../../../data/model/PetModel.dart';
import '../../../domain/usecase/pet/AddPetUseCase.dart';
import '../../../domain/usecase/pet/PetUseCase.dart';

class PetViewModel extends ChangeNotifier {
  final PetUseCase petUseCase;
  final AddPetUseCase addPetUseCase;

  PetViewModel({
    required this.petUseCase,
    required this.addPetUseCase
  });

  List<PetModel> pets = [];
  bool isLoading = false;
  String? error;

  Future<void> addPet(PetModel pet) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(pet.id);

    await docRef.set(pet.toJson());
  }

  Future<String?> uploadPetImage(File file) async {
    try {
      final fileName = path.basename(file.path);
      final ref = FirebaseStorage.instance.ref().child('pet_images/$fileName');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Lỗi khi upload ảnh: $e');
      return null;
    }
  }
}