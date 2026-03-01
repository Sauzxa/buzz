import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache service for API responses with TTL support
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Cache data with TTL (time-to-live)
  Future<void> set(
    String key,
    dynamic data, {
    Duration ttl = const Duration(minutes: 5),
  }) async {
    await init();
    final expiresAt = DateTime.now().add(ttl).millisecondsSinceEpoch;
    final cacheData = {'data': data, 'expiresAt': expiresAt};
    await _prefs!.setString(key, jsonEncode(cacheData));
  }

  /// Get cached data if not expired
  Future<dynamic> get(String key) async {
    await init();
    final cached = _prefs!.getString(key);
    if (cached == null) return null;

    try {
      final cacheData = jsonDecode(cached);
      final expiresAt = cacheData['expiresAt'] as int;

      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        // Expired - remove it
        await _prefs!.remove(key);
        return null;
      }

      return cacheData['data'];
    } catch (e) {
      print('Error reading cache: $e');
      return null;
    }
  }

  /// Check if cache exists and is valid
  Future<bool> has(String key) async {
    final data = await get(key);
    return data != null;
  }

  /// Clear specific cache
  Future<void> remove(String key) async {
    await init();
    await _prefs!.remove(key);
  }

  /// Clear all cache
  Future<void> clearAll() async {
    await init();
    final keys = _prefs!.getKeys();
    for (final key in keys) {
      if (key.startsWith('cache_')) {
        await _prefs!.remove(key);
      }
    }
  }
}
