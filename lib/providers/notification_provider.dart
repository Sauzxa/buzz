import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/notification_model.dart';
import '../api/api_endpoints.dart';
import '../api/api_client.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<NotificationModel> _unreadNotifications = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;
  String? _cachedUserId;

  final _storage = const FlutterSecureStorage();

  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => _unreadNotifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadNotifications.length;
  bool get hasMore => _hasMore;

  /// Set user ID for notifications
  void setUserId(String userId) {
    _cachedUserId = userId;
  }

  /// Get user ID from cache or storage
  Future<String?> _getUserId() async {
    if (_cachedUserId != null) return _cachedUserId;

    try {
      _cachedUserId = await _storage.read(key: 'user_id');
      return _cachedUserId;
    } catch (e) {
      print('❌ Error reading user ID: $e');
      return null;
    }
  }

  /// Fetch notifications from backend
  Future<void> fetchNotifications({bool? isRead, bool loadMore = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final page = loadMore ? _currentPage + 1 : 0;

      print('📥 Fetching notifications, page: $page');

      final apiClient = ApiClient();
      final response = await apiClient.get(
        ApiEndpoints.getUserNotifications(isRead: isRead, page: page, size: 20),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Parse pagination response
        final content = data['content'] as List;
        final newNotifications = content
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        if (loadMore) {
          _notifications.addAll(newNotifications);
        } else {
          _notifications = newNotifications;
        }

        _currentPage = page;
        _hasMore = !(data['last'] as bool? ?? true);

        // Fetch unread count separately
        await _fetchUnreadNotifications();

        print('✅ Fetched ${newNotifications.length} notifications');
      } else {
        _error = 'Failed to fetch notifications: ${response.statusCode}';
        print('⚠️ $_error');
      }
    } catch (e) {
      _error = 'Error fetching notifications: $e';
      print('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch unread notifications count
  Future<void> _fetchUnreadNotifications() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get(
        ApiEndpoints.getUserNotifications(
          isRead: false,
          page: 0,
          size: 100, // Get all unread
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['content'] as List;
        _unreadNotifications = content
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        print('📊 Unread notifications: ${_unreadNotifications.length}');
      }
    } catch (e) {
      print('❌ Error fetching unread count: $e');
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(int notificationId, String userId) async {
    try {
      print('📝 Marking notification $notificationId as read');

      final apiClient = ApiClient();
      final response = await apiClient.patch(
        ApiEndpoints.markNotificationAsRead(notificationId),
      );

      if (response.statusCode == 200) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }

        // Remove from unread list
        _unreadNotifications.removeWhere((n) => n.id == notificationId);

        notifyListeners();
        print('✅ Notification marked as read');
        return true;
      } else {
        print('⚠️ Failed to mark as read: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      print('🗑️ Deleting notification $notificationId');

      final apiClient = ApiClient();
      final response = await apiClient.delete(
        ApiEndpoints.deleteNotification(notificationId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove from local state
        _notifications.removeWhere((n) => n.id == notificationId);
        _unreadNotifications.removeWhere((n) => n.id == notificationId);

        notifyListeners();
        print('✅ Notification deleted');
        return true;
      } else {
        print('⚠️ Failed to delete notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting notification: $e');
      return false;
    }
  }

  /// Add new notification to the list (called when FCM message arrives)
  void addNewNotification(NotificationModel notification) {
    // Add to the beginning of the list
    _notifications.insert(0, notification);

    // Add to unread list if not read
    if (!notification.isRead) {
      _unreadNotifications.insert(0, notification);
    }

    notifyListeners();
    print('➕ New notification added: ${notification.title}');
  }

  /// Clear all notifications
  void clearNotifications() {
    _notifications.clear();
    _unreadNotifications.clear();
    _currentPage = 0;
    _hasMore = true;
    _error = null;
    notifyListeners();
    print('🧹 Notifications cleared');
  }

  /// Refresh notifications (pull to refresh)
  Future<void> refreshNotifications([String? userId]) async {
    final id = userId ?? await _getUserId();
    if (id == null) {
      print('⚠️ Cannot refresh notifications: No user ID available');
      return;
    }
    _currentPage = 0;
    _hasMore = true;
    await fetchNotifications();
  }

  /// Load more notifications (pagination)
  Future<void> loadMoreNotifications({bool? isRead}) async {
    if (!_hasMore || _isLoading) return;
    await fetchNotifications(isRead: isRead, loadMore: true);
  }

  /// Increment unread count (called when FCM notification arrives in foreground/background)
  void incrementUnreadCount() {
    // Create a temporary notification to bump the count
    // The full notification will be fetched on next refresh
    notifyListeners();
    print('🔔 Unread count incremented');
  }
}
