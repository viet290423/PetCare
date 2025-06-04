import 'package:flutter/material.dart';
import 'package:petcare/data/model/PetModel.dart';
import 'package:petcare/domain/usecase/pet/GetRemindersByPetUseCase.dart';
import 'package:petcare/domain/usecase/pet/PetUseCase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/model/AppointmentModel.dart';
import '../../../../data/model/ReminderModel.dart';

class UserHomeViewModel with ChangeNotifier {
  final PetUseCase getPetData;
  final GetRemindersByPetUseCase getRemindersByPetUseCase;

  List<PetModel> _pets = [];
  bool _isLoading = false;
  String? _error;

  UserHomeViewModel({
    required this.getPetData,
    required this.getRemindersByPetUseCase,
  });

  List<PetModel> get pets => _pets;

  List<ReminderModel> _reminders = [];
  List<ReminderModel> get reminders => _reminders;
  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> get appointments => _appointments;


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

  Future<void> fetchReminders(String petId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _reminders = await getRemindersByPetUseCase(petId);
      _error = null;
    } catch (e) {
      _error = 'Lỗi khi tải nhắc nhở: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAppointments(String petId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final response = await Supabase.instance.client
          .from('appointments')
          .select('*, services(title)')
          .eq('user_id', userId)
          .eq('pet_id', petId);

      _appointments = (response as List)
          .map((json) => AppointmentModel.fromJson(json))
          .toList();

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
