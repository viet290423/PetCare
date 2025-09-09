import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/model/PetTipsModel.dart';
import '../data/model/PetModel.dart';

class PetTipsService {
  static const String _baseUrl = 'https://pet-care-tips-8gwe96yjt-viet290423s-projects.vercel.app/api';
  
  /// Gọi API để lấy tips chăm sóc thú cưng từ AI
  static Future<PetTipsResponse> getPetTips({
    required String name,
    required String species,
    required int ageMonths,
    required double weightKg,
    required List<String> conditions,
  }) async {
    try {
      final request = PetTipsRequest(
        name: name,
        species: species,
        ageMonths: ageMonths,
        weightKg: weightKg,
        conditions: conditions,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/pet_tips'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PetTipsResponse.fromJson(data);
      } else {
        throw Exception('Failed to get pet tips: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting pet tips: $e');
    }
  }

  /// Tạo PetTipsRequest từ PetModel
  static PetTipsRequest createRequestFromPet(PetModel pet) {
    // Tính tuổi theo tháng từ ngày sinh
    final now = DateTime.now();
    int ageMonths = 0;
    
    // Sử dụng birthDateObj nếu có, nếu không thì parse từ birthDate string
    DateTime? birthDate;
    if (pet.birthDateObj != null) {
      birthDate = pet.birthDateObj;
    } else if (pet.birthDate.isNotEmpty) {
      try {
        birthDate = DateTime.parse(pet.birthDate);
      } catch (e) {
        print('Error parsing birthDate: $e');
      }
    }
    
    if (birthDate != null) {
      ageMonths = ((now.difference(birthDate).inDays) / 30).round();
    }

    // Lấy các điều kiện sức khỏe từ pet (nếu có)
    List<String> conditions = [];
    if (pet.healthConditions != null && pet.healthConditions!.isNotEmpty) {
      conditions = pet.healthConditions!;
    }

    // Sử dụng species nếu có, nếu không thì dùng type
    String species = pet.species ?? pet.type.toLowerCase();

    // Sử dụng weightKg nếu có, nếu không thì parse từ weight string
    double weightKg = pet.weightKg ?? 0.0;
    if (weightKg == 0.0 && pet.weight.isNotEmpty) {
      try {
        weightKg = double.parse(pet.weight);
      } catch (e) {
        print('Error parsing weight: $e');
      }
    }

    return PetTipsRequest(
      name: pet.name,
      species: species,
      ageMonths: ageMonths,
      weightKg: weightKg,
      conditions: conditions,
    );
  }

  /// Lấy tips cho thú cưng dựa trên thông tin hiện tại
  static Future<PetTipsResponse> getTipsForPet(PetModel pet) async {
    final request = createRequestFromPet(pet);
    return await getPetTips(
      name: request.name,
      species: request.species,
      ageMonths: request.ageMonths,
      weightKg: request.weightKg,
      conditions: request.conditions,
    );
  }
}
