import 'package:flutter/foundation.dart';
import '../models/service_model.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

enum LoadingState { idle, loading, success, error }

class ServicesProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  LoadingState _state = LoadingState.idle;
  List<ServiceModel> _services = [];
  String? _errorMessage;

  // Configuration for "Other Services" section
  static const int maxServicesPerCategory = 4;

  // Getters
  LoadingState get state => _state;
  List<ServiceModel> get services => _services;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LoadingState.loading;
  bool get hasError => _state == LoadingState.error;
  bool get hasData => _services.isNotEmpty;

  /// Fetch all services from API
  Future<void> fetchServices() async {
    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔍 [SERVICES] Starting fetch...');
      print(
        '🔑 [SERVICES] Auth header: ${_apiClient.currentHeaders['Authorization']}',
      );

      final response = await _apiClient.get(ApiEndpoints.getAllServices);

      print('📡 [SERVICES] Response Status: ${response.statusCode}');
      print('📦 [SERVICES] Response Data Type: ${response.data.runtimeType}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if response.data is actually a List
        if (response.data is! List) {
          print('❌ [SERVICES] ERROR: Expected List but got: ${response.data}');
          _state = LoadingState.error;
          _errorMessage = 'Invalid response format from server';
          notifyListeners();
          return;
        }

        final List<dynamic> data = response.data as List<dynamic>;
        print('✅ [SERVICES] Services count: ${data.length}');

        // Debug: Print first service structure
        if (data.isNotEmpty) {
          print(
            '🔍 [SERVICES] First service keys: ${(data[0] as Map).keys.toList()}',
          );
          print(
            '🔍 [SERVICES] formFields type: ${(data[0] as Map)['formFields'].runtimeType}',
          );
          if ((data[0] as Map)['formFields'] != null) {
            print(
              '🔍 [SERVICES] formFields value: ${(data[0] as Map)['formFields']}',
            );
          }
        } else {
          print('⚠️ [SERVICES] WARNING: Empty services array returned');
        }

        _services = data.map((json) {
          try {
            return ServiceModel.fromJson(json);
          } catch (e, stackTrace) {
            print('❌ [SERVICES] Error parsing service: $json');
            print('❌ [SERVICES] Parsing error: $e');
            print('❌ [SERVICES] Stack: $stackTrace');
            rethrow;
          }
        }).toList();

        _state = LoadingState.success;
        _errorMessage = null;
        print('✅ [SERVICES] Successfully loaded ${_services.length} services');
      } else {
        _state = LoadingState.error;
        _errorMessage = 'Failed to load services: ${response.statusCode}';
        print('❌ [SERVICES] Error status: ${response.statusCode}');
        print('❌ [SERVICES] Error response: ${response.data}');
        print('❌ [SERVICES] Response headers: ${response.headers}');
      }
    } catch (e, stackTrace) {
      _state = LoadingState.error;
      _errorMessage = 'Network error: ${e.toString()}';
      print('❌ [SERVICES] Network error: $e');
      print('❌ [SERVICES] Stack trace: $stackTrace');
    }

    notifyListeners();
  }

  /// Get services by category ID
  List<ServiceModel> getServicesByCategory(String categoryId) {
    return _services
        .where((service) => service.categoryId == categoryId)
        .toList();
  }

  /// Get overflow services (services that exceed maxServicesPerCategory)
  /// These will be displayed in the "Other Services" section
  List<ServiceModel> getOtherServices() {
    final Map<String?, List<ServiceModel>> servicesByCategory = {};

    // Group services by category
    for (var service in _services) {
      if (!servicesByCategory.containsKey(service.categoryId)) {
        servicesByCategory[service.categoryId] = [];
      }
      servicesByCategory[service.categoryId]!.add(service);
    }

    // Collect overflow services
    List<ServiceModel> overflowServices = [];
    servicesByCategory.forEach((categoryId, services) {
      if (services.length > maxServicesPerCategory) {
        overflowServices.addAll(services.skip(maxServicesPerCategory));
      }
    });

    return overflowServices;
  }

  /// Get main services (up to maxServicesPerCategory per category)
  List<ServiceModel> getMainServicesByCategory(String categoryId) {
    final categoryServices = getServicesByCategory(categoryId);
    return categoryServices.take(maxServicesPerCategory).toList();
  }

  /// Get service by ID
  ServiceModel? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear all data
  void clear() {
    _services = [];
    _state = LoadingState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
