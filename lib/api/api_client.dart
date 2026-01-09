import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/config.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio _dio;

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
        onError: (error, handler) {
          // Force logging for debugging
          print(
            'ERROR[${error.response?.statusCode}] => ${error.requestOptions.path}',
          );
          print('Error type: ${error.type}');
          print('Error message: ${error.message}');
          if (error.response != null) {
            print('Error response data: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
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
        return Exception(
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
            return Exception('Unauthorized: $message');
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
          return Exception('No internet connection');
        }
        return Exception('Unexpected error occurred: ${error.message}');

      default:
        return Exception('Something went wrong: ${error.type}');
    }
  }
}
