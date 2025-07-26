class MedicalRecordModel {
  final String id;
  final String petId;
  final String title;
  final String description;
  final String
  recordType; // 'checkup', 'vaccination', 'treatment', 'surgery', 'test'
  final DateTime recordDate;
  final String? doctorId;
  final String? doctorName;
  final String status; // 'completed', 'ongoing', 'scheduled', 'cancelled'
  final double? cost;
  final String? notes;
  final List<String>? attachments; // URLs của ảnh/xét nghiệm
  final Map<String, dynamic>? vitals; // Thông số sinh hiệu
  final List<String>? medications; // Danh sách thuốc
  final String? nextVisitDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalRecordModel({
    required this.id,
    required this.petId,
    required this.title,
    required this.description,
    required this.recordType,
    required this.recordDate,
    this.doctorId,
    this.doctorName,
    required this.status,
    this.cost,
    this.notes,
    this.attachments,
    this.vitals,
    this.medications,
    this.nextVisitDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'],
      petId: json['pet_id'],
      title: json['title'],
      description: json['description'],
      recordType: json['record_type'],
      recordDate: DateTime.parse(json['record_date']),
      doctorId: json['doctor_id'],
      doctorName: json['doctor_name'],
      status: json['status'],
      cost: json['cost']?.toDouble(),
      notes: json['notes'],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      vitals: json['vitals'] != null
          ? Map<String, dynamic>.from(json['vitals'])
          : null,
      medications: json['medications'] != null
          ? List<String>.from(json['medications'])
          : null,
      nextVisitDate: json['next_visit_date'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'title': title,
      'description': description,
      'record_type': recordType,
      'record_date': recordDate.toIso8601String(),
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'status': status,
      'cost': cost,
      'notes': notes,
      'attachments': attachments,
      'vitals': vitals,
      'medications': medications,
      'next_visit_date': nextVisitDate,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
