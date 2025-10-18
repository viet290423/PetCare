import 'package:dartz/dartz.dart';
import '../../../data/model/MedicalRecordModel.dart';
import '../../repository/PetRepository.dart';

class UpdateMedicalRecordUseCase {
  final PetRepository repository;

  UpdateMedicalRecordUseCase(this.repository);

  Future<Either<String, void>> call(MedicalRecordModel record) async {
    try {
      await repository.updateMedicalRecord(record);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
