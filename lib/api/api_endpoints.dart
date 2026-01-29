import '../config/config.dart';

class ApiEndpoints {
  // Base URL for your backend server
  // Using centralized configuration for easy IP address management
  static String get baseUrl => AppConfig.baseUrl;

  // API version prefix
  static const String apiPrefix = '/api';

  // Authentication endpoints
  static String get signup => '$apiPrefix/auth/register';
  static String get login => '$apiPrefix/auth/login';
  static String get logout => '$apiPrefix/auth/logout';
  static String get refreshToken => '$apiPrefix/auth/refresh';

  // User endpoints
  // User endpoints
  static String getUserById(String userId) => '$apiPrefix/users/$userId';
  static String updateUser(String userId) => '$apiPrefix/users/$userId';

  // Category endpoints
  static String get getAllCategories =>
      '$apiPrefix/category-service/all-categories';

  // Service endpoints
  static String get getAllServices => '$apiPrefix/services/all';

  // Order endpoints
  static String get createOrder => '$apiPrefix/orders';
  static String uploadOrderFile(String orderId) =>
      '$apiPrefix/orders/$orderId/files';
  static String getActiveOrdersByCustomer(String customerId) =>
      '$apiPrefix/orders/customer/$customerId/active';
  static String getArchivedOrdersByCustomer(String customerId) =>
      '$apiPrefix/orders/customer/$customerId/archived';
  static String getOrderById(String orderId) => '$apiPrefix/orders/$orderId';
  static String cancelOrder(String orderId) => '$apiPrefix/orders/$orderId';

  // Invoice endpoints
  static String getInvoiceByOrderId(String orderId) =>
      '$apiPrefix/invoices/order/$orderId';
  static String uploadPaymentProof(String invoiceId) =>
      '$apiPrefix/invoices/$invoiceId/upload-proof';

  // News endpoints
  static String get getNews => '$apiPrefix/news';

  // Discount endpoints
  static String get getActiveDiscounts => '$apiPrefix/discounts';

  // FCM (Firebase Cloud Messaging) endpoints
  static String get registerFcmToken => '$apiPrefix/fcm/register';
  static String removeFcmToken(String token) => '$apiPrefix/fcm/token/$token';
  static String get removeAllFcmTokens => '$apiPrefix/fcm/tokens/all';

  // Notification endpoints
  static String getUserNotifications({
    required String userId,
    bool? isRead,
    int page = 0,
    int size = 20,
  }) {
    final readParam = isRead != null ? '&isRead=$isRead' : '';
    return '$apiPrefix/notification/user/$userId?page=$page&size=$size$readParam';
  }

  static String markNotificationAsRead(int notificationId) =>
      '$apiPrefix/notification/$notificationId/read';
  static String deleteNotification(int notificationId) =>
      '$apiPrefix/notification/$notificationId';

  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
