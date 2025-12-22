import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../onboarding/onb1.dart';
import '../auth/SignIn.dart';
import '../core/homePage.dart';
import '../theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = context.read<AuthProvider>();

    // Try to auto-login (also checks onboarding status)
    final isAuthenticated = await authProvider.tryAutoLogin();

    // Wait for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Enhanced routing logic
    if (isAuthenticated) {
      // User has valid token → HomePage
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } else if (authProvider.hasSeenOnboarding) {
      // No token but has seen onboarding → SignIn
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const SignInPage()));
    } else {
      // First time user → Onboarding
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const onb1()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/Logos/WhiteLogo.png',
              height: 120,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  'BUZZ',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),

            // Loading text
            Text(
              'Loading...',
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
