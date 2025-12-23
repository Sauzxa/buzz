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

      // Check for client errors from response data if status is 200 but contains error
      // or if status code is 4xx (handled by dio exception usually, but safe to check)

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        // Try to extract error message
        final message = response.data['message'] ?? 'Login failed';
        throw Exception(message);
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
}
