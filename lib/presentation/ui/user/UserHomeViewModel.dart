import 'package:flutter/material.dart';
import 'package:petcare/data/model/PetModel.dart';
import 'package:petcare/domain/usecase/pet/PetUseCase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _error = 'Không có người dùng đăng nhập';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final result = await getPetData(); // Gọi UseCase

      _pets = result;
      _error = null;
    } catch (e) {
      _error = 'Lỗi khi tải thú cưng: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
