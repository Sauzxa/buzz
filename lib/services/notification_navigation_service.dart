import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../routes/route_names.dart';

/// Service to handle navigation based on notification type
/// Supports deep linking for all 12 notification types
class NotificationNavigationService {
  static final NotificationNavigationService _instance =
      NotificationNavigationService._internal();
  factory NotificationNavigationService() => _instance;
  NotificationNavigationService._internal();

  // Key for storing pending notification in SharedPreferences
  static const String _pendingNotificationKey = 'pending_notification';

  // Global navigator key for navigation without context
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Navigate based on notification type and reference ID
  void handleNotificationNavigation(
    BuildContext context,
    NotificationType type,
    int? referenceId,
  ) {
    print('🔔 Handling navigation for type: $type, referenceId: $referenceId');

    switch (type) {
      // Order-related notifications - Navigate to Order Details
      case NotificationType.ORDER_CREATED:
      case NotificationType.ORDER_PRICED:
      case NotificationType.ORDER_COMPLETED:
      case NotificationType.ORDER_CANCELED:
      case NotificationType.ASSIGNE_DESIGNER:
      case NotificationType.ORDER_AWAITING_FINAL_PAYMENT:
      case NotificationType.DESIGNER_WORK_COMPLETED:
        _navigateToOrderDetails(context, referenceId);
        break;

      // Payment-related notifications - Navigate to Order Details (payment section)
      case NotificationType.PAYMENT_PROOF_UPLOADED:
      case NotificationType.PAYMENT_PROOF_VALIDATED:
      case NotificationType.PAYMENT_PROOF_REJECTED:
      case NotificationType.INVOICE_UPDATED:
        _navigateToOrderDetails(context, referenceId);
        break;

      // Chat notification - Navigate to Chat
      case NotificationType.CHAT:
        _navigateToChat(context, referenceId);
        break;

      // News notification - Navigate to Home (news section)
      case NotificationType.NEWS:
        _navigateToHome(context);
        break;

      // Discount notification - Navigate to Home (show discount)
      case NotificationType.DISCOUNT:
        _navigateToHome(context);
        break;
    }
  }

  /// Navigate using navigator key (when context is not available)
  void handleNotificationNavigationWithoutContext(
    NotificationType type,
    int? referenceId,
  ) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      handleNotificationNavigation(context, type, referenceId);
    } else {
      print('⚠️ Navigator context not available, storing for later');
      _storePendingNavigation(type, referenceId);
    }
  }

  /// Navigate to Order Details page
  void _navigateToOrderDetails(BuildContext context, int? orderId) {
    if (orderId != null) {
      print('📦 Navigating to order details: $orderId');
      Navigator.pushNamed(
        context,
        RouteNames.orderDetails,
        arguments: orderId.toString(), // Pass orderId as string
      );
    } else {
      // If no order ID, go to order management
      print('📦 No order ID, navigating to order management');
      Navigator.pushNamed(context, RouteNames.orderManagement);
    }
  }

  /// Navigate to Chat page
  void _navigateToChat(BuildContext context, int? chatId) {
    print('💬 Navigating to chat');
    Navigator.pushNamed(context, RouteNames.chat);
  }

  /// Navigate to Home page
  void _navigateToHome(BuildContext context) {
    print('🏠 Navigating to home');
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.home,
      (route) => false,
    );
  }

  /// Store pending notification for navigation after app is ready
  Future<void> _storePendingNavigation(
    NotificationType type,
    int? referenceId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'notificationType': type.toString().split('.').last,
        'referenceId': referenceId,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_pendingNotificationKey, jsonEncode(data));
      print('💾 Stored pending notification: $data');
    } catch (e) {
      print('❌ Error storing pending notification: $e');
    }
  }

  /// Store pending notification from raw data (for background handler)
  static Future<void> storePendingNotificationFromData(
    Map<String, dynamic> data,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingData = {
        'notificationType': data['notificationType'],
        'referenceId': data['referenceId'],
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_pendingNotificationKey, jsonEncode(pendingData));
      print('💾 Background: Stored pending notification: $pendingData');
    } catch (e) {
      print('❌ Background: Error storing pending notification: $e');
    }
  }

  /// Check and handle any pending notification navigation
  Future<bool> checkAndHandlePendingNavigation(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingJson = prefs.getString(_pendingNotificationKey);

      if (pendingJson != null) {
        final data = jsonDecode(pendingJson) as Map<String, dynamic>;
        print('📬 Found pending notification: $data');

        // Clear the pending notification
        await prefs.remove(_pendingNotificationKey);

        // Check if notification is not too old (within 24 hours)
        final timestamp = DateTime.parse(data['timestamp'] as String);
        if (DateTime.now().difference(timestamp).inHours < 24) {
          final typeStr = data['notificationType'] as String;
          final referenceId = data['referenceId'] as int?;
          final type = NotificationType.fromString(typeStr);

          // Small delay to ensure navigation is ready
          await Future.delayed(const Duration(milliseconds: 500));

          handleNotificationNavigation(context, type, referenceId);
          return true;
        } else {
          print('⏰ Pending notification too old, ignoring');
        }
      }
    } catch (e) {
      print('❌ Error checking pending notification: $e');
    }
    return false;
  }

  /// Clear any pending notification
  Future<void> clearPendingNavigation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingNotificationKey);
      print('🧹 Cleared pending notification');
    } catch (e) {
      print('❌ Error clearing pending notification: $e');
    }
  }

  /// Parse notification data from RemoteMessage
  static Map<String, dynamic> parseNotificationData(Map<String, dynamic> data) {
    return {
      'id': _parseInt(data['id']),
      'title': data['title'] as String? ?? '',
      'message': data['message'] as String? ?? data['body'] as String? ?? '',
      'notificationImage': data['notificationImage'] as String?,
      'notificationType': data['notificationType'] as String? ?? 'NEWS',
      'referenceId': _parseInt(data['referenceId']),
      'isRead': data['isRead'] == 'true',
      'createdAt':
          data['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
