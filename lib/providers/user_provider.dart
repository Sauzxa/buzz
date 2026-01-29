import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
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

  /// Update user profile including optional image
  Future<bool> updateUserProfile({
    required Map<String, dynamic> data,
    dynamic imageFile, // File from dart:io
  }) async {
    print('--- updateUserProfile STARTED ---');
    print('Data received: $data');
    print('Image file provided: ${imageFile != null}');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final formData = FormData();

      // Add User Data as 'request' part (JSON)
      // Backend expects @RequestPart("request") UserUpdateDto
      final jsonString = jsonEncode(data);
      print('Encoding "request" part JSON: $jsonString');

      formData.files.add(
        MapEntry(
          'request',
          MultipartFile.fromString(
            jsonString,
            contentType: MediaType.parse('application/json'),
          ),
        ),
      );

      // Add Profile Image as 'profileImage' part
      // Backend expects @RequestPart("profileImage") MultipartFile
      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        print('Adding "profileImage" part: $fileName');

        formData.files.add(
          MapEntry(
            'profileImage',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
              contentType: MediaType.parse('image/${fileName.split('.').last}'),
            ),
          ),
        );
      }

      final userId = _user.id;
      if (userId == null) throw Exception('User ID is null');

      final url = ApiEndpoints.updateUser(userId);
      print('Sending PUT request to: $url');

      final response = await _apiClient.put(url, data: formData);

      print('Response Status Code: ${response.statusCode}');
      print('Response Status Message: ${response.statusMessage}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh user data to get updated PFP url etc
        await fetchUserById(userId);
        print('--- updateUserProfile SUCCESS ---');
        return true;
      } else {
        _errorMessage = 'Update failed: ${response.statusMessage}';
        print('--- updateUserProfile FAILED: $_errorMessage ---');
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        print('DioException: ${e.message}');
        print('DioException response: ${e.response}');
      }
      _errorMessage = 'Update error: ${e.toString()}';
      print('--- updateUserProfile EXCEPTION: $_errorMessage ---');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete user account (soft delete)
  Future<bool> deleteAccount() async {
    print('--- deleteAccount STARTED ---');
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _user.id;
      if (userId == null) throw Exception('User ID is null');

      final url = ApiEndpoints.deleteUser(userId); // DELETE /api/users/{id}
      print('Sending DELETE request to: $url');

      final response = await _apiClient.delete(url);

      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        print('--- deleteAccount SUCCESS ---');
        // Clear user data
        _user = UserModel();
        return true;
      } else {
        _errorMessage = 'Delete failed: ${response.statusMessage}';
        print('--- deleteAccount FAILED: $_errorMessage ---');
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        print('DioException: ${e.message}');
        print('DioException response: ${e.response}');
        if (e.response?.data != null) {
          _errorMessage = e.response!.data['message'] ?? 'Failed to delete account';
        } else {
          _errorMessage = 'Failed to delete account';
        }
      } else {
        _errorMessage = 'Delete error: ${e.toString()}';
      }
      print('--- deleteAccount EXCEPTION: $_errorMessage ---');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
