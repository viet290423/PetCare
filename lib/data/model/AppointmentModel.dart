class AppointmentModel {
  final int? id;
  final int serviceId;
  final String? serviceTitle;
  final String petId;
  final String userId;
  final DateTime appointmentTime;
  final String status;
  final DateTime? createdAt;

  AppointmentModel({
    this.id,
    required this.serviceId,
    this.serviceTitle,
    required this.petId,
    required this.userId,
    required this.appointmentTime,
    required this.status,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'pet_id': petId,
      'user_id': userId,
      'appointment_time': appointmentTime.toIso8601String(),
      'status': status,
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['i40d'],
      serviceId: json['service_id'],
      serviceTitle: json['services'] != null ? json['services']['title'] : null,
      petId: json['pet_id'].toString(),
      userId: json['user_id'],
      appointmentTime: DateTime.parse(json['appointment_time']),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}