import '../../../domain/repository/DoctorRepository.dart';
import '../../../data/model/TimeSlotModel.dart';

class GetAvailableTimeSlotsUseCase {
  final DoctorRepository _repository;

  GetAvailableTimeSlotsUseCase(this._repository);

  Future<List<TimeSlotModel>> execute(String doctorId, DateTime date) async {
    return await _repository.getAvailableTimeSlots(doctorId, date);
  }
}
