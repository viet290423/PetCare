import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/AppointmentModel.dart';
import '../model/HealthStatusModel.dart';
import '../model/PetModel.dart';
import '../model/ReminderModel.dart';
import '../model/MedicalRecordModel.dart';
import '../model/HealthMetricsModel.dart';
import '../model/VaccinationRecordModel.dart';

abstract class PetDataSource {
  Future<List<PetModel>> getPets();

  Future<void> addPet(PetModel pet);

  Future<HealthStatusModel> getHealthStatus(String petId);

  Future<List<Map<String, dynamic>>> getProductSuggestions();

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

class PetDataSourceImpl implements PetDataSource {
  final SupabaseClient client;

  PetDataSourceImpl(this.client);

  @override
  Future<List<PetModel>> getPets() async {
    final user = client.auth.currentUser;
    final response = await client
        .from('pets')
        .select()
        .eq('user_id', user?.id as Object)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => _createPetModelFromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addPet(PetModel pet) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('Người dùng chưa đăng nhập');

    final data = {...pet.toJson(), 'user_id': userId};

    try {
      await client.from('pets').insert(data);
    } catch (e) {
      throw Exception('Thêm thú cưng thất bại: ${e.toString()}');
    }
  }

  @override
  Future<HealthStatusModel> getHealthStatus(String petId) async {
    final response = await client
        .from('health')
        .select()
        .eq('pet_id', petId)
        .order('lastVaccination', ascending: false)
        .limit(1);

    if (response.isNotEmpty) {
      return HealthStatusModel.fromJson(response.first);
    }
    return HealthStatusModel(
      weight: 0,
      lastVaccination: DateTime.now(),
      note: '',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getProductSuggestions() async {
    final response = await client.from('products').select().limit(2);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> addReminder(ReminderModel reminder) async {
    try {
      await client.from('reminders').insert(reminder.toJson());
    } catch (e) {
      throw Exception("Lỗi khi thêm nhắc nhở: $e");
    }
  }

  @override
  Future<List<ReminderModel>> getRemindersByPet(String petId) async {
    print('PetDataSource: Getting reminders for petId: $petId');
    try {
      final response = await client
          .from('reminders')
          .select()
          .eq('pet_id', petId)
          .order('date_time');
      print('PetDataSource: Got ${response.length} reminders from database');
      return (response as List).map((e) => ReminderModel.fromJson(e)).toList();
    } catch (e) {
      print('PetDataSource: Error getting reminders: $e');
      throw Exception("Lỗi khi lấy danh sách nhắc nhở: $e");
    }
  }

  Future<void> addAppointment(AppointmentModel appointment) async {
    try {
      await client.from('appointments').insert(appointment.toJson());
    } catch (e) {
      throw Exception('Lỗi khi thêm lịch hẹn: $e');
    }
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    try {
      await client.from('reminders').delete().eq('id', reminderId);
    } catch (e) {
      throw Exception('Lỗi khi xóa nhắc nhở: $e');
    }
  }

  @override
  Future<void> updatePet(PetModel pet) async {
    try {
      await client.from('pets').update(pet.toJson()).eq('id', pet.id);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật thú cưng: $e');
    }
  }

  // Medical Records Implementation
  @override
  Future<List<MedicalRecordModel>> getMedicalRecords(String petId) async {
    try {
      final response = await client
          .from('medical_records')
          .select()
          .eq('pet_id', petId)
          .order('record_date', ascending: false);

      return (response as List)
          .map(
            (item) => MedicalRecordModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy hồ sơ y tế: $e');
    }
  }

  @override
  Future<void> addMedicalRecord(MedicalRecordModel record) async {
    try {
      await client.from('medical_records').insert(record.toJson());
    } catch (e) {
      throw Exception('Lỗi khi thêm hồ sơ y tế: $e');
    }
  }

  @override
  Future<void> updateMedicalRecord(MedicalRecordModel record) async {
    try {
      await client
          .from('medical_records')
          .update(record.toJson())
          .eq('id', record.id);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật hồ sơ y tế: $e');
    }
  }

  @override
  Future<void> deleteMedicalRecord(String recordId) async {
    try {
      await client.from('medical_records').delete().eq('id', recordId);
    } catch (e) {
      throw Exception('Lỗi khi xóa hồ sơ y tế: $e');
    }
  }

  // Health Metrics Implementation
  @override
  Future<List<HealthMetricsModel>> getHealthMetrics(String petId) async {
    try {
      final response = await client
          .from('health_metrics')
          .select()
          .eq('pet_id', petId)
          .order('date', ascending: false);

      return (response as List)
          .map(
            (item) => HealthMetricsModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy chỉ số sức khỏe: $e');
    }
  }

  @override
  Future<void> addHealthMetrics(HealthMetricsModel metrics) async {
    try {
      await client.from('health_metrics').insert(metrics.toJson());
    } catch (e) {
      throw Exception('Lỗi khi thêm chỉ số sức khỏe: $e');
    }
  }

  @override
  Future<void> updateHealthMetrics(HealthMetricsModel metrics) async {
    try {
      await client
          .from('health_metrics')
          .update(metrics.toJson())
          .eq('id', metrics.id);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật chỉ số sức khỏe: $e');
    }
  }

  @override
  Future<void> deleteHealthMetrics(String metricsId) async {
    try {
      await client.from('health_metrics').delete().eq('id', metricsId);
    } catch (e) {
      throw Exception('Lỗi khi xóa chỉ số sức khỏe: $e');
    }
  }

  // Vaccination Records Implementation
  @override
  Future<List<VaccinationRecordModel>> getVaccinationRecords(
    String petId,
  ) async {
    try {
      final response = await client
          .from('vaccination_records')
          .select()
          .eq('pet_id', petId)
          .order('vaccination_date', ascending: false);

      return (response as List)
          .map(
            (item) =>
                VaccinationRecordModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy lịch sử tiêm chủng: $e');
    }
  }

  @override
  Future<void> addVaccinationRecord(VaccinationRecordModel record) async {
    try {
      await client.from('vaccination_records').insert(record.toJson());
    } catch (e) {
      throw Exception('Lỗi khi thêm lịch sử tiêm chủng: $e');
    }
  }

  @override
  Future<void> updateVaccinationRecord(VaccinationRecordModel record) async {
    try {
      await client
          .from('vaccination_records')
          .update(record.toJson())
          .eq('id', record.id);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật lịch sử tiêm chủng: $e');
    }
  }

  @override
  Future<void> deleteVaccinationRecord(String recordId) async {
    try {
      await client.from('vaccination_records').delete().eq('id', recordId);
    } catch (e) {
      throw Exception('Lỗi khi xóa lịch sử tiêm chủng: $e');
    }
  }

  /// Helper method để tạo PetModel với các trường mới cho AI tips
  PetModel _createPetModelFromJson(Map<String, dynamic> json) {
    // Parse birthDate từ string thành DateTime
    DateTime? birthDateObj;
    if (json['birthDate'] != null && json['birthDate'].toString().isNotEmpty) {
      try {
        birthDateObj = DateTime.parse(json['birthDate']);
      } catch (e) {
        print('Error parsing birthDate: $e');
      }
    }

    // Parse weight từ string thành double
    double? weightKg;
    if (json['weight'] != null && json['weight'].toString().isNotEmpty) {
      try {
        weightKg = double.parse(json['weight'].toString());
      } catch (e) {
        print('Error parsing weight: $e');
      }
    }

    // Parse healthConditions từ JSON array
    List<String>? healthConditions;
    if (json['healthConditions'] != null) {
      try {
        healthConditions = List<String>.from(json['healthConditions']);
      } catch (e) {
        print('Error parsing healthConditions: $e');
      }
    }

    return PetModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      breed: json['breed'] ?? '',
      birthDate: json['birthDate'] ?? '',
      gender: json['gender'] ?? '',
      weight: json['weight'] ?? '',
      color: json['color'] ?? '',
      species: json['species'],
      weightKg: weightKg,
      birthDateObj: birthDateObj,
      healthConditions: healthConditions,
    );
  }
}
