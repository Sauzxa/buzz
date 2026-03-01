import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../services/cache_service.dart';

enum LoadingState { idle, loading, success, error }

class CategoriesProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final CacheService _cache = CacheService();
  static const String _cacheKey = 'cache_categories';

  LoadingState _state = LoadingState.idle;
  List<CategoryModel> _categories = [];
  String? _errorMessage;

  // Getters
  LoadingState get state => _state;
  List<CategoryModel> get categories => _categories;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LoadingState.loading;
  bool get hasError => _state == LoadingState.error;
  bool get hasData => _categories.isNotEmpty;

  /// Fetch all categories from API
  /// Uses stale-while-revalidate: shows cached data immediately, fetches fresh in background
  Future<void> fetchCategories({bool forceRefresh = false}) async {
    // Load from cache first (stale-while-revalidate)
    if (!forceRefresh) {
      final cached = await _cache.get(_cacheKey);
      if (cached != null) {
        try {
          final List<dynamic> data = cached as List<dynamic>;
          _categories = data
              .map((json) => CategoryModel.fromJson(json))
              .toList();
          _state = LoadingState.success;
          notifyListeners();
          print(
            '✅ [CATEGORIES] Loaded from cache (${_categories.length} items)',
          );
        } catch (e) {
          print('❌ [CATEGORIES] Cache parse error: $e');
        }
      }
    }

    // Fetch fresh data in background
    _state = LoadingState.loading;
    _errorMessage = null;
    if (_categories.isEmpty) {
      notifyListeners(); // Only show loading if no cached data
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.getAllCategories);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data as List<dynamic>;
        _categories = data.map((json) => CategoryModel.fromJson(json)).toList();
        _state = LoadingState.success;
        _errorMessage = null;

        // Cache the response
        await _cache.set(_cacheKey, data, ttl: const Duration(minutes: 10));
        print(
          '✅ [CATEGORIES] Fetched and cached (${_categories.length} items)',
        );
      } else {
        _state = LoadingState.error;
        _errorMessage = 'Failed to load categories: ${response.statusCode}';
      }
    } catch (e) {
      // Only set error state if we don't have cached data
      if (_categories.isEmpty) {
        _state = LoadingState.error;
        _errorMessage = 'Network error: ${e.toString()}';
      }
      print('Error fetching categories: $e');
    }

    notifyListeners();
  }

  /// Get category by ID
  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear all data
  void clear() {
    _categories = [];
    _state = LoadingState.idle;
    _errorMessage = null;
    _cache.remove(_cacheKey);
    notifyListeners();
  }
}
