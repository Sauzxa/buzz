import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/config.dart';
import '../services/storage_service.dart';
import '../utils/jwt_decoder.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio _dio;
  final StorageService _storageService = StorageService();
  bool _isRefreshing = false;

  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        // Minimal headers like Postman
        headers: {'Content-Type': 'application/json'},
        validateStatus: (status) {
          // Accept all status codes to handle them manually
          return status != null && status < 600;
        },
        // Use custom transformer to handle malformed JSON
        responseType: ResponseType.plain, // Get response as string first
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Force logging for debugging
          print('REQUEST[${options.method}] => ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Force logging for debugging
          print(
            'RESPONSE[${response.statusCode}] => ${response.requestOptions.path}',
          );

          // Parse JSON response
          if (response.data is String && response.data.toString().isNotEmpty) {
            try {
              response.data = jsonDecode(response.data as String);
            } catch (e) {
              print('❌ [API_CLIENT] JSON parse error: $e');
              print('❌ [API_CLIENT] Raw response: ${response.data}');
            }
          }

          return handler.next(response);
        },
        onError: (error, handler) async {
          // Force logging for debugging
          print(
            'ERROR[${error.response?.statusCode}] => ${error.requestOptions.path}',
          );
          print('Error type: ${error.type}');
          print('Error message: ${error.message}');
          if (error.response != null) {
            print('Error response data: ${error.response?.data}');
          }

          // Handle 401 errors with automatic token refresh
          if (error.response?.statusCode == 401) {
            // Don't retry if this is already a refresh token request or logout
            if (error.requestOptions.path.contains('/auth/refresh') ||
                error.requestOptions.path.contains('/auth/logout')) {
              return handler.next(error);
            }

            try {
              // Attempt to refresh token
              final newAccessToken = await _refreshToken();

              if (newAccessToken != null) {
                // Update the failed request with new token
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';

                // Retry the original request
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } else {
                // Refresh failed, propagate error
                return handler.next(error);
              }
            } catch (refreshError) {
              print('Token refresh failed: $refreshError');
              // Clear auth data on refresh failure
              await _storageService.clearAuthData();
              clearAuthToken();
              return handler.next(error);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// Refresh access token using stored refresh token
  /// Returns new access token or null if refresh fails
  Future<String?> _refreshToken() async {
    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      // Wait for ongoing refresh to complete
      await Future.delayed(const Duration(milliseconds: 500));
      return await _storageService.getToken();
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storageService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        print('No refresh token available');
        return null;
      }

      // Check if refresh token is expired
      if (JwtDecoder.isExpired(refreshToken)) {
        print('Refresh token is expired');
        return null;
      }

      // Call refresh endpoint
      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response
        final data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;

        final newAccessToken = data['accessToken']?.toString();
        final newRefreshToken = data['refreshToken']?.toString();

        if (newAccessToken != null) {
          // Save new tokens
          await _storageService.saveToken(newAccessToken);
          if (newRefreshToken != null) {
            await _storageService.saveRefreshToken(newRefreshToken);
          }

          // Update client headers
          setAuthToken(newAccessToken);

          print('✅ Token refreshed successfully');
          return newAccessToken;
        }
      }

      return null;
    } catch (e) {
      print('Error during token refresh: $e');
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  // Getter for current headers (for debugging)
  Map<String, dynamic> get currentHeaders => _dio.options.headers;

  // GET request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      // Enhanced logging for debugging
      print('🔴 [API_CLIENT] DioException caught for: $endpoint');
      print('🔴 [API_CLIENT] Error type: ${e.type}');
      print('🔴 [API_CLIENT] Error message: ${e.message}');
      print('🔴 [API_CLIENT] Response status: ${e.response?.statusCode}');
      print('🔴 [API_CLIENT] Response data: ${e.response?.data}');
      print('🔴 [API_CLIENT] Response headers: ${e.response?.headers}');
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Error handler
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        // Network errors - don't logout
        return NetworkException(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data['message'] ?? 'Something went wrong';

        switch (statusCode) {
          case 400:
            return Exception('Bad request: $message');
          case 401:
            // Auth error - will be handled by interceptor
            return AuthException('Unauthorized: $message');
          case 403:
            return Exception('Forbidden: $message');
          case 404:
            return Exception('Not found: $message');
          case 500:
            return Exception('Server error: $message');
          default:
            return Exception('Error $statusCode: $message');
        }

      case DioExceptionType.cancel:
        return Exception('Request cancelled');

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          // Network error - don't logout
          return NetworkException('No internet connection');
        }
        return NetworkException('Unexpected error occurred: ${error.message}');

      default:
        return Exception('Something went wrong: ${error.type}');
    }
  }
}

/// Custom exception for network errors
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
