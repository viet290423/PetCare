import '../../domain/repository/DoctorRepository.dart';
import '../model/DoctorModel.dart';
import '../model/TimeSlotModel.dart';
import '../source/DoctorDataSource.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorDataSource _dataSource;

  DoctorRepositoryImpl(this._dataSource);

  @override
  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      return await _dataSource.getAllDoctors();
    } catch (e) {
      throw Exception('Failed to fetch doctors: $e');
    }
  }

  @override
  Future<List<DoctorModel>> getDoctorsBySpecialization(
    String specialization,
  ) async {
    try {
      final allDoctors = await _dataSource.getAllDoctors();
      return allDoctors
          .where((doctor) => doctor.specializations.contains(specialization))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch doctors by specialization: $e');
    }
  }

  @override
  Future<List<DoctorModel>> getDoctorsByService(String serviceId) async {
    try {
      final allDoctors = await _dataSource.getAllDoctors();
      return allDoctors
          .where((doctor) => doctor.canPerformService(serviceId))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch doctors by service: $e');
    }
  }

  @override
  Future<DoctorModel?> getDoctorById(String doctorId) async {
    try {
      final allDoctors = await _dataSource.getAllDoctors();
      return allDoctors.firstWhere((doctor) => doctor.id == doctorId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DoctorModel?> getDoctorByUserId(String userId) async {
    try {
      return await _dataSource.getDoctorByUserId(userId);
    } catch (e) {
      throw Exception('Failed to fetch doctor by user ID: $e');
    }
  }

  @override
  Future<List<TimeSlotModel>> getAvailableTimeSlots(
    String doctorId,
    DateTime date,
  ) async {
    try {
      return await _dataSource.getAvailableTimeSlots(doctorId, date);
    } catch (e) {
      throw Exception('Failed to fetch available time slots: $e');
    }
  }

  @override
  Future<bool> checkDoctorAvailability(
    String doctorId,
    DateTime date,
    String timeSlot,
  ) async {
    try {
      final timeSlots = await _dataSource.getAvailableTimeSlots(doctorId, date);
      return timeSlots.any(
        (slot) =>
            slot.startTime == timeSlot && slot.isAvailable && !slot.isInPast(),
      );
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<DoctorModel>> searchDoctors(String query) async {
    try {
      final allDoctors = await _dataSource.getAllDoctors();
      return allDoctors
          .where(
            (doctor) =>
                doctor.name.toLowerCase().contains(query.toLowerCase()) ||
                doctor.specialization.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                doctor.specializations.any(
                  (spec) => spec.toLowerCase().contains(query.toLowerCase()),
                ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search doctors: $e');
    }
  }
}
