import 'dart:io';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/invoice_model.dart';
import 'cache_service.dart';

class InvoiceService {
  final ApiClient _apiClient = ApiClient();
  final CacheService _cache = CacheService();
  static const String _cacheKeyPrefix = 'cache_invoice_';

  /// Get invoice by order ID with caching
  Future<InvoiceModel?> getInvoiceByOrderId(String orderId) async {
    final cacheKey = '$_cacheKeyPrefix$orderId';

    // Try to get from cache first
    try {
      final cached = await _cache.get(cacheKey);
      if (cached != null) {
        print('✅ [INVOICE] Loaded invoice for order $orderId from cache');
        // Return cached data immediately, fetch fresh in background
        _fetchAndCacheInvoice(orderId, cacheKey);
        return InvoiceModel.fromJson(cached as Map<String, dynamic>);
      }
    } catch (e) {
      print('⚠️ [INVOICE] Cache read error: $e');
    }

    // If not in cache, fetch from API
    return await _fetchAndCacheInvoice(orderId, cacheKey);
  }

  /// Fetch invoice from API and cache it with retry logic
  Future<InvoiceModel?> _fetchAndCacheInvoice(
    String orderId,
    String cacheKey,
  ) async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelays = [
      Duration(seconds: 2),
      Duration(seconds: 5),
      Duration(seconds: 10),
    ];

    while (retryCount <= maxRetries) {
      try {
        if (retryCount > 0) {
          print(
            '🔄 [INVOICE] Retry attempt $retryCount/$maxRetries for order $orderId...',
          );
        }

        final response = await _apiClient.get(
          ApiEndpoints.getInvoiceByOrderId(orderId),
        );

        // 404 or any non-200 where data is plaintext — no invoice exists yet
        if (response.statusCode == 404 || response.statusCode == null) {
          return null;
        }

        if (response.statusCode == 200) {
          // Guard: backend may return plain text even on 200 if something is off
          if (response.data is! Map<String, dynamic>) {
            print(
              '⚠️ [INVOICE_SERVICE] Unexpected response type for order $orderId: ${response.data.runtimeType}',
            );
            return null;
          }

          final invoiceData = response.data as Map<String, dynamic>;

          // Cache the invoice for 5 minutes
          try {
            await _cache.set(
              cacheKey,
              invoiceData,
              ttl: const Duration(minutes: 5),
            );
            print('✅ [INVOICE] Cached invoice for order $orderId');
          } catch (e) {
            print('⚠️ [INVOICE] Cache write error: $e');
          }

          return InvoiceModel.fromJson(invoiceData);
        }

        // Any other non-success status
        final msg = response.data is String
            ? response.data as String
            : 'status ${response.statusCode}';

        // Don't retry on 4xx client errors
        if (response.statusCode != null &&
            response.statusCode! >= 400 &&
            response.statusCode! < 500) {
          throw Exception('Failed to load invoice: $msg');
        }

        // Retry on 5xx server errors
        throw Exception('Server error: $msg');
      } catch (e) {
        print(
          '⚠️ [INVOICE_SERVICE] Error fetching invoice for order $orderId: $e',
        );

        // Check if we should retry
        if (retryCount < maxRetries &&
            !e.toString().contains('Failed to load invoice')) {
          final delay = retryDelays[retryCount];
          print('⏳ [INVOICE] Waiting ${delay.inSeconds}s before retry...');
          await Future.delayed(delay);
          retryCount++;
        } else {
          rethrow;
        }
      }
    }

    // If all retries failed
    throw Exception('Invoice request failed after $maxRetries retries');
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
        // Extract user-friendly error message
        String errorMessage = 'Failed to upload payment proof';

        if (response.statusCode == 400) {
          final responseData = response.data;
          if (responseData is String) {
            // Check for specific error patterns
            if (responseData.contains('ESPECE') ||
                responseData.toLowerCase().contains('cash')) {
              errorMessage = 'Cash payments do not require receipt upload';
            } else if (responseData.contains('status')) {
              errorMessage = 'Payment proof cannot be uploaded at this time';
            } else {
              errorMessage = 'Invalid payment proof upload';
            }
          }
        } else if (response.statusCode == 403) {
          errorMessage = 'You do not have permission to upload this receipt';
        } else if (response.statusCode == 404) {
          errorMessage = 'Invoice not found';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error uploading payment proof: $e');
      rethrow;
    }
  }
}
