class VaccinationRecordModel {
  final String id;
  final String petId;
  final String vaccineName;
  final String vaccineType; // 'core', 'non-core', 'rabies', 'other'
  final DateTime vaccinationDate;
  final DateTime? nextDueDate;
  final String? batchNumber;
  final String? manufacturer;
  final String? administeredBy;
  final String? notes;
  final String status; // 'completed', 'scheduled', 'overdue'
  final DateTime createdAt;

  VaccinationRecordModel({
    required this.id,
    required this.petId,
    required this.vaccineName,
    required this.vaccineType,
    required this.vaccinationDate,
    this.nextDueDate,
    this.batchNumber,
    this.manufacturer,
    this.administeredBy,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  factory VaccinationRecordModel.fromJson(Map<String, dynamic> json) {
    return VaccinationRecordModel(
      id: json['id'],
      petId: json['pet_id'],
      vaccineName: json['vaccine_name'],
      vaccineType: json['vaccine_type'],
      vaccinationDate: DateTime.parse(json['vaccination_date']),
      nextDueDate: json['next_due_date'] != null
          ? DateTime.parse(json['next_due_date'])
          : null,
      batchNumber: json['batch_number'],
      manufacturer: json['manufacturer'],
      administeredBy: json['administered_by'],
      notes: json['notes'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'vaccine_name': vaccineName,
      'vaccine_type': vaccineType,
      'vaccination_date': vaccinationDate.toIso8601String(),
      'next_due_date': nextDueDate?.toIso8601String(),
      'batch_number': batchNumber,
      'manufacturer': manufacturer,
      'administered_by': administeredBy,
      'notes': notes,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isOverdue {
    if (nextDueDate == null) return false;
    return DateTime.now().isAfter(nextDueDate!);
  }

  bool get isDueSoon {
    if (nextDueDate == null) return false;
    final daysUntilDue = nextDueDate!.difference(DateTime.now()).inDays;
    return daysUntilDue <= 30 && daysUntilDue >= 0;
  }
}
