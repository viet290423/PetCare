class DoctorModel {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final String education;
  final String imageUrl;
  final String description;
  final List<String> certifications;
  final double rating;
  final int reviewCount;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.education,
    required this.imageUrl,
    required this.description,
    required this.certifications,
    required this.rating,
    required this.reviewCount,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'],
      experience: json['experience'],
      education: json['education'],
      imageUrl: json['image_url'],
      description: json['description'],
      certifications: List<String>.from(json['certifications'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'experience': experience,
      'education': education,
      'image_url': imageUrl,
      'description': description,
      'certifications': certifications,
      'rating': rating,
      'review_count': reviewCount,
    };
  }
}
