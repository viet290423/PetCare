class DiseaseModel {
  final String id;
  final String title;
  final String description;
  final String detailedDescription;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatments;
  final List<String> preventions;
  final String severity;
  final String petType;
  final String imageUrl;
  final List<String> faqs;
  final List<ServiceRecommendation>? recommendations;

  DiseaseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.detailedDescription,
    required this.symptoms,
    required this.causes,
    required this.treatments,
    required this.preventions,
    required this.severity,
    required this.petType,
    required this.imageUrl,
    required this.faqs,
    this.recommendations,
  });

  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    print('Đang ánh xạ dữ liệu: $json');
    return DiseaseModel(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      detailedDescription: json['detailed_description'],
      symptoms: List<String>.from(json['symptoms']) ?? [],
      causes: List<String>.from(json['causes']) ?? [],
      treatments: List<String>.from(json['treatments']) ?? [],
      preventions: List<String>.from(json['preventions']) ?? [],
      severity: json['severity'],
      petType: json['pet_type'],
      imageUrl: json['image_url'],
      faqs: List<String>.from(json['faqs']) ?? [],
      recommendations: (json['disease_service_recommendations'] as List)
          .map((rec) => ServiceRecommendation.fromJson(rec))
          .toList(),
    );
  }
}

class ServiceRecommendation {
  final int serviceId;
  final String recommendationType;

  ServiceRecommendation({
    required this.serviceId,
    required this.recommendationType,
  });

  factory ServiceRecommendation.fromJson(Map<String, dynamic> json) {
    return ServiceRecommendation(
      serviceId: json['service_id'],
      recommendationType: json['recommendation_type'],
    );
  }
}