import '../config/config.dart';

class ApiEndpoints {
  // Base URL for your backend server
  // Using centralized configuration for easy IP address management
  static String get baseUrl => AppConfig.baseUrl;

  // API version prefix
  static const String apiPrefix = '/api';

  // Authentication endpoints

  static String get singup => '$apiPrefix/users/create-test';
  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
