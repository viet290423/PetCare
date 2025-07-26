import 'package:dartz/dartz.dart';
import '../../../data/model/VaccinationRecordModel.dart';
import '../../repository/PetRepository.dart';

class GetVaccinationRecordsUseCase {
  final PetRepository repository;

  GetVaccinationRecordsUseCase(this.repository);

  Future<Either<String, List<VaccinationRecordModel>>> call(
    String petId,
  ) async {
    try {
      final records = await repository.getVaccinationRecords(petId);
      return Right(records);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
