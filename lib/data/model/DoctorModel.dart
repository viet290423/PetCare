class DoctorModel {
  final String id;
  final String? userId;
  final String name;
  final String specialization;
  final List<String> specializations;
  final String experience;
  final String education;
  final String? imageUrl;
  final String description;
  final List<String> certifications;
  final double rating;
  final int reviewCount;
  final List<String> workingDays;
  final String workingHours;
  final bool isAvailable;
  final List<String> serviceIds;

  DoctorModel({
    required this.id,
    this.userId,
    required this.name,
    required this.specialization,
    required this.specializations,
    required this.experience,
    required this.education,
    this.imageUrl,
    required this.description,
    required this.certifications,
    required this.rating,
    required this.reviewCount,
    required this.workingDays,
    required this.workingHours,
    required this.isAvailable,
    required this.serviceIds,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      specialization: json['specialization'],
      specializations: List<String>.from(json['specializations'] ?? []),
      experience: json['experience'],
      education: json['education'],
      imageUrl: json['image_url'],
      description: json['description'],
      certifications: List<String>.from(json['certifications'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      workingDays: List<String>.from(json['working_days'] ?? []),
      workingHours: json['working_hours'] ?? "08:00-17:00",
      isAvailable: json['is_available'] ?? true,
      serviceIds: List<String>.from(json['service_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'specialization': specialization,
      'specializations': specializations,
      'experience': experience,
      'education': education,
      'image_url': imageUrl,
      'description': description,
      'certifications': certifications,
      'rating': rating,
      'review_count': reviewCount,
      'working_days': workingDays,
      'working_hours': workingHours,
      'is_available': isAvailable,
      'service_ids': serviceIds,
    };
  }

  bool canPerformService(String serviceId) {
    return serviceIds.contains(serviceId);
  }

  bool isWorkingOnDay(String dayOfWeek) {
    return workingDays.contains(dayOfWeek);
  }
}
