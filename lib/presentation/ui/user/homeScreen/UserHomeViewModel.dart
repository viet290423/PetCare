import 'package:flutter/material.dart';
import 'package:petcare/data/model/PetModel.dart';
import 'package:petcare/domain/usecase/pet/GetRemindersByPetUseCase.dart';
import 'package:petcare/domain/usecase/pet/PetUseCase.dart';
import 'package:petcare/domain/usecase/pet/UpdatePetUseCase.dart';
import 'package:petcare/domain/usecase/pet/GetMedicalRecordsUseCase.dart';
import 'package:petcare/domain/usecase/pet/GetHealthMetricsUseCase.dart';
import 'package:petcare/domain/usecase/pet/GetVaccinationRecordsUseCase.dart';
import 'package:petcare/domain/usecase/pet/AddMedicalRecordUseCase.dart';
import 'package:petcare/domain/usecase/pet/AddHealthMetricsUseCase.dart';
import 'package:petcare/domain/usecase/pet/AddVaccinationRecordUseCase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/model/AppointmentModel.dart';
import '../../../../data/model/ReminderModel.dart';
import '../../../../data/model/MedicalRecordModel.dart';
import '../../../../data/model/HealthMetricsModel.dart';
import '../../../../data/model/VaccinationRecordModel.dart';
import '../../../../data/model/PetTipsModel.dart';
import '../../../../domain/usecase/pet/DeleteReminderUseCase.dart';
import '../../../../services/pet_tips_service.dart';

class UserHomeViewModel with ChangeNotifier {
  final PetUseCase getPetData;
  final GetRemindersByPetUseCase getRemindersByPetUseCase;
  final DeleteReminderUseCase deleteReminderUseCase;
  final UpdatePetUseCase updatePetUseCase;
  final GetMedicalRecordsUseCase getMedicalRecordsUseCase;
  final GetHealthMetricsUseCase getHealthMetricsUseCase;
  final GetVaccinationRecordsUseCase getVaccinationRecordsUseCase;
  final AddMedicalRecordUseCase addMedicalRecordUseCase;
  final AddHealthMetricsUseCase addHealthMetricsUseCase;
  final AddVaccinationRecordUseCase addVaccinationRecordUseCase;

  List<PetModel> _pets = [];
  bool _isLoading = false;
  String? _error;

  // Cache cho reminders và appointments
  final Map<String, List<ReminderModel>> _remindersCache = {};
  final Map<String, List<AppointmentModel>> _appointmentsCache = {};

  // Cache cho records
  final Map<String, List<MedicalRecordModel>> _medicalRecordsCache = {};
  final Map<String, List<HealthMetricsModel>> _healthMetricsCache = {};
  final Map<String, List<VaccinationRecordModel>> _vaccinationRecordsCache = {};
  
  // Cache cho AI tips
  final Map<String, PetTipsResponse> _aiTipsCache = {};
  bool _isLoadingTips = false;

  UserHomeViewModel({
    required this.getPetData,
    required this.getRemindersByPetUseCase,
    required this.deleteReminderUseCase,
    required this.updatePetUseCase,
    required this.getMedicalRecordsUseCase,
    required this.getHealthMetricsUseCase,
    required this.getVaccinationRecordsUseCase,
    required this.addMedicalRecordUseCase,
    required this.addHealthMetricsUseCase,
    required this.addVaccinationRecordUseCase,
  });

  List<PetModel> get pets => _pets;
  List<ReminderModel> get reminders => _remindersCache[selectedPetId] ?? [];
  List<AppointmentModel> get appointments =>
      _appointmentsCache[selectedPetId] ?? [];

  // Records getters
  List<MedicalRecordModel> get medicalRecords =>
      _medicalRecordsCache[selectedPetId] ?? [];
  List<HealthMetricsModel> get healthMetrics =>
      _healthMetricsCache[selectedPetId] ?? [];
  List<VaccinationRecordModel> get vaccinationRecords =>
      _vaccinationRecordsCache[selectedPetId] ?? [];

  bool get isLoading => _isLoading;
  bool get isLoadingTips => _isLoadingTips;
  String? get error => _error;
  String? selectedPetId;
  
  // AI Tips getter
  PetTipsResponse? get currentAiTips => _aiTipsCache[selectedPetId];

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

  Future<void> deleteReminder(String reminderId) async {
    try {
      await deleteReminderUseCase(reminderId);
      await fetchReminders(selectedPetId!, forceRefresh: true);
    } catch (e) {
      print('Error deleting reminder: $e');
    }
  }

  Future<void> fetchAppointments(
    String petId, {
    bool forceRefresh = false,
  }) async {
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
      _error = 'Lỗi khi tải lịch hẹn: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Medical Records methods
  Future<void> fetchMedicalRecords(
    String petId, {
    bool forceRefresh = false,
  }) async {
    selectedPetId = petId;

    if (!forceRefresh && _medicalRecordsCache.containsKey(petId)) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await getMedicalRecordsUseCase(petId);
      result.fold((error) => _error = error, (records) {
        _medicalRecordsCache[petId] = records;
        _error = null;
      });
    } catch (e) {
      _error = 'Lỗi khi tải hồ sơ y tế: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Health Metrics methods
  Future<void> fetchHealthMetrics(
    String petId, {
    bool forceRefresh = false,
  }) async {
    selectedPetId = petId;

    if (!forceRefresh && _healthMetricsCache.containsKey(petId)) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await getHealthMetricsUseCase(petId);
      result.fold((error) => _error = error, (metrics) {
        _healthMetricsCache[petId] = metrics;
        _error = null;
      });
    } catch (e) {
      _error = 'Lỗi khi tải chỉ số sức khỏe: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Vaccination Records methods
  Future<void> fetchVaccinationRecords(
    String petId, {
    bool forceRefresh = false,
  }) async {
    selectedPetId = petId;

    if (!forceRefresh && _vaccinationRecordsCache.containsKey(petId)) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await getVaccinationRecordsUseCase(petId);
      result.fold((error) => _error = error, (records) {
        _vaccinationRecordsCache[petId] = records;
        _error = null;
      });
    } catch (e) {
      _error = 'Lỗi khi tải lịch sử tiêm chủng: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all records for a pet
  Future<void> fetchAllRecords(
    String petId, {
    bool forceRefresh = false,
  }) async {
    await Future.wait([
      fetchMedicalRecords(petId, forceRefresh: forceRefresh),
      fetchHealthMetrics(petId, forceRefresh: forceRefresh),
      fetchVaccinationRecords(petId, forceRefresh: forceRefresh),
    ]);
  }

  Future<void> updatePet(PetModel pet) async {
    await updatePetUseCase(pet);
    await fetchPets(forceRefresh: true);
    notifyListeners();
  }

  void clearCache() {
    _remindersCache.clear();
    _appointmentsCache.clear();
    _medicalRecordsCache.clear();
    _healthMetricsCache.clear();
    _vaccinationRecordsCache.clear();
    _aiTipsCache.clear();
  }

  // Helper methods for records
  List<MedicalRecordModel> getRecentMedicalRecords({int limit = 5}) {
    final records = medicalRecords;
    records.sort((a, b) => b.recordDate.compareTo(a.recordDate));
    return records.take(limit).toList();
  }

  List<HealthMetricsModel> getRecentHealthMetrics({int limit = 10}) {
    final metrics = healthMetrics;
    metrics.sort((a, b) => b.date.compareTo(a.date));
    return metrics.take(limit).toList();
  }

  List<VaccinationRecordModel> getUpcomingVaccinations() {
    final now = DateTime.now();
    return vaccinationRecords.where((record) {
      if (record.nextDueDate == null) return false;
      return record.nextDueDate!.isAfter(now) &&
          record.nextDueDate!.difference(now).inDays <= 90;
    }).toList();
  }

  List<VaccinationRecordModel> getOverdueVaccinations() {
    return vaccinationRecords.where((record) => record.isOverdue).toList();
  }

  // Health summary calculations
  double? getLatestWeight() {
    final metrics = healthMetrics;
    if (metrics.isEmpty) return null;
    metrics.sort((a, b) => b.date.compareTo(a.date));
    return metrics.first.weight;
  }

  String getHealthStatus() {
    final overdueVaccinations = getOverdueVaccinations();
    if (overdueVaccinations.isNotEmpty) {
      return 'Cần tiêm chủng';
    }

    final upcomingVaccinations = getUpcomingVaccinations();
    if (upcomingVaccinations.isNotEmpty) {
      return 'Sắp đến hạn tiêm chủng';
    }

    return 'Sức khỏe tốt';
  }

  // Add methods
  Future<void> addMedicalRecord(MedicalRecordModel record) async {
    try {
      final result = await addMedicalRecordUseCase(record);
      result.fold((error) => _error = error, (_) {
        _error = null;
        // Refresh records after adding
        if (selectedPetId != null) {
          fetchMedicalRecords(selectedPetId!, forceRefresh: true);
        }
      });
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi thêm hồ sơ y tế: $e';
      notifyListeners();
    }
  }

  Future<void> addHealthMetrics(HealthMetricsModel metrics) async {
    try {
      final result = await addHealthMetricsUseCase(metrics);
      result.fold((error) => _error = error, (_) {
        _error = null;
        // Refresh records after adding
        if (selectedPetId != null) {
          fetchHealthMetrics(selectedPetId!, forceRefresh: true);
        }
      });
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi thêm chỉ số sức khỏe: $e';
      notifyListeners();
    }
  }

  Future<void> addVaccinationRecord(VaccinationRecordModel record) async {
    try {
      final result = await addVaccinationRecordUseCase(record);
      result.fold((error) => _error = error, (_) {
        _error = null;
        // Refresh records after adding
        if (selectedPetId != null) {
          fetchVaccinationRecords(selectedPetId!, forceRefresh: true);
        }
      });
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi thêm lịch sử tiêm chủng: $e';
      notifyListeners();
    }
  }

  // AI Tips methods
  Future<void> fetchAiTips(String petId, {bool forceRefresh = false}) async {
    selectedPetId = petId;

    if (!forceRefresh && _aiTipsCache.containsKey(petId)) {
      notifyListeners();
      return;
    }

    _isLoadingTips = true;
    notifyListeners();

    try {
      final pet = _pets.firstWhere((p) => p.id == petId);
      final tipsResponse = await PetTipsService.getTipsForPet(pet);
      _aiTipsCache[petId] = tipsResponse;
      _error = null;
    } catch (e) {
      _error = 'Lỗi khi tải tips AI: $e';
    } finally {
      _isLoadingTips = false;
      notifyListeners();
    }
  }

  Future<void> refreshAiTips() async {
    if (selectedPetId != null) {
      await fetchAiTips(selectedPetId!, forceRefresh: true);
    }
  }
}
