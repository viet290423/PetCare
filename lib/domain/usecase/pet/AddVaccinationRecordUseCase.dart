import 'package:dartz/dartz.dart';
import '../../../data/model/VaccinationRecordModel.dart';
import '../../repository/PetRepository.dart';

class AddVaccinationRecordUseCase {
  final PetRepository repository;

  AddVaccinationRecordUseCase(this.repository);

  Future<Either<String, void>> call(VaccinationRecordModel record) async {
    try {
      await repository.addVaccinationRecord(record);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
