import '../../repository/PetRepository.dart';

class ProductSuggestionUseCase {
  final PetRepository repository;

  ProductSuggestionUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getProductSuggestions();
  }
}