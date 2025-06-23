import '../../../data/model/DoctorModel.dart';
import '../../../domain/repository/DoctorRepository.dart';

class GetAllDoctorUseCase {
  final DoctorRepository repository;

  GetAllDoctorUseCase(this.repository);

  Future<List<DoctorModel>> execute() async {
    return await repository.getAllDoctors();
  }
}
