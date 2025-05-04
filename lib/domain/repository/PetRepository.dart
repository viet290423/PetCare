import '../../data/model/HealthStatusModel.dart';
import '../../data/model/PetModel.dart';

abstract class PetRepository {
  Future<List<PetModel>> getPets();
  Future<HealthStatusModel> getHealthStatus(String petId);
  Future<List<Map<String, dynamic>>> getProductSuggestions();
  Future<void> addPet(PetModel pet);
}