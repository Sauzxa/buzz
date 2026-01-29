class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String? notificationImage;
  final bool isRead;
  final NotificationType notificationType;
  final int? referenceId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.notificationImage,
    required this.isRead,
    required this.notificationType,
    this.referenceId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      notificationImage: json['notificationImage'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      notificationType: NotificationType.fromString(
        json['notificationType'] as String,
      ),
      referenceId: json['referenceId'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'notificationImage': notificationImage,
      'isRead': isRead,
      'notificationType': notificationType.toString().split('.').last,
      'referenceId': referenceId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    String? notificationImage,
    bool? isRead,
    NotificationType? notificationType,
    int? referenceId,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationImage: notificationImage ?? this.notificationImage,
      isRead: isRead ?? this.isRead,
      notificationType: notificationType ?? this.notificationType,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum NotificationType {
  ORDER_CREATED,
  CHAT,
  NEWS,
  DISCOUNT,
  ORDER_PRICED,
  PAYMENT_PROOF_UPLOADED,
  PAYMENT_PROOF_VALIDATED,
  ORDER_COMPLETED,
  ORDER_CANCELED,
  PAYMENT_PROOF_REJECTED,
  ASSIGNE_DESIGNER,
  INVOICE_UPDATED;

  static NotificationType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ORDER_CREATED':
        return NotificationType.ORDER_CREATED;
      case 'CHAT':
        return NotificationType.CHAT;
      case 'NEWS':
        return NotificationType.NEWS;
      case 'DISCOUNT':
        return NotificationType.DISCOUNT;
      case 'ORDER_PRICED':
        return NotificationType.ORDER_PRICED;
      case 'PAYMENT_PROOF_UPLOADED':
        return NotificationType.PAYMENT_PROOF_UPLOADED;
      case 'PAYMENT_PROOF_VALIDATED':
        return NotificationType.PAYMENT_PROOF_VALIDATED;
      case 'ORDER_COMPLETED':
        return NotificationType.ORDER_COMPLETED;
      case 'ORDER_CANCELED':
        return NotificationType.ORDER_CANCELED;
      case 'PAYMENT_PROOF_REJECTED':
        return NotificationType.PAYMENT_PROOF_REJECTED;
      case 'ASSIGNE_DESIGNER':
        return NotificationType.ASSIGNE_DESIGNER;
      case 'INVOICE_UPDATED':
        return NotificationType.INVOICE_UPDATED;
      default:
        return NotificationType.NEWS; // Default fallback
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.ORDER_CREATED:
        return 'Order Created';
      case NotificationType.CHAT:
        return 'New Message';
      case NotificationType.NEWS:
        return 'News Update';
      case NotificationType.DISCOUNT:
        return 'Special Discount';
      case NotificationType.ORDER_PRICED:
        return 'Order Priced';
      case NotificationType.PAYMENT_PROOF_UPLOADED:
        return 'Payment Proof Uploaded';
      case NotificationType.PAYMENT_PROOF_VALIDATED:
        return 'Payment Validated';
      case NotificationType.ORDER_COMPLETED:
        return 'Order Completed';
      case NotificationType.ORDER_CANCELED:
        return 'Order Canceled';
      case NotificationType.PAYMENT_PROOF_REJECTED:
        return 'Payment Rejected';
      case NotificationType.ASSIGNE_DESIGNER:
        return 'Designer Assigned';
      case NotificationType.INVOICE_UPDATED:
        return 'Invoice Updated';
    }
  }
}
