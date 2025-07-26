import 'package:dartz/dartz.dart';
import '../../../data/model/MedicalRecordModel.dart';
import '../../repository/PetRepository.dart';

class GetMedicalRecordsUseCase {
  final PetRepository repository;

  GetMedicalRecordsUseCase(this.repository);

  Future<Either<String, List<MedicalRecordModel>>> call(String petId) async {
    try {
      final records = await repository.getMedicalRecords(petId);
      return Right(records);
    } catch (e) {
      return Left(e.toString());
    }
  }
} 