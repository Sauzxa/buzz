import 'dart:convert';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/user.model.dart';

class BugReportService {
  final ApiClient _apiClient = ApiClient();

  Future<bool> submitBugReport({
    required UserModel user,
    required String title,
    required String description,
    required String platform,
    required String appVersion,
    required String deviceModel,
    List<String>? steps,
    String? filePath,
  }) async {
    try {
      // Construct the message object
      final messageData = {
        "userId": user.id,
        "userName": user.fullName,
        "email": user.email,
        "title": title,
        "description": description,
        "platform": platform,
        "appVersion": appVersion,
        "deviceModel": deviceModel,
        "steps": steps ?? [],
        "timestamp": DateTime.now().toIso8601String(),
      };

      // Backend expects 'message' as a JSON-encoded STRING, not an object
      final data = {
        'message': jsonEncode(messageData),
        'messageType': 'BUG_REPORT',
      };

      // NOTE: File upload is not supported by the current /api/supportMessage endpoint
      // based on backend code inspection. Ignoring filePath for now to prevent 500 error.
      if (filePath != null && filePath.isNotEmpty) {
        print(
          'Warning: File attachment ignored. Backend endpoint does not support file upload.',
        );
      }

      final response = await _apiClient.post(
        ApiEndpoints.submitSupportMessage,
        data: data,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return true;
      } else {
        throw Exception(
          'Failed to submit bug report: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      throw Exception('Error submitting bug report: $e');
    }
  }

  /// Get all support messages with pagination and optional filtering
  /// Returns a paginated list of support messages
  Future<Map<String, dynamic>> getAllSupportMessages({
    int page = 0,
    int size = 10,
    String? messageType,
  }) async {
    try {
      final endpoint = ApiEndpoints.getAllSupportMessages(
        page: page,
        size: size,
        messageType: messageType,
      );

      final response = await _apiClient.get(endpoint);

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to fetch support messages: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching support messages: $e');
    }
  }

  /// Mark a support message as read
  /// Returns the updated message data
  Future<Map<String, dynamic>> markAsRead(int messageId) async {
    try {
      final endpoint = ApiEndpoints.markSupportMessageAsRead(messageId);

      final response = await _apiClient.patch(endpoint);

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to mark message as read: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      throw Exception('Error marking message as read: $e');
    }
  }
}
