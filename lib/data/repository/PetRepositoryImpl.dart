import '../../domain/repository/PetRepository.dart';
import '../model/AppointmentModel.dart';
import '../model/HealthStatusModel.dart';
import '../model/PetModel.dart';
import '../model/ReminderModel.dart';
import '../model/MedicalRecordModel.dart';
import '../model/HealthMetricsModel.dart';
import '../model/VaccinationRecordModel.dart';
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

  // Medical Records Implementation
  @override
  Future<List<MedicalRecordModel>> getMedicalRecords(String petId) {
    return petDataSource.getMedicalRecords(petId);
  }

  @override
  Future<void> addMedicalRecord(MedicalRecordModel record) {
    return petDataSource.addMedicalRecord(record);
  }

  @override
  Future<void> updateMedicalRecord(MedicalRecordModel record) {
    return petDataSource.updateMedicalRecord(record);
  }

  @override
  Future<void> deleteMedicalRecord(String recordId) {
    return petDataSource.deleteMedicalRecord(recordId);
  }

  // Health Metrics Implementation
  @override
  Future<List<HealthMetricsModel>> getHealthMetrics(String petId) {
    return petDataSource.getHealthMetrics(petId);
  }

  @override
  Future<void> addHealthMetrics(HealthMetricsModel metrics) {
    return petDataSource.addHealthMetrics(metrics);
  }

  @override
  Future<void> updateHealthMetrics(HealthMetricsModel metrics) {
    return petDataSource.updateHealthMetrics(metrics);
  }

  @override
  Future<void> deleteHealthMetrics(String metricsId) {
    return petDataSource.deleteHealthMetrics(metricsId);
  }

  // Vaccination Records Implementation
  @override
  Future<List<VaccinationRecordModel>> getVaccinationRecords(String petId) {
    return petDataSource.getVaccinationRecords(petId);
  }

  @override
  Future<void> addVaccinationRecord(VaccinationRecordModel record) {
    return petDataSource.addVaccinationRecord(record);
  }

  @override
  Future<void> updateVaccinationRecord(VaccinationRecordModel record) {
    return petDataSource.updateVaccinationRecord(record);
  }

  @override
  Future<void> deleteVaccinationRecord(String recordId) {
    return petDataSource.deleteVaccinationRecord(recordId);
  }
}
