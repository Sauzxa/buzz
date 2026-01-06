class CategoryModel {
  final String id;
  final String categoryName;
  final String description;
  final String categoryColor;
  final String categoryImage; // Image URL from third-party service
  final List<dynamic>? services;

  CategoryModel({
    required this.id,
    required this.categoryName,
    required this.description,
    required this.categoryColor,
    required this.categoryImage,
    this.services,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryColor: json['categoryColor']?.toString() ?? '#EC1968',
      categoryImage: json['categoryImage']?.toString() ?? '',
      services: json['services'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'description': description,
      'categoryColor': categoryColor,
      'categoryImage': categoryImage,
      'services': services,
    };
  }
}
