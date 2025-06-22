class TimeSlotModel {
  final String id;
  final String doctorId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final String? appointmentId; // ID của cuộc hẹn nếu đã được đặt

  TimeSlotModel({
    required this.id,
    required this.doctorId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.appointmentId,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id: json['id'],
      doctorId: json['doctor_id'],
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      isAvailable: json['is_available'] ?? true,
      appointmentId: json['appointment_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'date': date.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'is_available': isAvailable,
      'appointment_id': appointmentId,
    };
  }

  // Kiểm tra xem khung giờ này có trùng với thời gian hiện tại không
  bool isInPast() {
    final now = DateTime.now();
    final slotDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(startTime.split(':')[0]),
      int.parse(startTime.split(':')[1]),
    );
    return slotDateTime.isBefore(now);
  }

  // Lấy thời gian hiển thị cho UI
  String get displayTime {
    return '$startTime - $endTime';
  }
}
