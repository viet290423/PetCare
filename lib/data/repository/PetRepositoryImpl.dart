import '../../domain/repository/PetRepository.dart';
import '../model/AppointmentModel.dart';
import '../model/HealthStatusModel.dart';
import '../model/PetModel.dart';
import '../model/ReminderModel.dart';
import '../source/PetDataSource.dart';

class PetRepositoryImpl implements PetRepository {
  final PetDataSource petDataSource;

  PetRepositoryImpl(this.petDataSource);

  @override
  Future<List<PetModel>> getPets() {
    return petDataSource.getPets();
  }

  @override
  Future<void> addPet(PetModel pet) {
    return petDataSource.addPet(pet);
  }

  @override
  Future<HealthStatusModel> getHealthStatus(String petId) {
    return petDataSource.getHealthStatus(petId);
  }

  @override
  Future<List<Map<String, dynamic>>> getProductSuggestions() {
    return petDataSource.getProductSuggestions();
  }

  @override
  Future<void> addReminder(ReminderModel reminder) {
    return petDataSource.addReminder(reminder);
  }

  @override
  Future<List<ReminderModel>> getRemindersByPet(String petId) {
    print('PetRepositoryImpl: Getting reminders for petId: $petId');
    return petDataSource.getRemindersByPet(petId);
  }

  @override
  Future<void> addAppointment(AppointmentModel appointment) {
    return petDataSource.addAppointment(appointment);
  }

  @override
  Future<void> deleteReminder(String reminderId) {
    return petDataSource.deleteReminder(reminderId);
  }

  @override
  Future<void> updatePet(PetModel pet) {
    return petDataSource.updatePet(pet);
  }
}
