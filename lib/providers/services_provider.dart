import 'package:flutter/foundation.dart';
import '../models/service_model.dart';
import '../models/discount_model.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../services/cache_service.dart';

enum LoadingState { idle, loading, success, error }

class ServicesProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final CacheService _cache = CacheService();
  static const String _cacheKeyServices = 'cache_services';
  static const String _cacheKeyDiscounts = 'cache_discounts';

  LoadingState _state = LoadingState.idle;
  List<ServiceModel> _services = [];
  String? _errorMessage;
  List<String> _discountServiceNames = [];
  List<DiscountModel> _discounts = [];

  // Configuration for "Other Services" section
  static const int maxServicesPerCategory = 4;

  // Getters
  LoadingState get state => _state;
  List<ServiceModel> get services => _services;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LoadingState.loading;
  bool get hasError => _state == LoadingState.error;
  bool get hasData => _services.isNotEmpty;
  List<String> get discountServiceNames => _discountServiceNames;
  List<DiscountModel> get discounts => _discounts;

  /// Fetch all services from API
  /// Uses stale-while-revalidate: shows cached data immediately, fetches fresh in background
  Future<void> fetchServices({bool forceRefresh = false}) async {
    // Load from cache first (stale-while-revalidate)
    if (!forceRefresh) {
      final cached = await _cache.get(_cacheKeyServices);
      if (cached != null) {
        try {
          final List<dynamic> data = cached as List<dynamic>;
          _services = data.map((json) => ServiceModel.fromJson(json)).toList();
          _state = LoadingState.success;
          notifyListeners();
          print('✅ [SERVICES] Loaded from cache (${_services.length} items)');
        } catch (e) {
          print('❌ [SERVICES] Cache parse error: $e');
        }
      }
    }

    // Fetch fresh data in background
    _state = LoadingState.loading;
    _errorMessage = null;
    if (_services.isEmpty) {
      notifyListeners(); // Only show loading if no cached data
    }

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
          if (_services.isEmpty) {
            _state = LoadingState.error;
            _errorMessage = 'Invalid response format from server';
          }
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

        // Cache the response
        await _cache.set(
          _cacheKeyServices,
          data,
          ttl: const Duration(minutes: 10),
        );
        print(
          '✅ [SERVICES] Successfully loaded and cached ${_services.length} services',
        );
      } else {
        if (_services.isEmpty) {
          _state = LoadingState.error;
          _errorMessage = 'Failed to load services: ${response.statusCode}';
        }
        print('❌ [SERVICES] Error status: ${response.statusCode}');
        print('❌ [SERVICES] Error response: ${response.data}');
        print('❌ [SERVICES] Response headers: ${response.headers}');
      }
    } catch (e, stackTrace) {
      // Only set error state if we don't have cached data
      if (_services.isEmpty) {
        _state = LoadingState.error;
        _errorMessage = 'Network error: ${e.toString()}';
      }
      print('❌ [SERVICES] Network error: $e');
      print('❌ [SERVICES] Stack trace: $stackTrace');
    }

    notifyListeners();
  }

  /// Fetch active discounts from API
  /// Uses stale-while-revalidate: shows cached data immediately, fetches fresh in background
  Future<void> fetchDiscounts({bool forceRefresh = false}) async {
    // Load from cache first (stale-while-revalidate)
    if (!forceRefresh) {
      final cached = await _cache.get(_cacheKeyDiscounts);
      if (cached != null) {
        try {
          final List<dynamic> data = cached as List<dynamic>;
          _discounts = data
              .map((json) => DiscountModel.fromJson(json))
              .toList();
          _discountServiceNames = [];
          for (var discount in _discounts) {
            _discountServiceNames.addAll(discount.serviceNames);
          }
          notifyListeners();
          print('✅ [DISCOUNTS] Loaded from cache (${_discounts.length} items)');
        } catch (e) {
          print('❌ [DISCOUNTS] Cache parse error: $e');
        }
      }
    }

    // Fetch fresh data in background
    try {
      print('🔍 [DISCOUNTS] Starting fetch...');

      final response = await _apiClient.get(ApiEndpoints.getActiveDiscounts);

      print('📡 [DISCOUNTS] Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is! List) {
          print('❌ [DISCOUNTS] ERROR: Expected List but got: ${response.data}');
          return;
        }

        final List<dynamic> data = response.data as List<dynamic>;
        print('✅ [DISCOUNTS] Discounts count: ${data.length}');

        // Parse discount models
        _discounts = data.map((json) {
          try {
            return DiscountModel.fromJson(json);
          } catch (e, stackTrace) {
            print('❌ [DISCOUNTS] Error parsing discount: $json');
            print('❌ [DISCOUNTS] Parsing error: $e');
            print('❌ [DISCOUNTS] Stack: $stackTrace');
            rethrow;
          }
        }).toList();

        // Extract service names from discounts for backward compatibility
        _discountServiceNames = [];
        for (var discount in _discounts) {
          _discountServiceNames.addAll(discount.serviceNames);
        }

        // Cache the response
        await _cache.set(
          _cacheKeyDiscounts,
          data,
          ttl: const Duration(minutes: 10),
        );
        print('✅ [DISCOUNTS] Parsed and cached ${_discounts.length} discounts');
        print(
          '✅ [DISCOUNTS] Service names with discounts: $_discountServiceNames',
        );
        notifyListeners();
      } else {
        print('❌ [DISCOUNTS] Error status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ [DISCOUNTS] Network error: $e');
      print('❌ [DISCOUNTS] Stack trace: $stackTrace');
    }
  }

  /// Get services that have discounts
  List<ServiceModel> getDiscountedServices() {
    // Get unique service IDs from discounts
    final discountServiceIds = _discounts.map((d) => d.serviceId).toSet();

    // Filter services by ID first (more accurate), fallback to name matching
    return _services.where((service) {
      return discountServiceIds.contains(service.id) ||
          _discountServiceNames.contains(service.name);
    }).toList();
  }

  /// Get discount for a specific service
  DiscountModel? getDiscountForService(String serviceId) {
    try {
      return _discounts.firstWhere(
        (discount) => discount.serviceId == serviceId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get services by category name
  List<ServiceModel> getServicesByCategoryName(String categoryName) {
    return _services
        .where(
          (service) =>
              service.categoryName?.toLowerCase() == categoryName.toLowerCase(),
        )
        .toList();
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
    _discounts = [];
    _discountServiceNames = [];
    _state = LoadingState.idle;
    _errorMessage = null;
    _cache.remove(_cacheKeyServices);
    _cache.remove(_cacheKeyDiscounts);
    notifyListeners();
  }
}
