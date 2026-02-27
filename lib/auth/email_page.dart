import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../Widgets/button.dart';
import '../providers/auth_provider.dart';
import '../routes/route_names.dart';
import '../l10n/app_localizations.dart';

class EmailPage extends StatefulWidget {
  const EmailPage({super.key});

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  Future<void> _onContinue() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError(
        AppLocalizations.of(context)?.translate('error_enter_email') ??
            'Please enter your email address',
      );
      return;
    }

    if (!_isValidEmail(email)) {
      _showError(
        AppLocalizations.of(context)?.translate('error_invalid_email') ??
            'Please enter a valid email address',
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.sendEmailVerification(email);

      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (success) {
        // Navigate to Verify Email page with email
        Navigator.pushNamed(context, RouteNames.verifyEmail, arguments: email);
      } else {
        _showError(authProvider.error ?? 'Failed to send verification email');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      _showError(
        AppLocalizations.of(context)?.translate('error_unexpected') ??
            'An error occurred. Please try again.',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: [
            const SizedBox(height: 40),

            // Logo
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/Logos/artifexPink.png',
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.ac_unit,
                        size: 40,
                        color: AppColors.roseColor,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Welcome Text
            Text(
              AppLocalizations.of(context)?.translate('email_page_title') ??
                  'Welcome',
              style: GoogleFonts.dmSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              AppLocalizations.of(context)?.translate('email_page_subtitle') ??
                  'Enter your email address to get started',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
            ),

            const SizedBox(height: 40),

            // Email Input Label
            Text(
              AppLocalizations.of(context)?.translate('email_label') ??
                  'Email Address',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Theme.of(context).inputDecorationTheme.labelStyle!.color,
              ),
            ),

            const SizedBox(height: 8),

            // Email Input Field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                hintText:
                    AppLocalizations.of(context)?.translate('email_hint') ??
                    'Enter your email',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).inputDecorationTheme.hintStyle!.color,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Privacy and agreements text
            Center(
              child: Text(
                AppLocalizations.of(context)?.translate('privacy_agreements') ??
                    'Privacy and agreements',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Continue Button
            PrimaryButton(
              text:
                  AppLocalizations.of(context)?.translate('continue_btn') ??
                  'Continue',
              isLoading: _isProcessing,
              onPressed: _isProcessing ? () {} : _onContinue,
            ),

            const SizedBox(height: 20),

            // Already have account
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(
                        context,
                      )?.translate('already_have_account') ??
                      'Already have an account? ',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, RouteNames.signIn);
                  },
                  child: Text(
                    AppLocalizations.of(
                          context,
                        )?.translate('login_link_text') ??
                        'Login',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.roseColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
