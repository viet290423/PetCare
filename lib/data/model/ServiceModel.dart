class ServiceModel {
  final int id;
  final String title;
  final String description;
  final String icon;
  final String category;
  final String? detailedDescription;
  final String? imageUrl;
  final double? price;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.detailedDescription,
    this.imageUrl,
    this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      category: json['category'],
      detailedDescription: json['detailed_description'],
      imageUrl: json['image_url'],
      price: json['price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'category': category,
      'detailed_description': detailedDescription,
      'image_url': imageUrl,
      'price': price,
    };
  }
}
