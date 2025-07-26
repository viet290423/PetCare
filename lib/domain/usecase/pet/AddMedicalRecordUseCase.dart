import 'package:dartz/dartz.dart';
import '../../../data/model/MedicalRecordModel.dart';
import '../../repository/PetRepository.dart';

class AddMedicalRecordUseCase {
  final PetRepository repository;

  AddMedicalRecordUseCase(this.repository);

  Future<Either<String, void>> call(MedicalRecordModel record) async {
    try {
      await repository.addMedicalRecord(record);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
