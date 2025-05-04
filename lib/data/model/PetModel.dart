import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String id;
  final String name;
  final String imageUrl;
  final String breed;

  PetModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.breed,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) => PetModel(
    id: json['id'],
    name: json['name'],
    imageUrl: json['imageUrl'],
    breed: json['breed'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'breed': breed,
  };
}
