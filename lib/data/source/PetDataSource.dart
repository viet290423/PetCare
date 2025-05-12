import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/HealthStatusModel.dart';
import '../model/PetModel.dart';
import '../model/ReminderModel.dart';

abstract class PetDataSource {
  Future<List<PetModel>> getPets();

  Future<void> addPet(PetModel pet);

  Future<HealthStatusModel> getHealthStatus(String petId);

  Future<List<Map<String, dynamic>>> getProductSuggestions();

  Future<void> addReminder(ReminderModel reminder);

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
        .map((item) => PetModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addPet(PetModel pet) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('Người dùng chưa đăng nhập');

    final data = {
      ...pet.toJson(),
      'user_id': userId,
    };

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
    final response = await client.from('reminders').insert(reminder.toJson());

    if (response == null) {
      throw Exception("Lỗi khi thêm nhắc nhở");
    }
  }
}
