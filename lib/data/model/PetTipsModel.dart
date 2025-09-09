class PetTipsRequest {
  final String name;
  final String species;
  final int ageMonths;
  final double weightKg;
  final List<String> conditions;

  PetTipsRequest({
    required this.name,
    required this.species,
    required this.ageMonths,
    required this.weightKg,
    required this.conditions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'ageMonths': ageMonths,
      'weightKg': weightKg,
      'conditions': conditions,
    };
  }

  factory PetTipsRequest.fromJson(Map<String, dynamic> json) {
    return PetTipsRequest(
      name: json['name'] ?? '',
      species: json['species'] ?? '',
      ageMonths: json['ageMonths'] ?? 0,
      weightKg: (json['weightKg'] ?? 0.0).toDouble(),
      conditions: List<String>.from(json['conditions'] ?? []),
    );
  }
}

class PetTipsResponse {
  final String tip;

  PetTipsResponse({
    required this.tip,
  });

  factory PetTipsResponse.fromJson(Map<String, dynamic> json) {
    return PetTipsResponse(
      tip: json['tip'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tip': tip,
    };
  }
}

class PetTip {
  final String id;
  final String petId;
  final String tip;
  final DateTime createdAt;
  final String category;

  PetTip({
    required this.id,
    required this.petId,
    required this.tip,
    required this.createdAt,
    required this.category,
  });

  factory PetTip.fromJson(Map<String, dynamic> json) {
    return PetTip(
      id: json['id'] ?? '',
      petId: json['petId'] ?? '',
      tip: json['tip'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      category: json['category'] ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'tip': tip,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
    };
  }
}
