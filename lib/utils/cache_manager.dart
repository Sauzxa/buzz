import '../services/cache_service.dart';

/// Centralized cache management utilities
class CacheManager {
  static final CacheService _cache = CacheService();

  /// Cache keys used across the app
  static const String categoriesKey = 'cache_categories';
  static const String servicesKey = 'cache_services';
  static const String discountsKey = 'cache_discounts';
  static const String newsKey = 'cache_news';

  /// Clear all homepage-related cache
  static Future<void> clearHomepageCache() async {
    await Future.wait([
      _cache.remove(categoriesKey),
      _cache.remove(servicesKey),
      _cache.remove(discountsKey),
      _cache.remove(newsKey),
    ]);
    print('🗑️ [CACHE] Cleared all homepage cache');
  }

  /// Clear all app cache
  static Future<void> clearAllCache() async {
    await _cache.clearAll();
    print('🗑️ [CACHE] Cleared all app cache');
  }

  /// Check cache status for debugging
  static Future<Map<String, bool>> getCacheStatus() async {
    return {
      'categories': await _cache.has(categoriesKey),
      'services': await _cache.has(servicesKey),
      'discounts': await _cache.has(discountsKey),
      'news': await _cache.has(newsKey),
    };
  }

  /// Warm up cache by pre-fetching data
  /// Call this on app start or after login
  static Future<void> warmUpCache({
    required Future<void> Function() fetchCategories,
    required Future<void> Function() fetchServices,
    required Future<void> Function() fetchDiscounts,
    required Future<void> Function() fetchNews,
  }) async {
    print('🔥 [CACHE] Warming up cache...');
    await Future.wait([
      fetchCategories(),
      fetchServices(),
      fetchDiscounts(),
      fetchNews(),
    ], eagerError: false);
    print('✅ [CACHE] Cache warmed up');
  }
}
