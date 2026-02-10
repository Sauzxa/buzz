import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Widgets/button.dart';
import '../services/auth_service.dart';
import '../auth/SignIn.dart';
import '../utils/fade_route.dart';
import '../l10n/app_localizations.dart';

class SetNewPasswordPage extends StatefulWidget {
  final String token;

  const SetNewPasswordPage({Key? key, required this.token}) : super(key: key);

  @override
  State<SetNewPasswordPage> createState() => _SetNewPasswordPageState();
}

class _SetNewPasswordPageState extends State<SetNewPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isProcessing = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showError(
        AppLocalizations.of(context)?.translate('error_fill_all_simple') ??
            'Please fill all fields',
      );
      return;
    }

    if (password.length < 8) {
      _showError(
        AppLocalizations.of(context)?.translate('error_password_length_8') ??
            'Password must be at least 8 characters',
      );
      return;
    }

    if (password != confirmPassword) {
      _showError(
        AppLocalizations.of(context)?.translate('error_passwords_mismatch') ??
            'Passwords do not match',
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await _authService.resetPassword(
        token: widget.token,
        newPassword: password,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate('success_password_reset') ??
                'Password reset successfully! Please login.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(context, FadeRoute(page: const SignInPage()));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)?.translate('set_new_pass_title') ??
                    'Set new password',
                style: GoogleFonts.dmSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge!.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)?.translate('set_new_pass_desc') ??
                    'Create your new secure\npassword.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall!.color,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              _buildPasswordField(
                controller: _passwordController,
                label:
                    AppLocalizations.of(context)?.translate('new_pass_label') ??
                    'New Password',
                obscureText: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 24),

              _buildPasswordField(
                controller: _confirmPasswordController,
                label:
                    AppLocalizations.of(
                      context,
                    )?.translate('confirm_password_label') ??
                    'Confirm Password',
                obscureText: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 30),

              PrimaryButton(
                text:
                    AppLocalizations.of(context)?.translate('set_pass_btn') ??
                    'Set Password',
                isLoading: _isProcessing,
                onPressed: _isProcessing ? () {} : _onSetPassword,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: Theme.of(context).inputDecorationTheme.labelStyle!.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
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
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400],
                ),
                onPressed: onToggle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
