import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../api/api_endpoints.dart';
import '../api/api_client.dart';
import '../models/notification_model.dart';
import 'notification_navigation_service.dart';

// Top-level function for background message handler
// This runs in a separate isolate when app is in background/terminated
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📨 Background message received: ${message.messageId}');
  print('📨 Background notification title: ${message.notification?.title}');
  print('📨 Background notification data: ${message.data}');

  // Store the notification data for handling when app opens
  if (message.data.isNotEmpty) {
    await NotificationNavigationService.storePendingNotificationFromData(
      message.data,
    );
  }
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NotificationNavigationService _navigationService =
      NotificationNavigationService();

  String? _fcmToken;
  bool _isInitialized = false;

  // Callback for notification taps (legacy - kept for compatibility)
  Function(NotificationModel)? onNotificationTap;

  // Callback for new notifications (for updating badge count)
  Function(NotificationModel)? onNewNotification;

  // Callback for new chat messages
  Function(int chatId, int messageId)? onNewChatMessage;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase Cloud Messaging
  Future<void> initialize() async {
    if (_isInitialized) {
      print('🔥 FCM already initialized');
      return;
    }

    try {
      print('\n' + '=' * 50);
      print('🚀 INITIALIZING FCM SERVICE');
      print('=' * 50);

      // Initialize local notifications
      print('📱 Initializing local notifications...');
      await _initializeLocalNotifications();
      print('✅ Local notifications initialized');

      // Request notification permissions
      print('🔐 Requesting notification permissions...');
      final permissionGranted = await requestPermission();
      print('Permission granted: $permissionGranted');

      // Get FCM token
      print('🔑 Attempting to get FCM token...');
      try {
        _fcmToken = await _firebaseMessaging.getToken();
        if (_fcmToken != null) {
          print('✅ FCM Token obtained: $_fcmToken');
        } else {
          print('❌ FCM Token is null!');
          print('⚠️ Possible causes:');
          print('   - google-services.json not properly configured');
          print('   - Firebase project doesn\'t have Cloud Messaging enabled');
          print('   - Google Play Services not available on device');
        }
      } catch (tokenError) {
        print('❌ Error getting FCM token: $tokenError');
        print('Stack trace: ${StackTrace.current}');
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('\n🔄 FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        // Register new token with backend
        registerTokenWithBackend(newToken);
      });

      // Setup message handlers
      _setupMessageHandlers();

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      _isInitialized = true;
      print('=' * 50);
      print('✅ FCM SERVICE INITIALIZATION COMPLETE');
      print('=' * 50 + '\n');
    } catch (e) {
      print('\n' + '=' * 50);
      print('❌ FCM INITIALIZATION ERROR');
      print('=' * 50);
      print('Error: $e');
      print('Stack trace: ${StackTrace.current}');
      print('=' * 50 + '\n');
      rethrow;
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'buzz_notifications', // id
        'Buzz Notifications', // name
        description: 'Notifications for Buzz app',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);
    }
  }

  /// Request notification permissions
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      // Android 13+ requires runtime permission
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        if (!status.isGranted) {
          print('⚠️ Notification permission denied');
          return false;
        }
      }
    }

    // iOS and older Android versions
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final isGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    print(
      isGranted
          ? '✅ Notification permission granted'
          : '⚠️ Notification permission denied',
    );

    return isGranted;
  }

  /// Setup message handlers for different app states
  void _setupMessageHandlers() {
    print('🔧 Setting up FCM message handlers...');

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('\n' + '=' * 50);
      print('📨 FOREGROUND MESSAGE RECEIVED');
      print('=' * 50);
      print('Message ID: ${message.messageId}');
      print('Notification Title: ${message.notification?.title}');
      print('Notification Body: ${message.notification?.body}');
      print('Data Payload: ${message.data}');
      print('Sent Time: ${message.sentTime}');
      print('=' * 50 + '\n');

      // Show local notification
      if (message.notification != null) {
        print('📲 Showing local notification...');
        _showLocalNotification(message);
      } else {
        print('⚠️ No notification payload, only data');
      }

      // Notify listeners about new notification (for badge update)
      if (message.data.isNotEmpty) {
        print('🔔 Notifying listeners about new notification');
        _notifyNewNotification(message.data);

        // Check if it's a chat message notification
        _notifyNewChatMessage(message.data);
      }
    });

    // Background message tap (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('\n' + '=' * 50);
      print('📲 BACKGROUND MESSAGE TAPPED');
      print('=' * 50);
      print('Message ID: ${message.messageId}');
      print('Data: ${message.data}');
      print('=' * 50 + '\n');
      _handleNotificationTap(message.data);
    });

    print('✅ FCM message handlers setup complete');

    // Check if app was opened from terminated state is handled in main.dart
    // to ensure proper navigation after app is ready
  }

  /// Check if app was opened from a notification while terminated
  /// Call this from main.dart after app is ready
  Future<RemoteMessage?> getInitialMessage() async {
    return await _firebaseMessaging.getInitialMessage();
  }

  /// Show local notification when app is in foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Get image from message data if present (base64 encoded)
    final imageBase64 = message.data['notificationImage'] as String?;
    ByteArrayAndroidBitmap? largeIcon;
    BigPictureStyleInformation? bigPictureStyle;

    // Decode base64 image if present
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        final imageBytes = base64Decode(imageBase64);
        largeIcon = ByteArrayAndroidBitmap(imageBytes);
        bigPictureStyle = BigPictureStyleInformation(
          ByteArrayAndroidBitmap(imageBytes),
          largeIcon: largeIcon,
          contentTitle: notification.title,
          summaryText: notification.body,
        );
      } catch (e) {
        print('❌ Error decoding notification image: $e');
      }
    }

    final androidDetails = AndroidNotificationDetails(
      'buzz_notifications',
      'Buzz Notifications',
      channelDescription: 'Notifications for Buzz app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      largeIcon: largeIcon,
      styleInformation: bigPictureStyle,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _handleNotificationTap(data);
      } catch (e) {
        print('❌ Error parsing notification payload: $e');
      }
    }
  }

  /// Handle notification tap and navigate to appropriate screen
  void _handleNotificationTap(Map<String, dynamic> data) {
    try {
      // Extract notification data
      final notificationTypeStr = data['notificationType'] as String?;
      final referenceId = data['referenceId'] != null
          ? int.tryParse(data['referenceId'].toString())
          : null;

      if (notificationTypeStr == null) {
        print('⚠️ No notification type in data');
        return;
      }

      final notificationType = NotificationType.fromString(notificationTypeStr);

      // Create notification model for legacy callback
      final notification = NotificationModel(
        id: data['id'] != null ? int.tryParse(data['id'].toString()) ?? 0 : 0,
        title: data['title'] as String? ?? '',
        message: data['message'] as String? ?? '',
        notificationImage: data['notificationImage'] as String?,
        isRead: false,
        notificationType: notificationType,
        referenceId: referenceId,
        createdAt: DateTime.now(),
      );

      // Call legacy navigation callback if set
      if (onNotificationTap != null) {
        onNotificationTap!(notification);
      }

      // Use navigation service for automatic navigation
      _navigationService.handleNotificationNavigationWithoutContext(
        notificationType,
        referenceId,
      );
    } catch (e) {
      print('❌ Error handling notification tap: $e');
    }
  }

  /// Notify listeners about new notification (for badge updates)
  void _notifyNewNotification(Map<String, dynamic> data) {
    try {
      final notificationTypeStr = data['notificationType'] as String?;
      if (notificationTypeStr == null) return;

      final notificationType = NotificationType.fromString(notificationTypeStr);
      final referenceId = data['referenceId'] != null
          ? int.tryParse(data['referenceId'].toString())
          : null;

      final notification = NotificationModel(
        id: data['id'] != null ? int.tryParse(data['id'].toString()) ?? 0 : 0,
        title: data['title'] as String? ?? '',
        message: data['message'] as String? ?? '',
        notificationImage: data['notificationImage'] as String?,
        isRead: false,
        notificationType: notificationType,
        referenceId: referenceId,
        createdAt: DateTime.now(),
      );

      // Call new notification callback (for badge update)
      if (onNewNotification != null) {
        onNewNotification!(notification);
      }
    } catch (e) {
      print('❌ Error notifying new notification: $e');
    }
  }

  /// Notify chat provider about new chat message
  void _notifyNewChatMessage(Map<String, dynamic> data) {
    try {
      // Check if this is a chat message notification
      final notificationTypeStr = data['notificationType'] as String?;
      if (notificationTypeStr != 'CHAT_MESSAGE') return;

      final chatId = data['chatId'] != null
          ? int.tryParse(data['chatId'].toString())
          : null;

      final messageId = data['messageId'] != null
          ? int.tryParse(data['messageId'].toString())
          : null;

      if (chatId != null && messageId != null && onNewChatMessage != null) {
        print(
          '💬 Notifying chat provider: chatId=$chatId, messageId=$messageId',
        );
        onNewChatMessage!(chatId, messageId);
      }
    } catch (e) {
      print('❌ Error notifying new chat message: $e');
    }
  }

  /// Register FCM token with backend
  Future<void> registerTokenWithBackend(String token) async {
    try {
      final deviceType = Platform.isAndroid ? 'android' : 'ios';
      final deviceName = Platform.isAndroid
          ? 'Android Device'
          : Platform.isIOS
          ? 'iOS Device'
          : 'Unknown Device';

      final body = {
        'token': token,
        'deviceType': deviceType,
        'deviceName': deviceName,
      };

      print('\n' + '=' * 50);
      print('📤 REGISTERING FCM TOKEN WITH BACKEND');
      print('=' * 50);
      print('Token: $token');
      print('Device Type: $deviceType');
      print('Device Name: $deviceName');
      print('Endpoint: ${ApiEndpoints.registerFcmToken}');
      print('=' * 50 + '\n');

      final apiClient = ApiClient();
      final response = await apiClient.post(
        ApiEndpoints.registerFcmToken,
        data: body,
      );

      print('\n' + '=' * 50);
      print('📥 FCM TOKEN REGISTRATION RESPONSE');
      print('=' * 50);
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('=' * 50 + '\n');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ FCM token registered successfully with backend');
      } else {
        print('⚠️ Failed to register token: ${response.statusCode}');
        print('Response body: ${response.data}');
      }
    } catch (e) {
      print('\n' + '=' * 50);
      print('❌ FCM TOKEN REGISTRATION ERROR');
      print('=' * 50);
      print('Error: $e');
      print('Stack trace: ${StackTrace.current}');
      print('=' * 50 + '\n');
      // Don't throw - token registration failure shouldn't crash the app
    }
  }

  /// Remove FCM token from backend (on logout)
  Future<void> removeTokenFromBackend() async {
    try {
      if (_fcmToken == null) {
        print('⚠️ No FCM token to remove');
        return;
      }

      print('📤 Removing FCM token from backend...');

      final apiClient = ApiClient();
      final response = await apiClient.delete(
        ApiEndpoints.removeFcmToken(_fcmToken!),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ FCM token removed successfully');
        _fcmToken = null;
      } else {
        print('⚠️ Failed to remove token: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error removing FCM token: $e');
      // Don't throw - token removal failure shouldn't crash logout
    }
  }

  /// Remove all FCM tokens for current user (logout from all devices)
  Future<void> removeAllTokensFromBackend() async {
    try {
      print('📤 Removing all FCM tokens from backend...');

      final apiClient = ApiClient();
      final response = await apiClient.delete(ApiEndpoints.removeAllFcmTokens);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ All FCM tokens removed successfully');
        _fcmToken = null;
      } else {
        print('⚠️ Failed to remove all tokens: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error removing all FCM tokens: $e');
    }
  }

  /// Delete FCM token locally (Firebase will regenerate on next app start)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      print('✅ FCM token deleted locally');
    } catch (e) {
      print('❌ Error deleting FCM token: $e');
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Get notification badge count (iOS only)
  Future<void> setBadgeCount(int count) async {
    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
}
