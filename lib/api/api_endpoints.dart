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
  static String get forgotPassword => '$apiPrefix/auth/forgot-password';
  static String get resetPassword => '$apiPrefix/auth/reset-password';
  static String get changePassword => '$apiPrefix/auth/change-password';

  // User endpoints
  // User endpoints
  static String getUserById(String userId) => '$apiPrefix/users/$userId';
  static String updateUser(String userId) => '$apiPrefix/users/$userId';
  static String deleteUser(String userId) => '$apiPrefix/users/$userId';

  // Category endpoints
  static String get getAllCategories =>
      '$apiPrefix/category-service/all-categories';

  // Service endpoints
  static String get getAllServices => '$apiPrefix/services/all';

  // Order endpoints
  static String get createOrder => '$apiPrefix/orders';
  static String uploadOrderFile(String orderId) =>
      '$apiPrefix/orders/$orderId/files';
  static String getAllOrdersByCustomer(String customerId) =>
      '$apiPrefix/orders/customer/$customerId';
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
    bool? isRead,
    int page = 0,
    int size = 20,
  }) {
    // Backend requires isRead parameter, default to false if not provided
    final readParam = isRead ?? false;
    return '$apiPrefix/notification/user/my-notification?isRead=$readParam&page=$page&size=$size';
  }

  static String markNotificationAsRead(int notificationId) =>
      '$apiPrefix/notification/$notificationId/read';
  static String deleteNotification(int notificationId) =>
      '$apiPrefix/notification/$notificationId';

  // Chat endpoints
  static String get getOrCreateMyChat => '$apiPrefix/chats/my-chat';
  static String getAllChats({
    int page = 0,
    int size = 10,
    String sortDir = 'desc',
  }) => '$apiPrefix/chats?page=$page&size=$size&sortDir=$sortDir';
  static String getChatById(int chatId) => '$apiPrefix/chats/$chatId';

  // Message endpoints
  static String getChatMessages(int chatId, {int page = 0, int size = 20}) =>
      '$apiPrefix/chats/$chatId/messages?page=$page&size=$size';
  static String sendMessage(int chatId) => '$apiPrefix/chats/$chatId/messages';
  static String markMessageAsRead(int chatId, int messageId) =>
      '$apiPrefix/chats/$chatId/messages/$messageId/read';
  static String markChatAsRead(int chatId) =>
      '$apiPrefix/chats/$chatId/messages/read-all';

  // Support endpoints
  static String get submitSupportMessage => '$apiPrefix/supportMessage';
  static String getAllSupportMessages({
    int page = 0,
    int size = 10,
    String? messageType,
  }) {
    String url = '$apiPrefix/supportMessage/get-all?page=$page&size=$size';
    if (messageType != null) {
      url += '&messageType=$messageType';
    }
    return url;
  }

  static String markSupportMessageAsRead(int messageId) =>
      '$apiPrefix/supportMessage/$messageId/read';

  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
