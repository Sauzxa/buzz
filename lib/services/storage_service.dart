import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  StorageService._internal();

  // Create storage instance
  final _storage = const FlutterSecureStorage();

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  /// Save JWT token to secure storage
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      print('Error saving token: $e');
      rethrow;
    }
  }

  /// Get JWT token from secure storage
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  /// Delete JWT token from secure storage
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      print('Error deleting token: $e');
      rethrow;
    }
  }

  /// Save user ID to secure storage
  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
    } catch (e) {
      print('Error saving user ID: $e');
      rethrow;
    }
  }

  /// Get user ID from secure storage
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      print('Error reading user ID: $e');
      return null;
    }
  }

  /// Delete user ID from secure storage
  Future<void> deleteUserId() async {
    try {
      await _storage.delete(key: _userIdKey);
    } catch (e) {
      print('Error deleting user ID: $e');
      rethrow;
    }
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Mark that user has completed onboarding
  Future<void> setOnboardingCompleted() async {
    try {
      await _storage.write(key: _hasSeenOnboardingKey, value: 'true');
    } catch (e) {
      print('Error saving onboarding status: $e');
      rethrow;
    }
  }

  /// Check if user has seen onboarding
  Future<bool> hasSeenOnboarding() async {
    try {
      final value = await _storage.read(key: _hasSeenOnboardingKey);
      return value == 'true';
    } catch (e) {
      print('Error reading onboarding status: $e');
      return false;
    }
  }

  /// Clear onboarding flag (for testing/reset)
  Future<void> clearOnboardingFlag() async {
    try {
      await _storage.delete(key: _hasSeenOnboardingKey);
    } catch (e) {
      print('Error clearing onboarding flag: $e');
      rethrow;
    }
  }

  /// Clear auth data only (logout) - preserves onboarding flag
  Future<void> clearAuthData() async {
    try {
      await deleteToken();
      await deleteUserId();
      // Note: Does NOT clear hasSeenOnboarding
    } catch (e) {
      print('Error clearing auth data: $e');
      rethrow;
    }
  }

  /// Clear all stored data (complete reset)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Error clearing storage: $e');
      rethrow;
    }
  }
}
