class HealthMetricsModel {
  final String id;
  final String petId;
  final DateTime date;
  final double? weight; // kg
  final double? temperature; // độ C
  final int? heartRate; // nhịp/phút
  final int? respiratoryRate; // nhịp/phút
  final double? bloodPressureSystolic; // mmHg
  final double? bloodPressureDiastolic; // mmHg
  final String? notes;
  final DateTime createdAt;

  HealthMetricsModel({
    required this.id,
    required this.petId,
    required this.date,
    this.weight,
    this.temperature,
    this.heartRate,
    this.respiratoryRate,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.notes,
    required this.createdAt,
  });

  factory HealthMetricsModel.fromJson(Map<String, dynamic> json) {
    return HealthMetricsModel(
      id: json['id'],
      petId: json['pet_id'],
      date: DateTime.parse(json['date']),
      weight: json['weight']?.toDouble(),
      temperature: json['temperature']?.toDouble(),
      heartRate: json['heart_rate'],
      respiratoryRate: json['respiratory_rate'],
      bloodPressureSystolic: json['blood_pressure_systolic']?.toDouble(),
      bloodPressureDiastolic: json['blood_pressure_diastolic']?.toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'date': date.toIso8601String(),
      'weight': weight,
      'temperature': temperature,
      'heart_rate': heartRate,
      'respiratory_rate': respiratoryRate,
      'blood_pressure_systolic': bloodPressureSystolic,
      'blood_pressure_diastolic': bloodPressureDiastolic,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
