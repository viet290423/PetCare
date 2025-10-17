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
  String? _aiTipsError;
  // AI tips cache signatures & timestamps
  final Map<String, String> _aiTipsSignatureByPet = {};
  final Map<String, DateTime> _aiTipsUpdatedAt = {};
  final Duration _aiCacheTtl = const Duration(hours: 24);

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
  String? get tipsError => _aiTipsError;
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
    // Giữ lại AI caches để tránh gọi AI lại không cần thiết khi vào màn hình
    // Nếu cần làm mới thủ công, dùng refreshAiTips() hoặc clearGrowthTipsCache()
  }

  Future<void> deletePet(String petId) async {
    try {
      await Supabase.instance.client.from('pets').delete().eq('id', petId);

      // Xóa khỏi danh sách local
      _pets.removeWhere((p) => p.id == petId);

      // Xóa caches liên quan
      _remindersCache.remove(petId);
      _appointmentsCache.remove(petId);
      _medicalRecordsCache.remove(petId);
      _healthMetricsCache.remove(petId);
      _vaccinationRecordsCache.remove(petId);
      _aiTipsCache.remove(petId);
      _aiTipsSignatureByPet.remove(petId);
      _aiTipsUpdatedAt.remove(petId);
      _growthTipsCache.remove(petId);
      _growthSignatureByPet.remove(petId);
      _growthUpdatedAt.remove(petId);

      // Điều chỉnh selectedPetId
      if (selectedPetId == petId) {
        selectedPetId = _pets.isNotEmpty ? _pets.first.id : null;
      }

      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi xóa thú cưng: $e';
      notifyListeners();
      rethrow;
    }
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
    if (selectedPetId != null) {
      _invalidateAiCaches(selectedPetId!);
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
    if (selectedPetId != null) {
      _invalidateAiCaches(selectedPetId!);
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
    if (selectedPetId != null) {
      _invalidateAiCaches(selectedPetId!);
    }
  }

  // AI Tips methods
  Future<void> fetchAiTips(String petId, {bool forceRefresh = false}) async {
    selectedPetId = petId;

    // Cache by signature + TTL
    if (_pets.isEmpty) {
      // Không có dữ liệu thú cưng, tránh gọi AI vô ích
      return;
    }
    final pet = _pets.firstWhere((p) => p.id == petId, orElse: () => _pets.first);
    final currentSignature = _buildTipsSignature(pet);
    final lastSignature = _aiTipsSignatureByPet[petId];
    final lastUpdatedAt = _aiTipsUpdatedAt[petId];
    final notExpired = lastUpdatedAt != null && DateTime.now().difference(lastUpdatedAt) < _aiCacheTtl;
    if (!forceRefresh && _aiTipsCache.containsKey(petId) && lastSignature == currentSignature && notExpired) {
      notifyListeners();
      return;
    }

    _isLoadingTips = true;
    _aiTipsError = null;
    notifyListeners();

    try {
      final tipsResponse = await PetTipsService.getTipsForPet(pet);
      _aiTipsCache[petId] = tipsResponse;
      _aiTipsSignatureByPet[petId] = currentSignature;
      _aiTipsUpdatedAt[petId] = DateTime.now();
      _aiTipsError = null;
    } catch (e) {
      // Không set _error để tránh làm sập toàn màn hình
      _aiTipsError = 'failed';
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

  // Growth tips related
  final Map<String, PetGrowthResponse> _growthTipsCache = {};
  bool _isLoadingGrowthTips = false;
  // Growth tips cache signatures & timestamps
  final Map<String, String> _growthSignatureByPet = {};
  final Map<String, DateTime> _growthUpdatedAt = {};
  final Duration _growthCacheTtl = const Duration(hours: 12);

  bool get isLoadingGrowthTips => _isLoadingGrowthTips;

  PetGrowthResponse? get currentGrowthTips {
    if (selectedPetId == null) return null;
    return _growthTipsCache[selectedPetId!];
  }

  /// Phát hiện thay đổi cân nặng bất thường
  bool _hasAbnormalWeightChange(List<HealthMetricsModel> metrics) {
    if (metrics.length < 2) return false;

    final weights = metrics
        .where((m) => m.weight != null)
        .map((m) => m.weight!)
        .toList();

    if (weights.length < 2) return false;

    // Kiểm tra thay đổi đột ngột (>10% trong 1 lần đo)
    final latest = weights.last;
    final previous = weights[weights.length - 2];
    final suddenChangePercent = ((latest - previous) / previous).abs();

    if (suddenChangePercent > 0.1) {
      return true; // Thay đổi đột ngột
    }

    // Kiểm tra xu hướng dài hạn (nếu có ít nhất 3 điểm dữ liệu)
    if (weights.length >= 3) {
      return _hasUnsafeWeightTrend(weights);
    }

    return false;
  }

  /// Phát hiện xu hướng cân nặng không an toàn
  bool _hasUnsafeWeightTrend(List<double> weights) {
    if (weights.length < 3) return false;

    // Tính xu hướng tăng/giảm đều
    final trend = _calculateWeightTrend(weights);
    final totalChangePercent = ((weights.last - weights.first) / weights.first).abs();

    // Ngưỡng an toàn: tăng/giảm > 15% trong thời gian dài
    if (totalChangePercent > 0.15 && trend.abs() > 0.02) {
      return true;
    }

    return false;
  }

  /// Tính xu hướng cân nặng (dương = tăng, âm = giảm)
  double _calculateWeightTrend(List<double> weights) {
    if (weights.length < 2) return 0.0;

    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    int n = weights.length;

    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += weights[i];
      sumXY += i * weights[i];
      sumXX += i * i;
    }

    // Tính hệ số góc của đường thẳng hồi quy
    double slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    return slope;
  }

  /// Lấy lịch sử cân nặng từ health metrics
  List<double> _getWeightHistory(List<HealthMetricsModel> metrics) {
    return metrics
        .where((m) => m.weight != null)
        .map((m) => m.weight!)
        .toList();
  }

  /// Fetch growth tips nếu có thay đổi cân nặng bất thường
  Future<void> checkAndFetchGrowthTips(String petId) async {
    final metrics = healthMetrics.where((m) => m.petId == petId).toList();

    if (!_hasAbnormalWeightChange(metrics)) {
      return; // Không có thay đổi bất thường, không cần fetch
    }

    // Cache by signature + TTL
    final growthSignature = _buildGrowthSignature(metrics);
    final lastSignature = _growthSignatureByPet[petId];
    final lastUpdatedAt = _growthUpdatedAt[petId];
    final notExpired = lastUpdatedAt != null && DateTime.now().difference(lastUpdatedAt) < _growthCacheTtl;
    if (lastSignature == growthSignature && notExpired && _growthTipsCache.containsKey(petId)) {
      notifyListeners();
      return;
    }

    _isLoadingGrowthTips = true;
    notifyListeners();

    try {
      final pet = _pets.firstWhere((p) => p.id == petId);
      final weightHistory = _getWeightHistory(metrics);
      final warningType = _getWeightWarningType(metrics);
      final growthResponse = await PetTipsService.getGrowthTipsForPet(pet, weightHistory, warningType);
      _growthTipsCache[petId] = growthResponse;
      _growthSignatureByPet[petId] = growthSignature;
      _growthUpdatedAt[petId] = DateTime.now();
      _error = null;
    } catch (e) {
      _error = 'Lỗi khi tải growth tips: $e';
    } finally {
      _isLoadingGrowthTips = false;
      notifyListeners();
    }
  }

  /// Xác định loại cảnh báo cân nặng
  String _getWeightWarningType(List<HealthMetricsModel> metrics) {
    final weights = metrics
        .where((m) => m.weight != null)
        .map((m) => m.weight!)
        .toList();

    if (weights.length < 2) return 'normal';

    // Kiểm tra thay đổi đột ngột
    final latest = weights.last;
    final previous = weights[weights.length - 2];
    final suddenChangePercent = ((latest - previous) / previous).abs();

    if (suddenChangePercent > 0.1) {
      return latest > previous ? 'sudden_increase' : 'sudden_decrease';
    }

    // Kiểm tra xu hướng dài hạn
    if (weights.length >= 3) {
      final trend = _calculateWeightTrend(weights);
      final totalChangePercent = ((weights.last - weights.first) / weights.first).abs();

      if (totalChangePercent > 0.15 && trend.abs() > 0.02) {
        return trend > 0 ? 'gradual_increase' : 'gradual_decrease';
      }
    }

    return 'normal';
  }

  /// Clear growth tips cache
  void clearGrowthTipsCache() {
    _growthTipsCache.clear();
    _growthSignatureByPet.clear();
    _growthUpdatedAt.clear();
  }

  // ===== Helpers for AI cache/signature =====
  void _invalidateAiCaches(String petId) {
    _aiTipsSignatureByPet.remove(petId);
    _aiTipsUpdatedAt.remove(petId);
    _growthSignatureByPet.remove(petId);
    _growthUpdatedAt.remove(petId);
  }

  String _buildTipsSignature(PetModel pet) {
    final species = (pet.species ?? pet.type).toLowerCase();
    final ageMonths = _estimateAgeMonths(pet);
    final weight = pet.weightKg ?? _tryParseWeightToKg(pet.weight);
    final conditions = (pet.healthConditions ?? []).map((e) => e.toLowerCase()).toList()..sort();
    return 's:' + species + '|a:' + ageMonths.toString() + '|w:' + (weight?.toStringAsFixed(2) ?? '0') + '|c:' + conditions.join(',');
  }

  String _buildGrowthSignature(List<HealthMetricsModel> metrics) {
    final weights = _getWeightHistory(metrics);
    final lastN = weights.length > 6 ? weights.sublist(weights.length - 6) : weights;
    final trend = _calculateWeightTrend(lastN);
    final totalChange = lastN.length >= 2 ? (lastN.last - lastN.first) : 0.0;
    return 'w:' + lastN.map((e)=>e.toStringAsFixed(2)).join(',') + '|t:' + trend.toStringAsFixed(4) + '|d:' + totalChange.toStringAsFixed(2);
  }

  int _estimateAgeMonths(PetModel pet) {
    final now = DateTime.now();
    DateTime? birthDate = pet.birthDateObj;
    if (birthDate == null && pet.birthDate.isNotEmpty) {
      try {
        birthDate = DateTime.parse(pet.birthDate);
      } catch (_) {}
    }
    if (birthDate == null) return 0;
    return (now.difference(birthDate).inDays / 30).round();
  }

  double? _tryParseWeightToKg(String v) {
    if (v.isEmpty) return null;
    try {
      String s = v.trim().toLowerCase().replaceAll(',', '.');
      bool isGram = s.contains(' g') || s.endsWith('g');
      final match = RegExp(r"[-+]?[0-9]*\.?[0-9]+").firstMatch(s);
      if (match == null) return null;
      final value = double.parse(match.group(0)!);
      return isGram ? value / 1000.0 : value;
    } catch (_) {
      return null;
    }
  }
}
