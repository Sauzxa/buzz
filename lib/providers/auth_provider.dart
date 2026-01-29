import 'package:flutter/material.dart';
import '../models/user.model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/fcm_service.dart';
import '../api/api_client.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final ApiClient _apiClient = ApiClient();
  final FcmService _fcmService = FcmService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  bool _hasSeenOnboarding = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  /// Login with email and password
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      _user = await _authService.login(email, password);

      // Save token to secure storage if available
      if (_user?.token != null) {
        await _storageService.saveToken(_user!.token!);
        _apiClient.setAuthToken(_user!.token!);
        _isAuthenticated = true;

        // Save user ID and complete user data
        if (_user?.id != null) {
          await _storageService.saveUserId(_user!.id!);
        }
        await _storageService.saveUserData(_user!);

        // Register FCM token with backend after successful login
        await _registerFcmToken();
      }
    } catch (e) {
      // Extract clean error message
      String errorMessage = e.toString();

      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      // Check if it's an authentication error (wrong credentials)
      if (errorMessage.contains('401') ||
          errorMessage.contains('Unauthorized') ||
          errorMessage.contains('Invalid credentials') ||
          errorMessage.contains('Bad credentials') ||
          errorMessage.toLowerCase().contains('wrong')) {
        _error = 'Wrong email or password';
      }
      // Check if it's a server error
      else if (errorMessage.contains('500') ||
          errorMessage.contains('Server error')) {
        _error = 'Server error. Please try again later.';
      }
      // Check if it's a network error
      else if (errorMessage.contains('Connection') ||
          errorMessage.contains('internet') ||
          errorMessage.contains('timeout')) {
        _error = 'Connection error. Please check your internet.';
      }
      // Default to the cleaned error message
      else {
        _error = errorMessage;
      }

      _isAuthenticated = false;
    } finally {
      _setLoading(false);
    }
  }

  /// Signup with user data
  Future<void> signup(Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;

    try {
      _user = await _authService.signup(data);

      // Save token to secure storage if available
      if (_user?.token != null) {
        await _storageService.saveToken(_user!.token!);
        _apiClient.setAuthToken(_user!.token!);
        _isAuthenticated = true;

        // Save user ID and complete user data
        if (_user?.id != null) {
          await _storageService.saveUserId(_user!.id!);
        }
        await _storageService.saveUserData(_user!);

        // Register FCM token with backend after successful signup
        await _registerFcmToken();
      }
    } catch (e) {
      _error = 'Signup failed: ${e.toString()}';
      _isAuthenticated = false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check for stored token and auto-login with backend validation
  /// This validates the token with the backend and fetches fresh user data
  Future<bool> tryAutoLogin() async {
    _setLoading(true);

    // Check onboarding status first
    _hasSeenOnboarding = await _storageService.hasSeenOnboarding();

    try {
      final token = await _storageService.getToken();
      final userId = await _storageService.getUserId();

      if (token != null && token.isNotEmpty && userId != null) {
        // Set token in API client for the validation request
        _apiClient.setAuthToken(token);

        // Validate token and fetch fresh user data from backend
        _user = await _authService.validateTokenAndFetchUser(userId);

        // Token is valid, update storage with fresh data
        await _storageService.saveUserData(_user!);
        _isAuthenticated = true;

        // Register FCM token if not already registered
        await _registerFcmToken();

        _setLoading(false);
        return true;
      }
    } catch (e) {
      print('Auto-login failed: $e');

      // Token is invalid/expired, clear auth data
      await _storageService.clearAuthData();
      _apiClient.clearAuthToken();
      _user = null;
      _isAuthenticated = false;
      _error = null;
    }

    _setLoading(false);
    return false;
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    await _storageService.setOnboardingCompleted();
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  /// Logout - clear token and user data
  Future<void> logout() async {
    try {
      // Remove FCM token from backend
      await _removeFcmToken();

      // Call server logout
      await _authService.logout();

      // Clear auth data (preserves onboarding flag)
      await _storageService.clearAuthData();

      // Clear API client token
      _apiClient.clearAuthToken();

      // Clear user state
      _user = null;
      _isAuthenticated = false;
      _error = null;

      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Register FCM token with backend
  Future<void> _registerFcmToken() async {
    try {
      print('\n' + '=' * 50);
      print('🔑 CHECKING FCM TOKEN FOR REGISTRATION');
      print('=' * 50);
      print('FCM Initialized: ${_fcmService.isInitialized}');
      print('FCM Token Available: ${_fcmService.fcmToken != null}');
      print('FCM Token: ${_fcmService.fcmToken}');
      print('=' * 50 + '\n');

      if (_fcmService.isInitialized && _fcmService.fcmToken != null) {
        print('✅ FCM ready, registering token with backend...');
        await _fcmService.registerTokenWithBackend(_fcmService.fcmToken!);
      } else {
        print('⚠️ FCM not initialized or token not available');
        print('   - Please check Firebase configuration');
        print('   - Ensure google-services.json is in android/app/');
        print('   - Ensure GoogleService-Info.plist is in ios/Runner/');
      }
    } catch (e) {
      print('\n' + '=' * 50);
      print('❌ ERROR IN _registerFcmToken');
      print('=' * 50);
      print('Error: $e');
      print('=' * 50 + '\n');
      // Don't throw - FCM registration failure shouldn't prevent login
    }
  }

  /// Remove FCM token from backend
  Future<void> _removeFcmToken() async {
    try {
      print('📤 Removing FCM token from backend...');
      await _fcmService.removeTokenFromBackend();
    } catch (e) {
      print('❌ Error removing FCM token: $e');
      // Don't throw - FCM removal failure shouldn't prevent logout
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
