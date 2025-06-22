class AppointmentModel {
  final int? id;
  final int serviceId;
  final String? serviceTitle;
  final String petId;
  final String userId;
  final String? doctorId;
  final String? doctorName;
  final DateTime appointmentTime;
  final String status;
  final DateTime? createdAt;
  final String? notes;

  AppointmentModel({
    this.id,
    required this.serviceId,
    this.serviceTitle,
    required this.petId,
    required this.userId,
    this.doctorId,
    this.doctorName,
    required this.appointmentTime,
    required this.status,
    this.createdAt,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'pet_id': petId,
      'user_id': userId,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'appointment_time': appointmentTime.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      serviceId: json['service_id'],
      serviceTitle: json['services'] != null ? json['services']['title'] : null,
      petId: json['pet_id'].toString(),
      userId: json['user_id'],
      doctorId: json['doctor_id'],
      doctorName: json['doctor_name'],
      appointmentTime: DateTime.parse(json['appointment_time']),
      status: json['status'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      notes: json['notes'],
    );
  }
}