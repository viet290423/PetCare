import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/model/PetTipsModel.dart';
import '../data/model/PetModel.dart';

class PetTipsService {
  static const String _baseUrl = 'https://pet-care-tips-74ziv4kru-viet290423s-projects.vercel.app/api';
  
  /// Gọi API để lấy tips chăm sóc thú cưng từ AI
  static Future<PetTipsResponse> getPetTips({
    required String name,
    required String species,
    required int ageMonths,
    required double weightKg,
    required List<String> conditions,
    String mode = 'tips',
  }) async {
    try {
      final request = PetTipsRequest(
        name: name,
        species: species,
        ageMonths: ageMonths,
        weightKg: weightKg,
        conditions: conditions,
        mode: mode,
      );

      final requestBody = request.toJson();
      print('=== SENDING AI REQUEST ===');
      print('Mode: ${requestBody['mode']}');
      print('Name: ${requestBody['name']}');
      print('Species: ${requestBody['species']}');
      print('Age (months): ${requestBody['ageMonths']}');
      print('Weight (kg): ${requestBody['weightKg']}');
      print('Conditions: ${requestBody['conditions']}');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/pet_tips'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
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
        birthDate = _parseBirthDate(pet.birthDate);
      } catch (e) {
        print('Error parsing birthDate: $e');
      }
    }
    
    if (birthDate != null) {
      ageMonths = ((now.difference(birthDate).inDays) / 30).round();
      print('Parsed birthDate: $birthDate, ageMonths: $ageMonths');
    } else {
      print('Could not parse birthDate: ${pet.birthDate}');
    }

    // Lấy các điều kiện sức khỏe từ pet (nếu có)
    List<String> conditions = [];
    if (pet.healthConditions != null && pet.healthConditions!.isNotEmpty) {
      conditions = pet.healthConditions!;
    }

    // Sử dụng species nếu có, nếu không thì dùng type
    String species = pet.species ?? pet.type.toLowerCase();

    // Sử dụng weightKg nếu có, nếu không thì parse từ weight string (hỗ trợ đơn vị)
    double weightKg = pet.weightKg ?? 0.0;
    if (weightKg == 0.0 && pet.weight.isNotEmpty) {
      try {
        weightKg = _parseWeightToKg(pet.weight);
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
      mode: 'tips',
    );
  }

  /// Parse chuỗi cân nặng về kg. Hỗ trợ "2 g", "2kg", "2,5 kg", "2.5"
  static double _parseWeightToKg(String raw) {
    String s = raw.trim().toLowerCase();
    // Chuẩn hoá dấu phẩy thành dấu chấm
    s = s.replaceAll(',', '.');
    // Xác định đơn vị
    bool isGram = s.contains(' g') || s.endsWith('g');
    // Lọc lấy phần số
    final numberMatch = RegExp(r"[-+]?[0-9]*\.?[0-9]+").firstMatch(s);
    if (numberMatch == null) {
      throw FormatException('Invalid weight format: $raw');
    }
    final value = double.parse(numberMatch.group(0)!);
    return isGram ? value / 1000.0 : value;
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

  /// Lấy growth tips cho thú cưng dựa trên lịch sử cân nặng
  static Future<PetGrowthResponse> getGrowthTipsForPet(PetModel pet, List<double> weightHistory, [String? warningType]) async {
    try {
      final request = PetTipsRequest(
        name: pet.name,
        species: pet.species ?? pet.type.toLowerCase(),
        ageMonths: _calculateAgeMonths(pet),
        weightKg: pet.weightKg ?? 0.0,
        conditions: pet.healthConditions ?? [],
        mode: 'growth',
      );

      final requestBody = {
        ...request.toJson(),
        'weightHistory': weightHistory,
        'warningType': warningType ?? 'normal',
      };

      print('=== SENDING GROWTH AI REQUEST ===');
      print('Mode: ${requestBody['mode']}');
      print('Name: ${requestBody['name']}');
      print('Species: ${requestBody['species']}');
      print('Age (months): ${requestBody['ageMonths']}');
      print('Weight (kg): ${requestBody['weightKg']}');
      print('Weight History: $weightHistory');
      print('Warning Type: ${requestBody['warningType']}');

      final response = await http.post(
        Uri.parse('$_baseUrl/pet_tips'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PetGrowthResponse.fromJson(data);
      } else {
        throw Exception('Failed to get growth tips: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting growth tips: $e');
    }
  }

  /// Tính tuổi theo tháng từ PetModel
  static int _calculateAgeMonths(PetModel pet) {
    final now = DateTime.now();
    int ageMonths = 0;
    
    DateTime? birthDate;
    if (pet.birthDateObj != null) {
      birthDate = pet.birthDateObj;
    } else if (pet.birthDate.isNotEmpty) {
      try {
        birthDate = _parseBirthDate(pet.birthDate);
      } catch (e) {
        print('Error parsing birthDate: $e');
      }
    }
    
    if (birthDate != null) {
      ageMonths = ((now.difference(birthDate).inDays) / 30).round();
    }
    
    return ageMonths;
  }

  /// Parse birthDate với nhiều format khác nhau
  static DateTime? _parseBirthDate(String birthDateStr) {
    if (birthDateStr.isEmpty) return null;
    
    // Loại bỏ khoảng trắng thừa
    birthDateStr = birthDateStr.trim();
    
    // Thử các format khác nhau
    try {
      // Thử format ISO 8601 trước
      return DateTime.parse(birthDateStr);
    } catch (e) {
      // Thử các format khác
      try {
        // Format dd/MM/yyyy
        if (birthDateStr.contains('/')) {
          final parts = birthDateStr.split('/');
          if (parts.length == 3) {
            // Thử dd/MM/yyyy trước
            if (parts[0].length <= 2 && parts[1].length <= 2) {
              return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            }
            // Thử MM/dd/yyyy
            else if (parts[0].length <= 2 && parts[2].length <= 2) {
              return DateTime(int.parse(parts[1]), int.parse(parts[0]), int.parse(parts[2]));
            }
          }
        }
        
        // Format dd-MM-yyyy
        if (birthDateStr.contains('-')) {
          final parts = birthDateStr.split('-');
          if (parts.length == 3) {
            // Thử dd-MM-yyyy trước
            if (parts[0].length <= 2 && parts[1].length <= 2) {
              return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            }
            // Thử MM-dd-yyyy
            else if (parts[0].length <= 2 && parts[2].length <= 2) {
              return DateTime(int.parse(parts[1]), int.parse(parts[0]), int.parse(parts[2]));
            }
          }
        }
        
        // Format yyyy/MM/dd
        if (birthDateStr.contains('/') && birthDateStr.length == 10) {
          final parts = birthDateStr.split('/');
          if (parts.length == 3 && parts[0].length == 4) {
            return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          }
        }
        
      } catch (e2) {
        print('Cannot parse birthDate: $birthDateStr, error: $e2');
        return null;
      }
    }
    
    return null;
  }
}
