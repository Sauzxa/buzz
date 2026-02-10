import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';
import '../services/notification_navigation_service.dart';
import '../utils/fade_route.dart';
import '../auth/SignIn.dart';
import '../onboarding/onb1.dart';
import 'homePage.dart';
import '../Widgets/bouncing_dots_indicator.dart';
import '../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule check after the first frame to avoid "setState during build" error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = context.read<AuthProvider>();

    // Try to auto-login (also checks onboarding status)
    final isAuthenticated = await authProvider.tryAutoLogin();

    // Add a brief delay to show the loading state completed
    // This gives better visual feedback that navigation is about to happen
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Enhanced routing logic with smooth animations
    if (isAuthenticated) {
      // User has valid token → Populate UserProvider and navigate to HomePage
      if (authProvider.user != null) {
        final userProvider = context.read<UserProvider>();
        userProvider.updateUser(authProvider.user!);

        // Set user ID in notification provider for FCM callbacks
        if (authProvider.user!.id != null) {
          final notificationProvider = context.read<NotificationProvider>();
          notificationProvider.setUserId(authProvider.user!.id!);
        }
      }

      // Navigate with smooth fade transition
      Navigator.of(
        context,
      ).pushAndRemoveUntil(FadeRoute(page: const HomePage()), (route) => false);

      // Check for pending notification navigation (app opened from terminated state)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final navigationService = NotificationNavigationService();
        final navigatorContext =
            NotificationNavigationService.navigatorKey.currentContext;
        if (navigatorContext != null) {
          await navigationService.checkAndHandlePendingNavigation(
            navigatorContext,
          );
        }
      });
    } else if (authProvider.hasSeenOnboarding) {
      // No token but has seen onboarding → SignIn with smooth transition
      Navigator.of(context).pushAndRemoveUntil(
        FadeRoute(page: const SignInPage()),
        (route) => false,
      );
    } else {
      // First time user → Onboarding with smooth transition
      Navigator.of(
        context,
      ).pushAndRemoveUntil(FadeRoute(page: const onb1()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/Logos/WhiteLogo.png',
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  AppLocalizations.of(context)?.translate('app_name') ?? 'Buzz',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Loading indicator
            const BouncingDotsIndicator(color: Colors.white, size: 15.0),
            const SizedBox(height: 16),

            // Loading text
            Text(
              AppLocalizations.of(context)?.translate('loading_text') ??
                  'Loading...',
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
