import 'package:dartz/dartz.dart';

import '../../../data/model/AppointmentModel.dart';
import '../../repository/PetRepository.dart';

class AddAppointmentUseCase {
  final PetRepository repository;

  AddAppointmentUseCase(this.repository);

  Future<Either<String, void>> call(AppointmentModel appointment) async {
    try {
      await repository.addAppointment(appointment);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}