class OrderModel {
  final String? id;
  final String serviceId;
  final String serviceName;
  final String userId;
  final Map<String, dynamic> formData;
  final List<String>? fileUrls;
  final String status; // pending, in_progress, completed, cancelled
  final double? totalAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    this.id,
    required this.serviceId,
    required this.serviceName,
    required this.userId,
    required this.formData,
    this.fileUrls,
    this.status = 'pending',
    this.totalAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString(),
      serviceId: json['serviceId']?.toString() ?? '',
      serviceName: json['serviceName'] ?? '',
      userId: json['userId']?.toString() ?? '',
      formData: json['formData'] as Map<String, dynamic>? ?? {},
      fileUrls: json['fileUrls'] != null
          ? List<String>.from(json['fileUrls'])
          : null,
      status: json['status'] ?? 'pending',
      totalAmount: json['totalAmount'] != null
          ? double.tryParse(json['totalAmount'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'userId': userId,
      'formData': formData,
      if (fileUrls != null) 'fileUrls': fileUrls,
      'status': status,
      if (totalAmount != null) 'totalAmount': totalAmount,
    };
  }
}
