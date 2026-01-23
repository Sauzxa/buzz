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

  // News endpoints
  static String get getNews => '$apiPrefix/news';

  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
