import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

enum LoadingState { idle, loading, success, error }

class CategoriesProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

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
  Future<void> fetchCategories() async {
    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.getAllCategories);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data as List<dynamic>;
        _categories = data.map((json) => CategoryModel.fromJson(json)).toList();
        _state = LoadingState.success;
        _errorMessage = null;
      } else {
        _state = LoadingState.error;
        _errorMessage = 'Failed to load categories: ${response.statusCode}';
      }
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Network error: ${e.toString()}';
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
    notifyListeners();
  }
}
