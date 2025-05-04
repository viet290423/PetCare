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

  Future<void> fetchPets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _pets = await getPetData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}