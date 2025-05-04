import 'package:flutter/cupertino.dart';

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

  Future<void> fetchPets() async {
    isLoading = true;
    notifyListeners();
    try {
      pets = await petUseCase();
      error = null;
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addPet(PetModel pet) async {
    try {
      await addPetUseCase(pet);
      pets.add(pet);
      notifyListeners();
    } catch (e) {
      error = e.toString();
    }
  }
}