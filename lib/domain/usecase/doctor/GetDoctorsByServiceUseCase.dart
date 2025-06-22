import '../../../domain/repository/DoctorRepository.dart';
import '../../../data/model/DoctorModel.dart';

class GetDoctorsByServiceUseCase {
  final DoctorRepository _repository;

  GetDoctorsByServiceUseCase(this._repository);

  Future<List<DoctorModel>> execute(String serviceId) async {
    return await _repository.getDoctorsByService(serviceId);
  }
}
