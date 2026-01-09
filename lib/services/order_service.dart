import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();

  Future<void> createOrder({
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

      // Normalize formData keys to lowercase first letter (camelCase) to match backend DTO
      // e.g. "Title" -> "title", "Objectives" -> "objectives"
      formData.forEach((key, value) {
        if (value != null) {
          String normalizedKey = key;
          if (key.isNotEmpty) {
            normalizedKey = key[0].toLowerCase() + key.substring(1);
          }
          orderData[normalizedKey] = value;
        }
      });

      print('Creating order with data: $orderData');

      final response = await _apiClient.post(
        ApiEndpoints.createOrder,
        data: jsonEncode(orderData), // Send as raw JSON string
        // Content-Type: application/json is set by default in ApiClient
      );

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

      print('Order created successfully. ID: $orderId');

      // Step 2: Upload Files (Multipart)
      if (files != null && files.isNotEmpty) {
        await _uploadFiles(orderId.toString(), files);
      }
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
}
