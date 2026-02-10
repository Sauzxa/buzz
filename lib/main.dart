import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'routes/app_routes.dart';
import 'routes/route_names.dart';
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
import 'providers/theme_provider.dart';
import 'services/fcm_service.dart';
import 'services/notification_navigation_service.dart';
import 'theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

// Global FCM Service instance for access throughout app
late FcmService globalFcmService;
NotificationProvider? _globalNotificationProvider;
ChatProvider? _globalChatProvider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI overlay style for edge-to-edge display
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ),
  );

  // Enable edge-to-edge mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('No .env file found, using default configuration');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');

    // Initialize FCM Service
    globalFcmService = FcmService();

    // Check for initial message (app launched from terminated state via notification)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('App launched from terminated state with notification');
      print('Notification data: ${initialMessage.data}');

      // Store the pending navigation for when app is ready
      NotificationNavigationService.storePendingNotificationFromData(
        initialMessage.data,
      );
    }

    await globalFcmService.initialize();
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const Buzz());
}

class Buzz extends StatefulWidget {
  const Buzz({super.key});

  @override
  State<Buzz> createState() => _BuzzState();
}

class _BuzzState extends State<Buzz> {
  late AppLinks _appLinks;
  StreamSubscription? _deepLinkSub;

  @override
  void initState() {
    super.initState();
    // Setup FCM callback for new notifications
    _setupFcmCallback();
    // Initialize app_links
    _appLinks = AppLinks();
    // Setup deep link handling
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  void _initDeepLinkListener() {
    // Handle deep links when app is already running
    _deepLinkSub = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        print(' Deep link error: $err');
      },
    );

    // Handle initial deep link (when app is launched from terminated state)
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    print('🔗 Deep link received: $uri');

    // Handle password reset deep link: buzzapp://reset-password?token=xxx
    if (uri.scheme == 'buzzapp' && uri.host == 'reset-password') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        print('🔑 Password reset token: $token');

        // Navigate to SetNewPasswordPage with token
        WidgetsBinding.instance.addPostFrameCallback((_) {
          NotificationNavigationService.navigatorKey.currentState?.pushNamed(
            RouteNames.setNewPassword,
            arguments: token,
          );
        });
      } else {
        print('⚠️ No token found in deep link');
      }
    }
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: NotificationNavigationService.navigatorKey,
            initialRoute: AppRoutes.initialRoute,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
          );
        },
      ),
    );
  }
}

// Light theme configuration
ThemeData _buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.roseColor,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    dividerColor: const Color(0xFFE0E0E0),

    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: GoogleFonts.dmSans(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Icon theme
    iconTheme: const IconThemeData(color: Colors.black),

    // Text theme
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.dmSans(color: Colors.black, fontSize: 16),
      bodyMedium: GoogleFonts.dmSans(color: Colors.black, fontSize: 14),
      bodySmall: GoogleFonts.dmSans(
        color: const Color(0xFF888888),
        fontSize: 12,
      ),
      titleLarge: GoogleFonts.dmSans(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: GoogleFonts.dmSans(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.dmSans(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      hintStyle: GoogleFonts.dmSans(color: Colors.black, fontSize: 16),
      labelStyle: GoogleFonts.dmSans(
        color: const Color(0xFF888888),
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.roseColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    ),

    // Card theme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.roseColor,
      unselectedItemColor: Colors.grey,
    ),

    colorScheme: const ColorScheme.light(
      primary: AppColors.roseColor,
      secondary: AppColors.greenColor,
      surface: Colors.white,
      background: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
    ),
  );
}

// Dark theme configuration
ThemeData _buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.roseColorDark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkBorder,

    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      titleTextStyle: GoogleFonts.dmSans(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Icon theme
    iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),

    // Text theme
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.dmSans(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.dmSans(
        color: AppColors.darkTextPrimary,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.dmSans(
        color: AppColors.darkTextSecondary,
        fontSize: 12,
      ),
      titleLarge: GoogleFonts.dmSans(
        color: AppColors.darkTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: GoogleFonts.dmSans(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.dmSans(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputFill,
      hintStyle: GoogleFonts.dmSans(
        color: AppColors.darkTextSecondary,
        fontSize: 16,
      ),
      labelStyle: GoogleFonts.dmSans(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: AppColors.roseColorDark,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    ),

    // Card theme
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkCard,
      selectedItemColor: AppColors.roseColorDark,
      unselectedItemColor: AppColors.darkTextSecondary,
    ),

    colorScheme: const ColorScheme.dark(
      primary: AppColors.roseColorDark,
      secondary: AppColors.greenColorDark,
      surface: AppColors.darkCard,
      background: AppColors.darkBackground,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
      onBackground: AppColors.darkTextPrimary,
      onError: Colors.white,
    ),
  );
}
