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

  // Cache cho reminders và appointments
  final Map<String, List<ReminderModel>> _remindersCache = {};
  final Map<String, List<AppointmentModel>> _appointmentsCache = {};

  UserHomeViewModel({
    required this.getPetData,
    required this.getRemindersByPetUseCase,
  });

  List<PetModel> get pets => _pets;
  List<ReminderModel> get reminders => _remindersCache[selectedPetId] ?? [];
  List<AppointmentModel> get appointments => _appointmentsCache[selectedPetId] ?? [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? selectedPetId;

  Future<void> fetchPets({bool forceRefresh = false}) async {
    if (forceRefresh) {
      _pets.clear();
    }
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

      final result = await getPetData();
      _pets = result;
      _error = null;
    } catch (e) {
      _error = 'Lỗi khi tải thú cưng: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReminders(String petId, {bool forceRefresh = false}) async {
    selectedPetId = petId;

    if (!forceRefresh && _remindersCache.containsKey(petId)) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final reminders = await getRemindersByPetUseCase(petId);
      _remindersCache[petId] = reminders;
      _error = null;
    } catch (e) {
      _error = 'Lỗi khi tải nhắc nhở: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAppointments(String petId, {bool forceRefresh = false}) async {
    selectedPetId = petId;

    if (!forceRefresh && _appointmentsCache.containsKey(petId)) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final response = await Supabase.instance.client
          .from('appointments')
          .select('*, services(title)')
          .eq('user_id', userId)
          .eq('pet_id', petId);

      final appointments = (response as List)
          .map((json) => AppointmentModel.fromJson(json))
          .toList();

      _appointmentsCache[petId] = appointments;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCache() {
    _remindersCache.clear();
    _appointmentsCache.clear();
    notifyListeners();
  }
}