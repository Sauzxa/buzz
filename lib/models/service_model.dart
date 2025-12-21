class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String? categoryId;
  final double? price;
  final String? imageUrl;
  final bool? isActive;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    this.categoryId,
    this.price,
    this.imageUrl,
    this.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryId: json['categoryId']?.toString(),
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      imageUrl: json['imageUrl']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'price': price,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}
