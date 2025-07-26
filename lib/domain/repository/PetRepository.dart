import 'package:petcare/data/model/ReminderModel.dart';

import '../../data/model/AppointmentModel.dart';
import '../../data/model/HealthStatusModel.dart';
import '../../data/model/PetModel.dart';
import '../../data/model/MedicalRecordModel.dart';
import '../../data/model/HealthMetricsModel.dart';
import '../../data/model/VaccinationRecordModel.dart';

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

  // Medical Records
  Future<List<MedicalRecordModel>> getMedicalRecords(String petId);
  Future<void> addMedicalRecord(MedicalRecordModel record);
  Future<void> updateMedicalRecord(MedicalRecordModel record);
  Future<void> deleteMedicalRecord(String recordId);

  // Health Metrics
  Future<List<HealthMetricsModel>> getHealthMetrics(String petId);
  Future<void> addHealthMetrics(HealthMetricsModel metrics);
  Future<void> updateHealthMetrics(HealthMetricsModel metrics);
  Future<void> deleteHealthMetrics(String metricsId);

  // Vaccination Records
  Future<List<VaccinationRecordModel>> getVaccinationRecords(String petId);
  Future<void> addVaccinationRecord(VaccinationRecordModel record);
  Future<void> updateVaccinationRecord(VaccinationRecordModel record);
  Future<void> deleteVaccinationRecord(String recordId);
}
