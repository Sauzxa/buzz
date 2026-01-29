class InvoiceModel {
  final int? id;
  final String? invoiceNumber;
  final int? orderId;
  final String? orderNumber;
  final String? customerName;
  final String? serviceName;
  final String? paymentMethod;
  final String? paymentMethodType;
  final double? subtotal;
  final double? discountAmount;
  final double? totalAmount;
  final double? initialAmount;
  final double? finalAmount;
  final double? fee;
  final double? initialAmountPaid;
  final double? finalAmountPaid;
  final double? totalPaidAmount;
  final double? remainingAmount;
  final String? invoiceStatus;
  final String? paymentDeadline;
  final bool? isFullyPaid;
  final bool? isPaymentDeadlinePassed;
  final List<String>? paymentProofs;
  final List<String>? paymentValidatedAt;
  final String? createdAt;
  final String? updatedAt;

  InvoiceModel({
    this.id,
    this.invoiceNumber,
    this.orderId,
    this.orderNumber,
    this.customerName,
    this.serviceName,
    this.paymentMethod,
    this.paymentMethodType,
    this.subtotal,
    this.discountAmount,
    this.totalAmount,
    this.initialAmount,
    this.finalAmount,
    this.fee,
    this.initialAmountPaid,
    this.finalAmountPaid,
    this.totalPaidAmount,
    this.remainingAmount,
    this.invoiceStatus,
    this.paymentDeadline,
    this.isFullyPaid,
    this.isPaymentDeadlinePassed,
    this.paymentProofs,
    this.paymentValidatedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      orderId: json['orderId'],
      orderNumber: json['orderNumber'],
      customerName: json['customerName'],
      serviceName: json['serviceName'],
      paymentMethod: json['paymentMethod'],
      paymentMethodType: json['paymentMethodType'],
      subtotal: json['subtotal']?.toDouble(),
      discountAmount: json['discountAmount']?.toDouble(),
      totalAmount: json['totalAmount']?.toDouble(),
      initialAmount: json['initialAmount']?.toDouble(),
      finalAmount: json['finalAmount']?.toDouble(),
      fee: json['fee']?.toDouble(),
      initialAmountPaid: json['initialAmountPaid']?.toDouble(),
      finalAmountPaid: json['finalAmountPaid']?.toDouble(),
      totalPaidAmount: json['totalPaidAmount']?.toDouble(),
      remainingAmount: json['remainingAmount']?.toDouble(),
      invoiceStatus: json['invoiceStatus'],
      paymentDeadline: json['paymentDeadline'],
      isFullyPaid: json['isFullyPaid'],
      isPaymentDeadlinePassed: json['isPaymentDeadlinePassed'],
      paymentProofs: json['paymentProofs'] != null
          ? List<String>.from(json['paymentProofs'])
          : null,
      paymentValidatedAt: json['paymentValidatedAt'] != null
          ? List<String>.from(json['paymentValidatedAt'])
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'orderId': orderId,
      'orderNumber': orderNumber,
      'customerName': customerName,
      'serviceName': serviceName,
      'paymentMethod': paymentMethod,
      'paymentMethodType': paymentMethodType,
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'initialAmount': initialAmount,
      'finalAmount': finalAmount,
      'fee': fee,
      'initialAmountPaid': initialAmountPaid,
      'finalAmountPaid': finalAmountPaid,
      'totalPaidAmount': totalPaidAmount,
      'remainingAmount': remainingAmount,
      'invoiceStatus': invoiceStatus,
      'paymentDeadline': paymentDeadline,
      'isFullyPaid': isFullyPaid,
      'isPaymentDeadlinePassed': isPaymentDeadlinePassed,
      'paymentProofs': paymentProofs,
      'paymentValidatedAt': paymentValidatedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  bool get isSplitPayment => paymentMethodType == 'SPLIT_PAYMENT';
}
