import '../../data/model/DoctorModel.dart';
import '../../data/model/TimeSlotModel.dart';

abstract class DoctorRepository {
  Future<List<DoctorModel>> getAllDoctors();
  Future<List<DoctorModel>> getDoctorsBySpecialization(String specialization);
  Future<List<DoctorModel>> getDoctorsByService(String serviceId);
  Future<DoctorModel?> getDoctorById(String doctorId);
  Future<DoctorModel?> getDoctorByUserId(String userId);
  Future<List<TimeSlotModel>> getAvailableTimeSlots(
    String doctorId,
    DateTime date,
  );
  Future<bool> checkDoctorAvailability(
    String doctorId,
    DateTime date,
    String timeSlot,
  );
  Future<List<DoctorModel>> searchDoctors(String query);
}
