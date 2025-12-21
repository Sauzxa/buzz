import 'package:flutter/foundation.dart';
import '../models/user.model.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class UserProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  UserModel _user = UserModel();
  bool _isLoading = false;
  String? _errorMessage;

  UserModel get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get fullName => _user.fullName ?? 'Guest';

  // Get formatted full phone number with country code
  String get fullPhoneNumber {
    if (_user.phoneNumber != null) {
      return _user.phoneNumber.toString();
    }
    return '';
  }

  // Update phone number (local format without country code)
  void setPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters and store as string
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    _user = _user.copyWith(phoneNumber: cleanPhone);
    notifyListeners();
  }

  // Update email
  void setEmail(String email) {
    _user = _user.copyWith(email: email);
    notifyListeners();
  }

  // Update full name
  void setFullName(String fullName) {
    _user = _user.copyWith(fullName: fullName);
    notifyListeners();
  }

  // Update current address
  void setCurrentAddress(String address) {
    _user = _user.copyWith(currentAddress: address);
    notifyListeners();
  }

  // Update code postal
  void setpostalCode(String postalCode) {
    _user = _user.copyWith(postalCode: int.tryParse(postalCode));
    notifyListeners();
  }

  // Update wilaya
  void setWilaya(String wilaya) {
    _user = _user.copyWith(wilaya: wilaya);
    notifyListeners();
  }

  // Update password
  void setPassword(String password) {
    _user = _user.copyWith(password: password);
    notifyListeners();
  }

  // Update entire user model
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// Fetch user data by ID from API
  Future<void> fetchUserById(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.getUserById(userId));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _user = UserModel.fromJson(response.data);
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to load user data: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      print('Error fetching user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all user data
  void clearUser() {
    _user = UserModel();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Check if user has basic info
  bool get hasPhoneNumber => _user.phoneNumber != null;
  bool get hasEmail => _user.email != null && _user.email!.isNotEmpty;
  bool get hasFullName => _user.fullName != null && _user.fullName!.isNotEmpty;
}
