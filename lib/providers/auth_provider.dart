import 'package:flutter/material.dart';
import '../models/user.model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      _user = await _authService.login(email, password);
    } catch (e) {
      _error = 'Login failed';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signup(Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;

    try {
      _user = await _authService.signup(data);
    } catch (e) {
      _error = 'Signup failed';
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
