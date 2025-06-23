import 'package:flutter/foundation.dart';
import 'package:petcare/domain/usecase/doctor/GetAllDoctorUseCase.dart';
import '../../../data/model/DoctorModel.dart';
import '../../../data/model/TimeSlotModel.dart';
import '../../../domain/usecase/doctor/GetDoctorsByServiceUseCase.dart';
import '../../../domain/usecase/doctor/GetAvailableTimeSlotsUseCase.dart';

class DoctorViewModel extends ChangeNotifier {
  final GetAllDoctorUseCase _getAllDoctorUseCase;
  final GetDoctorsByServiceUseCase _getDoctorsByServiceUseCase;
  final GetAvailableTimeSlotsUseCase _getAvailableTimeSlotsUseCase;

  List<DoctorModel> _doctors = [];
  List<TimeSlotModel> _availableTimeSlots = [];
  bool _isLoading = false;
  String? _error;

  List<DoctorModel> get doctors => _doctors;

  List<TimeSlotModel> get availableTimeSlots => _availableTimeSlots;

  bool get isLoading => _isLoading;

  String? get error => _error;

  DoctorViewModel({
    required GetAllDoctorUseCase getAllDoctorUseCase,
    required GetDoctorsByServiceUseCase getDoctorsByServiceUseCase,
    required GetAvailableTimeSlotsUseCase getAvailableTimeSlotsUseCase,
  }) : _getAllDoctorUseCase = getAllDoctorUseCase,
       _getDoctorsByServiceUseCase = getDoctorsByServiceUseCase,
       _getAvailableTimeSlotsUseCase = getAvailableTimeSlotsUseCase;

  Future<void> fetchDoctors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _doctors = await _getAllDoctorUseCase.execute();
    } catch (e) {
      _error = 'Không thể tải danh sách bác sĩ: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getDoctorsByService(String serviceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _doctors = await _getDoctorsByServiceUseCase.execute(serviceId);
    } catch (e) {
      _error = 'Không thể tải danh sách bác sĩ: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAvailableTimeSlots(String doctorId, DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableTimeSlots = await _getAvailableTimeSlotsUseCase.execute(
        doctorId,
        date,
      );
    } catch (e) {
      _error = 'Không thể tải lịch làm việc: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<DoctorModel> getDoctorsBySpecialization(String specialization) {
    return _doctors
        .where((doctor) => doctor.specializations.contains(specialization))
        .toList();
  }

  List<DoctorModel> searchDoctors(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _doctors
        .where(
          (doctor) =>
              doctor.name.toLowerCase().contains(lowercaseQuery) ||
              doctor.specialization.toLowerCase().contains(lowercaseQuery) ||
              doctor.specializations.any(
                (spec) => spec.toLowerCase().contains(lowercaseQuery),
              ) ||
              doctor.description.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  // Lọc bác sĩ có sẵn
  List<DoctorModel> getAvailableDoctors() {
    return _doctors.where((doctor) => doctor.isAvailable).toList();
  }

  // Lọc bác sĩ theo ngày làm việc
  List<DoctorModel> getDoctorsByWorkingDay(String dayOfWeek) {
    return _doctors
        .where((doctor) => doctor.isWorkingOnDay(dayOfWeek))
        .toList();
  }
}
