import 'dart:io';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class InvoiceService {
  final ApiClient _apiClient = ApiClient();

  /// Get invoice by order ID
  Future<Map<String, dynamic>?> getInvoiceByOrderId(String orderId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getInvoiceByOrderId(orderId),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        return null; // No invoice found
      } else {
        throw Exception('Failed to load invoice: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching invoice: $e');
      return null;
    }
  }

  /// Upload payment proof for an invoice
  Future<void> uploadPaymentProof(String invoiceId, File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;

      final formData = FormData.fromMap({
        'paymentProof': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.put(
        ApiEndpoints.uploadPaymentProof(invoiceId),
        data: formData,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to upload payment proof: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error uploading payment proof: $e');
      rethrow;
    }
  }
}
