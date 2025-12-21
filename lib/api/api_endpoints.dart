import '../config/config.dart';

class ApiEndpoints {
  // Base URL for your backend server
  // Using centralized configuration for easy IP address management
  static String get baseUrl => AppConfig.baseUrl;

  // API version prefix
  static const String apiPrefix = '/api';

  // Authentication endpoints
  static String get singup => '$apiPrefix/users/create-test';

  // User endpoints
  static String getUserById(String userId) => '$apiPrefix/user/$userId';

  // Category endpoints
  static String get getAllCategories =>
      '$apiPrefix/category-service/all-categories';

  // Service endpoints
  static String get getAllServices => '$apiPrefix/services/all';

  // News endpoints
  static String get getNews => '$apiPrefix/news';

  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
