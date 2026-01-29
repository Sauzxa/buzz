import 'package:flutter/material.dart';
import '../models/user.model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/fcm_service.dart';
import '../api/api_client.dart';
import '../utils/jwt_decoder.dart';

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
        // Save refresh token if available
        if (_user?.refreshToken != null) {
          await _storageService.saveRefreshToken(_user!.refreshToken!);
        }
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
        // Save refresh token if available
        if (_user?.refreshToken != null) {
          await _storageService.saveRefreshToken(_user!.refreshToken!);
        }
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
      final refreshToken = await _storageService.getRefreshToken();
      final userId = await _storageService.getUserId();

      if (token != null && token.isNotEmpty && userId != null) {
        // Check if access token is expired or will expire soon (within 3 minutes)
        if (JwtDecoder.isExpired(token) ||
            JwtDecoder.willExpireSoon(token, const Duration(minutes: 3))) {
          print(
            '🔄 Access token expired or expiring soon, attempting refresh...',
          );

          // Try to refresh the token
          if (refreshToken != null && !JwtDecoder.isExpired(refreshToken)) {
            try {
              final refreshedUser = await _authService.refreshAccessToken(
                refreshToken,
              );

              // Save new tokens
              if (refreshedUser.token != null) {
                await _storageService.saveToken(refreshedUser.token!);
                _apiClient.setAuthToken(refreshedUser.token!);
              }
              if (refreshedUser.refreshToken != null) {
                await _storageService.saveRefreshToken(
                  refreshedUser.refreshToken!,
                );
              }

              // Update user data
              _user = refreshedUser;
              await _storageService.saveUserData(_user!);
              _isAuthenticated = true;

              // Register FCM token if not already registered
              await _registerFcmToken();

              _setLoading(false);
              print('✅ Token refreshed successfully during auto-login');
              return true;
            } catch (refreshError) {
              print('❌ Token refresh failed: $refreshError');
              // If refresh fails, clear auth and require re-login
              await _storageService.clearAuthData();
              _apiClient.clearAuthToken();
              _user = null;
              _isAuthenticated = false;
              _setLoading(false);
              return false;
            }
          } else {
            print('❌ Refresh token expired or unavailable');
            await _storageService.clearAuthData();
            _apiClient.clearAuthToken();
            _user = null;
            _isAuthenticated = false;
            _setLoading(false);
            return false;
          }
        }

        // Token is still valid, set it and validate with backend
        _apiClient.setAuthToken(token);

        try {
          // Validate token and fetch fresh user data from backend
          _user = await _authService.validateTokenAndFetchUser(userId);

          // Token is valid, update storage with fresh data
          await _storageService.saveUserData(_user!);
          _isAuthenticated = true;

          // Register FCM token if not already registered
          await _registerFcmToken();

          _setLoading(false);
          return true;
        } catch (validationError) {
          // Check if it's a network error
          if (validationError.toString().contains('Connection') ||
              validationError.toString().contains('timeout') ||
              validationError.toString().contains('internet')) {
            print('⚠️ Network error during validation, using cached data');
            // Use cached user data on network errors
            final cachedUser = await _storageService.getUserData();
            if (cachedUser != null) {
              _user = cachedUser;
              _isAuthenticated = true;
              _setLoading(false);
              return true;
            }
          }

          // For auth errors or if no cached data, logout
          throw validationError;
        }
      }
    } catch (e) {
      print('Auto-login failed: $e');

      // Check if it's a network error - keep user logged in
      if (e is NetworkException ||
          e.toString().contains('Connection') ||
          e.toString().contains('timeout') ||
          e.toString().contains('internet')) {
        print('⚠️ Network error, attempting to use cached data');
        final cachedUser = await _storageService.getUserData();
        final token = await _storageService.getToken();
        if (cachedUser != null &&
            token != null &&
            !JwtDecoder.isExpired(token)) {
          _user = cachedUser;
          _apiClient.setAuthToken(token);
          _isAuthenticated = true;
          _setLoading(false);
          return true;
        }
      }

      // For non-network errors or expired tokens, clear auth data
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

  /// Request password reset link
  /// Sends a password reset email to the provided email address
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.forgotPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      // Extract clean error message
      String errorMessage = e.toString();

      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      _error = errorMessage;
      _setLoading(false);
      return false;
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
