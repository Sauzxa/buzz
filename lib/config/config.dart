import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration constants
class AppConfig {
  // Server configuration - Use domain name in production
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://72.60.45.126:10000';

  // Legacy support (kept for backward compatibility)
  /*
  static String get serverIpAddress =>
      dotenv.env['SERVER_IP'] ?? '72.60.45.126';
*/
  /*
  static int get serverPort =>
      int.tryParse(dotenv.env['SERVER_PORT'] ?? '') ?? 3000;
*/
  // Environment configuration
  static const bool isDebugMode = true;
  static const bool enableLogging = true;

  // API configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
}
