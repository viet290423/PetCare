import 'package:cloud_firestore/cloud_firestore.dart';

class HealthStatusModel {
  final double weight;
  final DateTime lastVaccination;
  final String note;

  HealthStatusModel({
    required this.weight,
    required this.lastVaccination,
    required this.note,
  });

  factory HealthStatusModel.fromJson(Map<String, dynamic> json) => HealthStatusModel(
    weight: json['weight'],
    lastVaccination: (json['lastVaccination'] as Timestamp).toDate(),
    note: json['note'],
  );

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'lastVaccination': Timestamp.fromDate(lastVaccination),
    'note': note,
  };
}