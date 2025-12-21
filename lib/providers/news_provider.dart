import 'package:flutter/foundation.dart';
import '../models/news_model.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

enum LoadingState { idle, loading, success, error }

class NewsProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

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
  Future<void> fetchNews() async {
    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

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
      } else {
        _state = LoadingState.error;
        _errorMessage = 'Failed to load news: ${response.statusCode}';
      }
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Network error: ${e.toString()}';
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
    notifyListeners();
  }
}
