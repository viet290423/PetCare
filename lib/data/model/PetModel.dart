class PetModel {
  final String id;
  final String name;
  final String type;
  final String imageUrl;
  final String breed;
  final String birthDate;
  final String gender;
  final String weight;
  final String color;
  
  // Thêm các trường mới cho AI tips
  final String? species;
  final double? weightKg;
  final DateTime? birthDateObj;
  final List<String>? healthConditions;

  PetModel({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.breed,
    required this.birthDate,
    required this.gender,
    required this.weight,
    required this.color,
    this.species,
    this.weightKg,
    this.birthDateObj,
    this.healthConditions,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) => PetModel(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    imageUrl: json['imageUrl'],
    breed: json['breed'],
    birthDate: json['birthDate'],
    gender: json['gender'],
    weight: json['weight'],
    color: json['color'],
    species: json['species'],
    weightKg: json['weightKg']?.toDouble(),
    birthDateObj: json['birthDateObj'] != null 
        ? DateTime.parse(json['birthDateObj']) 
        : null,
    healthConditions: json['healthConditions'] != null 
        ? List<String>.from(json['healthConditions']) 
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'imageUrl': imageUrl,
    'breed': breed,
    'birthDate': birthDate,
    'gender': gender,
    'color': color,
    'weight': weight,
    'species': species,
    'weightKg': weightKg,
    'birthDateObj': birthDateObj?.toIso8601String(),
    'healthConditions': healthConditions,
  };
}
