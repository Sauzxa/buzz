import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();

  Future<int> createOrder({
    required String serviceId,
    required Map<String, dynamic> formData,
    List<File>? files,
  }) async {
    try {
      // Step 1: Create Order (JSON)
      // Prepare the request body
      final Map<String, dynamic> orderData = {
        'serviceId': int.parse(serviceId),
      };

      // Field name mappings for plural -> singular conversions
      const Map<String, String> fieldMappings = {
        'wantedFormats': 'wantedFormat',
        // Add more mappings here if needed
      };

      // Fields that contain enum values (need to be uppercase)
      const Set<String> enumFields = {
        'wantedFormat',
        'projectFormat',
        'projectFormats',
        'paperFormat',
        'productFormat',
        'designType',
        'printType',
        'support',
      };

      // Normalize formData keys to camelCase to match backend DTO
      // Handles: "Title" -> "title", "target_audience" -> "targetAudience", "tone-Style" -> "toneStyle"
      formData.forEach((key, value) {
        if (value != null) {
          String normalizedKey = _toCamelCase(key);

          // Apply field name mappings (e.g., plural -> singular)
          normalizedKey = fieldMappings[normalizedKey] ?? normalizedKey;

          // Convert enum values to uppercase (backend expects UPPERCASE enums)
          dynamic normalizedValue = value;
          if (enumFields.contains(normalizedKey) && value is String) {
            normalizedValue = value.toUpperCase();
          }

          orderData[normalizedKey] = normalizedValue;
        }
      });

      print('Creating order with data: $orderData');

      final response = await _apiClient.post(
        ApiEndpoints.createOrder,
        data: jsonEncode(orderData), // Send as raw JSON string
        // Content-Type: application/json is set by default in ApiClient
      );

      print('\n' + '=' * 50);
      print('📦 ORDER CREATION RESPONSE');
      print('=' * 50);
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('=' * 50 + '\n');

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw Exception(
          'Failed to create order: ${response.statusCode} ${response.data}',
        );
      }

      // Extract order ID from response
      // Response data might be a Map or a JSON String depending on Dio interceptor
      final responseData = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final orderId = responseData['id'];
      if (orderId == null) {
        throw Exception('Order created but ID was missing in response');
      }

      print('\n✅ Order created successfully. ID: $orderId');
      print('⏳ Backend should now send ORDER_CREATED notification...\n');

      // Step 2: Upload Files (Multipart)
      if (files != null && files.isNotEmpty) {
        await _uploadFiles(orderId.toString(), files);
      }

      return orderId;
    } catch (e) {
      print('Error in createOrder: $e');
      rethrow;
    }
  }

  Future<void> _uploadFiles(String orderId, List<File> files) async {
    final endpoint = ApiEndpoints.uploadOrderFile(orderId);

    for (var file in files) {
      try {
        String fileName = file.path.split('/').last;

        // Create FormData for file upload
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path, filename: fileName),
          // 'description': 'Uploaded via mobile app' // Optional
        });

        print('Uploading file: $fileName to $endpoint');

        final response = await _apiClient.post(
          endpoint,
          data: formData,
          // Dio handles Content-Type for FormData automatically (multipart/form-data)
        );

        if (response.statusCode != null &&
            (response.statusCode! < 200 || response.statusCode! >= 300)) {
          // We log error but don't stop the whole process if one file fails?
          // Better to throw so user knows something went wrong.
          throw Exception(
            'Failed to upload file $fileName: ${response.statusCode}',
          );
        }
        print('File $fileName uploaded successfully');
      } catch (e) {
        print('Error uploading file: $e');
        // Decide if we want to fail the whole order or just continue
        // Throwing here to alert the user that the order is incomplete
        throw Exception(
          'Failed to upload file ${file.path.split('/').last}: $e',
        );
      }
    }
  }

  /// Get all orders for a customer (regardless of status)
  Future<List<dynamic>> getAllOrders(String customerId) async {
    try {
      print('🔍 [ORDER_SERVICE] Fetching all orders for customer: $customerId');

      final response = await _apiClient.get(
        ApiEndpoints.getAllOrdersByCustomer(customerId),
      );

      print('📡 [ORDER_SERVICE] Response status: ${response.statusCode}');
      print(
        '📦 [ORDER_SERVICE] Response data type: ${response.data.runtimeType}',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Check if response has paginated content
        if (data is Map<String, dynamic> && data.containsKey('content')) {
          final orders = data['content'] as List<dynamic>;
          print(
            '✅ [ORDER_SERVICE] Found ${orders.length} orders in paginated response',
          );
          return orders;
        }

        // Check if response is directly a list
        if (data is List<dynamic>) {
          print(
            '✅ [ORDER_SERVICE] Found ${data.length} orders in list response',
          );
          return data;
        }

        print('⚠️ [ORDER_SERVICE] Unexpected response format: $data');
        return [];
      } else {
        throw Exception('Failed to load all orders: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [ORDER_SERVICE] Error fetching all orders: $e');
      rethrow;
    }
  }

  /// Get active orders for a customer
  Future<List<dynamic>> getActiveOrders(String customerId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getActiveOrdersByCustomer(customerId),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('content')) {
          return data['content'] as List<dynamic>;
        }
        return [];
      } else {
        throw Exception('Failed to load active orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching active orders: $e');
      rethrow;
    }
  }

  /// Get archived orders for a customer
  Future<List<dynamic>> getArchivedOrders(String customerId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getArchivedOrdersByCustomer(customerId),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('content')) {
          return data['content'] as List<dynamic>;
        }
        return [];
      } else {
        throw Exception(
          'Failed to load archived orders: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching archived orders: $e');
      rethrow;
    }
  }

  /// Get order by ID
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getOrderById(orderId));

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load order details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching order details: $e');
      rethrow;
    }
  }

  /// Cancel an order
  Future<void> cancelOrder(String orderId) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.cancelOrder(orderId),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel order: ${response.statusCode}');
      }
    } catch (e) {
      print('Error cancelling order: $e');
      rethrow;
    }
  }

  /// Helper method to convert strings to camelCase
  /// Handles: "Title" -> "title", "target_audience" -> "targetAudience", "tone-Style" -> "toneStyle"
  String _toCamelCase(String input) {
    if (input.isEmpty) return input;

    // Replace underscores and hyphens with spaces, then split
    String normalized = input.replaceAll('_', ' ').replaceAll('-', ' ');
    List<String> words = normalized.split(' ');

    if (words.isEmpty) return input;

    // First word: lowercase
    String result = words[0][0].toLowerCase() + words[0].substring(1);

    // Remaining words: capitalize first letter
    for (int i = 1; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        result += words[i][0].toUpperCase() + words[i].substring(1);
      }
    }

    return result;
  }
}
