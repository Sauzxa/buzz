import 'package:buzz/models/user.model.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<UserModel> login(String email, String password) async {
    // example request - you can implement this similarly to signup
    final response = {"id": "1", "email": email, "token": "jwt_token_here"};

    return UserModel.fromJson(response);
  }

  Future<UserModel> signup(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.singup, data: data);

      // Check for server errors (5xx)
      if (response.statusCode! >= 500) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later or contact support.',
        );
      }

      // Check for client errors (4xx)
      if (response.statusCode! >= 400) {
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
