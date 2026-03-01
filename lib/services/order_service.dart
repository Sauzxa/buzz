import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import 'cache_service.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();
  final CacheService _cache = CacheService();
  static const String _cacheKeyPrefix = 'cache_order_';

  Future<int> createOrder({
    required String serviceId,
    required Map<String, dynamic> formData,
    List<File>? files,
  }) async {
    int? createdOrderId;
    bool isPrintingService = false;

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

      // Extract order ID and status from response
      final responseData = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      // Handle case where backend returns { "order": { "id": ... } }
      final orderResponse =
          responseData is Map && responseData.containsKey('order')
          ? responseData['order']
          : responseData;

      final orderId = orderResponse['id'];
      final orderStatus = orderResponse['status'];

      if (orderId == null) {
        throw Exception('Order created but ID was missing in response');
      }

      // Store the created order ID for potential rollback
      createdOrderId = orderId;

      // Check if this is a printing service with auto-invoice (status will be PRICED)
      isPrintingService = orderStatus == 'PRICED';

      if (isPrintingService) {
        print(
          '\n✅ Printing order created with auto-invoice. ID: $orderId, Status: PRICED',
        );
        print('✅ Invoice automatically created with 24h payment deadline');
        print('⏳ Backend sent ORDER_CREATED and ORDER_PRICED notifications\n');
      } else {
        print('\n✅ Order created successfully. ID: $orderId, Status: DRAFT');
      }

      // Step 2: Upload Files (if provided)
      if (files != null && files.isNotEmpty) {
        print('📤 Starting file upload for order $orderId...');
        print(
          '⚠️  If file upload fails, order $orderId will be deleted automatically.\n',
        );

        try {
          await _uploadFiles(orderId.toString(), files);
          print('\n✅ All files uploaded successfully for order $orderId');
        } catch (fileUploadError) {
          print('\n❌ File upload failed for order $orderId: $fileUploadError');
          print('🔄 Rolling back: Deleting order $orderId...\n');

          // ROLLBACK: Delete the DRAFT order since file upload failed
          await _rollbackOrder(orderId.toString());

          // Re-throw the error with a clear message
          throw Exception(
            'File upload failed. Order has been deleted. Error: $fileUploadError',
          );
        }
      }

      // Step 3: Submit Order (only for non-printing services in DRAFT status)
      if (!isPrintingService) {
        print('📤 Submitting order $orderId (DRAFT → PENDING)...\n');

        try {
          await _submitOrder(orderId.toString());
          print('\n✅ Order submitted successfully. Status: PENDING');
          print('⏳ Backend sent ORDER_CREATED notification to admin\n');
        } catch (submitError) {
          print('\n❌ Order submission failed for order $orderId: $submitError');
          print('🔄 Rolling back: Deleting order $orderId...\n');

          // ROLLBACK: Delete the DRAFT order since submission failed
          await _rollbackOrder(orderId.toString());

          // Re-throw the error with a clear message
          throw Exception(
            'Order submission failed. Order has been deleted. Error: $submitError',
          );
        }
      }

      print('\n🎉 Order $orderId created and processed successfully!\n');
      return orderId;
    } catch (e) {
      print('❌ Error in createOrder: $e');

      // If we have a created order ID and the error wasn't from rollback itself,
      // ensure we attempt rollback
      if (createdOrderId != null &&
          !e.toString().contains('Order has been deleted') &&
          !e.toString().contains('Order has been cancelled')) {
        try {
          await _rollbackOrder(createdOrderId.toString());
        } catch (rollbackError) {
          print('⚠️  Rollback also failed: $rollbackError');
        }
      }

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

  /// Submit order after file upload (DRAFT → PENDING)
  /// This triggers the OrderCreatedEvent notification to admin
  Future<void> _submitOrder(String orderId) async {
    try {
      print('� Submitting order $orderId...');

      final response = await _apiClient.post(ApiEndpoints.submitOrder(orderId));

      if (response.statusCode != null &&
          (response.statusCode! >= 200 && response.statusCode! < 300)) {
        print('✅ Order $orderId submitted successfully (DRAFT → PENDING)');
      } else {
        print('⚠️  Failed to submit order $orderId: ${response.statusCode}');
        throw Exception('Submit failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error during order submission: $e');
      throw Exception('Failed to submit order $orderId: $e');
    }
  }

  /// Rollback (cancel/delete) an order if file upload fails
  /// This ensures no incomplete orders exist in the system
  Future<void> _rollbackOrder(String orderId) async {
    try {
      print('🔄 Attempting to delete DRAFT order $orderId due to failure...');

      final response = await _apiClient.delete(
        ApiEndpoints.deleteDraftOrder(orderId),
      );

      if (response.statusCode != null &&
          (response.statusCode! >= 200 && response.statusCode! < 300)) {
        print('✅ Order $orderId successfully deleted (rolled back)');
        print('✅ Associated files removed from MinIO storage');
      } else {
        print('⚠️  Failed to delete order $orderId: ${response.statusCode}');
        throw Exception('Rollback failed: Could not delete order $orderId');
      }
    } catch (e) {
      print('❌ Error during order rollback: $e');
      // Don't rethrow here - we want to preserve the original file upload error
      // Just log that rollback failed
      throw Exception('Failed to rollback order $orderId: $e');
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

  /// Get order by ID with caching and retry logic
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final cacheKey = '$_cacheKeyPrefix$orderId';

    // Try to get from cache first
    try {
      final cached = await _cache.get(cacheKey);
      if (cached != null) {
        print('✅ [ORDER] Loaded order $orderId from cache');
        // Return cached data immediately, but fetch fresh data in background
        _fetchAndCacheOrder(orderId, cacheKey);
        return cached as Map<String, dynamic>;
      }
    } catch (e) {
      print('⚠️ [ORDER] Cache read error: $e');
    }

    // If not in cache, fetch from API
    return await _fetchAndCacheOrder(orderId, cacheKey);
  }

  /// Fetch order from API and cache it
  Future<Map<String, dynamic>> _fetchAndCacheOrder(
    String orderId,
    String cacheKey,
  ) async {
    int retryCount = 0;
    const maxRetries = 3;
    Duration retryDelay = const Duration(seconds: 1);

    while (retryCount < maxRetries) {
      try {
        print('🔍 [ORDER] Fetching order $orderId (attempt ${retryCount + 1})');

        final response = await _apiClient
            .get(ApiEndpoints.getOrderById(orderId))
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Request timed out');
              },
            );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;

          // Cache the response for 5 minutes
          try {
            await _cache.set(cacheKey, data, ttl: const Duration(minutes: 5));
            print('✅ [ORDER] Cached order $orderId');
          } catch (e) {
            print('⚠️ [ORDER] Cache write error: $e');
          }

          return data;
        } else {
          throw Exception(
            'Failed to load order details: ${response.statusCode}',
          );
        }
      } catch (e) {
        retryCount++;
        print(
          '❌ [ORDER] Error fetching order $orderId (attempt $retryCount): $e',
        );

        if (retryCount >= maxRetries) {
          print('❌ [ORDER] Max retries reached for order $orderId');
          rethrow;
        }

        // Wait before retrying with exponential backoff
        await Future.delayed(retryDelay);
        retryDelay *= 2; // Double the delay for next retry
      }
    }

    throw Exception('Failed to fetch order after $maxRetries attempts');
  }

  /// Cancel an order
  Future<void> cancelOrder(String orderId) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.cancelOrder(orderId),
      );

      // Accept any 2xx response (200 OK or 204 No Content)
      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        final msg = response.data is String
            ? response.data as String
            : 'status ${response.statusCode}';
        throw Exception('Failed to cancel order: $msg');
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
