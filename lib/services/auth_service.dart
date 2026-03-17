import 'package:flutter/foundation.dart';
import 'package:artifex/models/user.model.dart';
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
      debugPrint('Logout API call failed: $e');
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

  /// Authenticate with Google OAuth
  /// Sends Google ID token to backend for validation
  /// Returns UserModel with JWT tokens on success
  Future<UserModel> googleAuth(String idToken) async {
    try {
      debugPrint('🔵 Sending Google ID token to backend for validation...');

      final response = await _apiClient.post(
        ApiEndpoints.googleAuth,
        data: {'idToken': idToken},
      );

      // Check for server errors (5xx)
      if (response.statusCode != null && response.statusCode! >= 500) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      }

      // Check for authentication errors (401, 403)
      if (response.statusCode == 401 || response.statusCode == 403) {
        String message = 'Google authentication failed';
        if (response.data != null && response.data is Map) {
          message = response.data['message'] ?? message;
        }
        throw Exception(message);
      }

      // Check for other client errors (4xx)
      if (response.statusCode != null && response.statusCode! >= 400) {
        String message = 'Google authentication failed';
        if (response.data != null && response.data is Map) {
          message = response.data['message'] ?? message;
        }
        throw Exception(message);
      }

      // Success response (2xx)
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Google authentication successful');
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Unexpected error occurred');
      }
    } catch (e) {
      debugPrint('❌ Google authentication error: $e');
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

      // Extract message from response body if available
      String extractMessage(String fallback) {
        if (response.data != null && response.data is Map) {
          return response.data['message'] ?? fallback;
        }
        return fallback;
      }

      // 503 = email server (SMTP) is down
      if (response.statusCode == 503) {
        throw Exception(
          extractMessage(
            'Email service is currently unavailable. Please try again later.',
          ),
        );
      }

      // Other server errors (5xx)
      if (response.statusCode != null && response.statusCode! >= 500) {
        throw Exception(
          extractMessage(
            'Server error (${response.statusCode}). Please try again later.',
          ),
        );
      }

      // Client errors (4xx)
      if (response.statusCode != null && response.statusCode! >= 400) {
        throw Exception(extractMessage('Failed to send password reset email'));
      }

      // Success - email sent (200 or 201)
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Unexpected error occurred');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Verify password reset OTP code
  /// Returns success status and remaining attempts on failure
  Future<Map<String, dynamic>> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyResetOtp,
        data: {'email': email, 'otp': otp},
      );

      // Check for server errors (5xx)
      if (response.statusCode != null && response.statusCode! >= 500) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      }

      // Check for client errors (4xx)
      if (response.statusCode != null && response.statusCode! >= 400) {
        String message = 'Failed to verify code';
        if (response.data != null && response.data is Map) {
          message = response.data['message'] ?? message;
        }
        throw Exception(message);
      }

      // Success response (2xx)
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map) {
          return {
            'success': response.data['success'] ?? false,
            'message': response.data['message'] ?? '',
            'remainingAttempts': response.data['remainingAttempts'],
          };
        }
      }

      throw Exception('Unexpected error occurred');
    } catch (e) {
      rethrow;
    }
  }

  /// Resend password reset OTP
  Future<void> resendResetOtp(String email) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resendResetOtp,
        data: {'email': email},
      );

      // Extract message from response body if available
      String extractMessage(String fallback) {
        if (response.data != null && response.data is Map) {
          return response.data['message'] ?? fallback;
        }
        return fallback;
      }

      // 429 = Too many requests (cooldown or max attempts)
      if (response.statusCode == 429) {
        throw Exception(
          extractMessage('Please wait before requesting a new code'),
        );
      }

      // 503 = email server (SMTP) is down
      if (response.statusCode == 503) {
        throw Exception(
          extractMessage(
            'Email service is currently unavailable. Please try again later.',
          ),
        );
      }

      // Other server errors (5xx)
      if (response.statusCode != null && response.statusCode! >= 500) {
        throw Exception(
          extractMessage(
            'Server error (${response.statusCode}). Please try again later.',
          ),
        );
      }

      // Client errors (4xx)
      if (response.statusCode != null && response.statusCode! >= 400) {
        throw Exception(extractMessage('Failed to resend code'));
      }

      // Success - code sent (200 or 201)
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Unexpected error occurred');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password with OTP from email
  /// Validates OTP and sets new password
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'otp': otp,
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

  /// Change password for authenticated user
  /// Requires current password and new password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmNewPassword':
              confirmPassword, // Backend expects confirmNewPassword not confirmPassword
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
        String message = 'Failed to change password';
        if (response.data != null && response.data is Map) {
          message = response.data['message'] ?? message;
        }
        throw Exception(message);
      }

      // Success - password changed
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Unexpected error occurred');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Send email verification OTP
  /// Sends a 5-digit verification code to the provided email address
  Future<void> sendEmailVerification(String email) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.sendEmailVerification,
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
        String message = 'Failed to send verification email';
        if (response.data != null && response.data is Map) {
          message = response.data['message'] ?? message;
        }
        throw Exception(message);
      }

      // Success
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Unexpected error occurred');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Verify email with OTP code
  /// Returns success status and remaining attempts
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyEmail,
        data: {'email': email, 'otp': otp},
      );

      // Check for server errors (5xx)
      if (response.statusCode != null && response.statusCode! >= 500) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      }

      // Parse response data
      if (response.data != null && response.data is Map) {
        return {
          'success': response.data['success'] ?? false,
          'message': response.data['message'] ?? 'Verification failed',
          'remainingAttempts': response.data['remainingAttempts'],
        };
      }

      return {
        'success': false,
        'message': 'Unexpected response format',
        'remainingAttempts': null,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Resend email verification OTP
  Future<void> resendEmailVerification(String email) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resendEmailVerification,
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
        String message = 'Failed to resend verification code';
        if (response.data != null && response.data is Map) {
          message = response.data['message'] ?? message;
        }
        throw Exception(message);
      }

      // Success
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Unexpected error occurred');
      }
    } catch (e) {
      rethrow;
    }
  }
}
