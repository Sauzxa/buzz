import 'package:flutter/foundation.dart';
import '../models/news_model.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../services/cache_service.dart';

enum LoadingState { idle, loading, success, error }

class NewsProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final CacheService _cache = CacheService();
  static const String _cacheKey = 'cache_news';

  LoadingState _state = LoadingState.idle;
  List<NewsModel> _newsList = [];
  String? _errorMessage;

  // Getters
  LoadingState get state => _state;
  List<NewsModel> get newsList => _newsList;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LoadingState.loading;
  bool get hasError => _state == LoadingState.error;
  bool get hasData => _newsList.isNotEmpty;

  /// Fetch all news from API
  /// Uses stale-while-revalidate: shows cached data immediately, fetches fresh in background
  Future<void> fetchNews({bool forceRefresh = false}) async {
    // Load from cache first (stale-while-revalidate)
    if (!forceRefresh) {
      final cached = await _cache.get(_cacheKey);
      if (cached != null) {
        try {
          final List<dynamic> data = cached as List<dynamic>;
          _newsList = data.map((json) => NewsModel.fromJson(json)).toList();

          // Sort by date (newest first)
          _newsList.sort((a, b) {
            if (a.date == null && b.date == null) return 0;
            if (a.date == null) return 1;
            if (b.date == null) return -1;
            return b.date!.compareTo(a.date!);
          });

          _state = LoadingState.success;
          notifyListeners();
          print('✅ [NEWS] Loaded from cache (${_newsList.length} items)');
        } catch (e) {
          print('❌ [NEWS] Cache parse error: $e');
        }
      }
    }

    // Fetch fresh data in background
    _state = LoadingState.loading;
    _errorMessage = null;
    if (_newsList.isEmpty) {
      notifyListeners(); // Only show loading if no cached data
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.getNews);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data as List<dynamic>;
        _newsList = data.map((json) => NewsModel.fromJson(json)).toList();

        // Sort by date (newest first)
        _newsList.sort((a, b) {
          if (a.date == null && b.date == null) return 0;
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return b.date!.compareTo(a.date!);
        });

        _state = LoadingState.success;
        _errorMessage = null;

        // Cache the response
        await _cache.set(_cacheKey, data, ttl: const Duration(minutes: 15));
        print('✅ [NEWS] Fetched and cached (${_newsList.length} items)');
      } else {
        if (_newsList.isEmpty) {
          _state = LoadingState.error;
          _errorMessage = 'Failed to load news: ${response.statusCode}';
        }
      }
    } catch (e) {
      // Only set error state if we don't have cached data
      if (_newsList.isEmpty) {
        _state = LoadingState.error;
        _errorMessage = 'Network error: ${e.toString()}';
      }
      print('Error fetching news: $e');
    }

    notifyListeners();
  }

  /// Get recent news (limit to n items)
  List<NewsModel> getRecentNews({int limit = 5}) {
    return _newsList.take(limit).toList();
  }

  /// Get news by ID
  NewsModel? getNewsById(String id) {
    try {
      return _newsList.firstWhere((news) => news.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear all data
  void clear() {
    _newsList = [];
    _state = LoadingState.idle;
    _errorMessage = null;
    _cache.remove(_cacheKey);
    notifyListeners();
  }
}
