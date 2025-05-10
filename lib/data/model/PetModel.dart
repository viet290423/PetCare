class PetModel {
  final String id;
  final String name;
  final String imageUrl;
  final String breed;
  final String birthDate;
  final String gender;
  final String weight;
  final String color;

  PetModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.breed,
    required this.birthDate,
    required this.gender,
    required this.weight,
    required this.color,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) => PetModel(
    id: json['id'],
    name: json['name'],
    imageUrl: json['imageUrl'],
    breed: json['breed'],
    birthDate: json['birthDate'],
    gender: json['gender'],
    weight: json['weight'],
    color: json['color'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'breed': breed,
    'birthDate': birthDate,
    'gender': gender,
    'color': color,
    'weight': weight,
  };
}
