import 'package:flutter/material.dart';
import '../models/user.model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../api/api_client.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final ApiClient _apiClient = ApiClient();

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
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
