import 'package:petcare/data/model/ReminderModel.dart';

import '../../data/model/AppointmentModel.dart';
import '../../data/model/HealthStatusModel.dart';
import '../../data/model/PetModel.dart';

abstract class PetRepository {
  Future<List<PetModel>> getPets();

  Future<HealthStatusModel> getHealthStatus(String petId);

  Future<List<Map<String, dynamic>>> getProductSuggestions();

  Future<void> addPet(PetModel pet);

  Future<void> addReminder(ReminderModel reminder);

  Future<List<ReminderModel>> getRemindersByPet(String petId);

  Future<void> addAppointment(AppointmentModel appointment);

  Future<void> deleteReminder(String reminderId);
  Future<void> updatePet(PetModel pet);
}
