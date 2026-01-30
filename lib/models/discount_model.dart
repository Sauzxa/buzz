class DiscountModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final String discountType; // "PERCENTAGE" or other
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final int usageLimit;
  final int usageCount;
  final int maxUsageCount;
  final double minPurchaseAmount;
  final double maxDiscountAmount;
  final String? discountImage;
  final String serviceId;
  final List<String> serviceNames;

  DiscountModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    required this.usageLimit,
    required this.usageCount,
    required this.maxUsageCount,
    required this.minPurchaseAmount,
    required this.maxDiscountAmount,
    this.discountImage,
    required this.serviceId,
    required this.serviceNames,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? 'PERCENTAGE',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      usageLimit: json['usageLimit'] as int? ?? 0,
      usageCount: json['usageCount'] as int? ?? 0,
      maxUsageCount: json['maxUsageCount'] as int? ?? 0,
      minPurchaseAmount: (json['minPurchaseAmount'] as num?)?.toDouble() ?? 0.0,
      maxDiscountAmount: (json['maxDiscountAmount'] as num?)?.toDouble() ?? 0.0,
      discountImage: json['discountImage']?.toString(),
      serviceId: json['serviceId']?.toString() ?? '',
      serviceNames:
          (json['servicesNames'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'maxUsageCount': maxUsageCount,
      'minPurchaseAmount': minPurchaseAmount,
      'maxDiscountAmount': maxDiscountAmount,
      'discountImage': discountImage,
      'serviceId': serviceId,
      'servicesNames': serviceNames,
    };
  }

  // Helper method to check if discount is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  // Helper method to get discount percentage display
  String get discountDisplay {
    if (discountType == 'PERCENTAGE') {
      return '${discountValue.toInt()}% OFF';
    }
    return '-${discountValue.toStringAsFixed(2)} DA';
  }
}
