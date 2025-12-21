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
      final response = await _apiClient.get(ApiEndpoints.getAllServices);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data as List<dynamic>;
        _services = data.map((json) => ServiceModel.fromJson(json)).toList();
        _state = LoadingState.success;
        _errorMessage = null;
      } else {
        _state = LoadingState.error;
        _errorMessage = 'Failed to load services: ${response.statusCode}';
      }
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Network error: ${e.toString()}';
      print('Error fetching services: $e');
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
