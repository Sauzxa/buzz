import 'package:buzz/models/user.model.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      // Check for server errors (5xx)
      if (response.statusCode != null && response.statusCode! >= 500) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      }

      // Check for authentication errors (401, 403)
      if (response.statusCode == 401 || response.statusCode == 403) {
        // Try to extract error message from backend
        String message = 'Wrong email or password';
        if (response.data != null && response.data is Map) {
          message = response.data['message'] ?? message;
        }
        throw Exception(message);
      }

      // Check for other client errors (4xx)
      if (response.statusCode != null && response.statusCode! >= 400) {
        String message = 'Login failed';
        if (response.data != null && response.data is Map) {
          message = response.data['message'] ?? message;
        }
        throw Exception(message);
      }

      // Success response (2xx)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        // Unexpected status code
        throw Exception('Unexpected error occurred');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (e) {
      // Log error but don't stop local logout
      print('Logout API call failed: $e');
    }
  }

  /// Refresh access token using refresh token
  /// Returns a new UserModel with updated access and refresh tokens
  Future<UserModel> refreshAccessToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      // Check for server errors (5xx)
      if (response.statusCode != null && response.statusCode! >= 500) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      }

      // Check for authentication errors (401, 403)
      if (response.statusCode == 401 || response.statusCode == 403) {
        String message = 'Refresh token expired or invalid';
        if (response.data != null && response.data is Map) {
          message = response.data['message'] ?? message;
        }
        throw Exception(message);
      }

      // Check for other client errors (4xx)
      if (response.statusCode != null && response.statusCode! >= 400) {
        String message = 'Token refresh failed';
        if (response.data != null && response.data is Map) {
          message = response.data['message'] ?? message;
        }
        throw Exception(message);
      }

      // Success response (2xx)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Unexpected error occurred during token refresh');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Validate token and fetch fresh user data from backend
  /// This is used during auto-login to ensure the token is still valid
  /// and to get the latest user profile data
  Future<UserModel> validateTokenAndFetchUser(String userId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getUserById(userId));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else if (response.statusCode == 401) {
        throw Exception('Token expired or invalid');
      } else {
        throw Exception('Failed to validate user: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> signup(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.signup, data: data);

      // Check for server errors (5xx)
      if (response.statusCode != null && response.statusCode! >= 500) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later or contact support.',
        );
      }

      // Check for client errors (4xx)
      if (response.statusCode != null && response.statusCode! >= 400) {
        throw Exception(
          'Request error (${response.statusCode}): ${response.data}',
        );
      }

      // Success response (2xx)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Request password reset link via email
  /// Sends a password reset email to the provided email address
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      // Check for server errors (5xx)
      if (response.statusCode != null && response.statusCode! >= 500) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      }

      // Check for client errors (4xx)
      if (response.statusCode != null && response.statusCode! >= 400) {
        String message = 'Failed to send password reset email';
        if (response.data != null && response.data is Map) {
          message = response.data['message'] ?? message;
        }
        throw Exception(message);
      }

      // Success - email sent
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Unexpected error occurred');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password with token from email
  /// Validates token and sets new password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      // Check for server errors (5xx)
      if (response.statusCode != null && response.statusCode! >= 500) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      }

      // Check for client errors (4xx)
      if (response.statusCode != null && response.statusCode! >= 400) {
        String message = 'Failed to reset password';
        if (response.data != null && response.data is Map) {
          message = response.data['message'] ?? message;
        }
        throw Exception(message);
      }

      // Success - password reset
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Unexpected error occurred');
      }
    } catch (e) {
      rethrow;
    }
  }
}
