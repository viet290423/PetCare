class ReminderModel {
  final String id;
  final String petId;
  final String title;
  final String? description;
  final String type; // ví dụ: Cho ăn, Thuốc, Tiêm phòng,...
  final DateTime dateTime;
  final String repeatType; // Không lặp, Hàng ngày, Hàng tuần, ...

  ReminderModel({
    required this.id,
    required this.petId,
    required this.title,
    this.description,
    required this.type,
    required this.dateTime,
    required this.repeatType,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
    id: json['id'],
    petId: json['pet_id'],
    title: json['title'],
    description: json['description'],
    type: json['type'],
    dateTime: DateTime.parse(json['date_time']),
    repeatType: json['repeat_type'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'pet_id': petId,
    'title': title,
    'description': description,
    'type': type,
    'date_time': dateTime.toIso8601String(),
    'repeat_type': repeatType,
  };
}
