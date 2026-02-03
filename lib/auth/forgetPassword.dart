import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Widgets/button.dart';
import '../providers/auth_provider.dart';
import '../utils/fade_route.dart';
import 'resetEmailSent.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onResetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email address');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.forgotPassword(email);

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      if (success) {
        // Navigate to Reset Email Sent page
        if (mounted) {
          Navigator.pushReplacement(
            context,
            FadeRoute(page: const ResetEmailSentPage()),
          );
        }
      } else {
        // Show error from provider
        _showError(authProvider.error ?? 'Failed to send reset email');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      _showError('An error occurred. Please try again.');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Forget Password Title
              Text(
                'Forget Password',
                style: GoogleFonts.dmSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge!.color,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Enter your email address\nto reset password.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall!.color,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Email Address Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email Address',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).inputDecorationTheme.labelStyle!.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Reset Password Button
              PrimaryButton(
                text: 'Reset Password',
                isLoading: _isProcessing,
                onPressed: _isProcessing ? () {} : _onResetPassword,
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
