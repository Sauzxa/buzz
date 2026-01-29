import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'routes/app_routes.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/categories_provider.dart';
import 'providers/services_provider.dart';
import 'providers/news_provider.dart';
import 'providers/saved_services_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/chat_provider.dart';
import 'services/fcm_service.dart';
import 'services/notification_navigation_service.dart';

// Global FCM Service instance for access throughout app
late FcmService globalFcmService;
NotificationProvider? _globalNotificationProvider;
ChatProvider? _globalChatProvider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('No .env file found, using default configuration');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print('🔥 Firebase initialized successfully');

    // Initialize FCM Service
    globalFcmService = FcmService();

    // Check for initial message (app launched from terminated state via notification)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('📬 App launched from terminated state with notification');
      print('📬 Notification data: ${initialMessage.data}');

      // Store the pending navigation for when app is ready
      NotificationNavigationService.storePendingNotificationFromData(
        initialMessage.data,
      );
    }

    await globalFcmService.initialize();
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  runApp(const Buzz());
}

class Buzz extends StatefulWidget {
  const Buzz({super.key});

  @override
  State<Buzz> createState() => _BuzzState();
}

class _BuzzState extends State<Buzz> {
  @override
  void initState() {
    super.initState();
    // Setup FCM callback for new notifications
    _setupFcmCallback();
  }

  void _setupFcmCallback() {
    globalFcmService.onNewNotification = (data) {
      // Update notification provider when new notification arrives
      _globalNotificationProvider?.refreshNotifications();
    };

    globalFcmService.onNewChatMessage = (chatId, messageId) {
      // Update chat provider when new message arrives
      _globalChatProvider?.onNewMessageNotification();
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => SavedServicesProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final provider = NotificationProvider();
            _globalNotificationProvider = provider;
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final provider = ChatProvider();
            _globalChatProvider = provider;
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        navigatorKey: NotificationNavigationService.navigatorKey,
        initialRoute: AppRoutes.initialRoute,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
