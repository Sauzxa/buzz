import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Widgets/button.dart';
import '../providers/auth_provider.dart';
import '../routes/route_names.dart';
import '../l10n/app_localizations.dart';
import 'dart:async';

class VerifyEmailPage extends StatefulWidget {
  final String email;

  const VerifyEmailPage({super.key, required this.email});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String _getOtpCode() {
    return _otpControllers.map((c) => c.text).join();
  }

  bool _isOtpComplete() {
    return _getOtpCode().length == 5;
  }

  Future<void> _onVerifyCode() async {
    if (!_isOtpComplete()) {
      _showError(
        AppLocalizations.of(context)?.translate('error_enter_code') ??
            'Please enter the 5-digit code',
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final result = await authProvider.verifyEmail(
        email: widget.email,
        otp: _getOtpCode(),
      );

      if (!mounted) return;

      setState(() => _isVerifying = false);

      if (result['success'] == true) {
        // Navigate to Sign Up page with verified email
        Navigator.pushNamed(
          context,
          RouteNames.signUp,
          arguments: widget.email,
        );
      } else {
        // Show error with remaining attempts
        String message = result['message'] ?? 'Invalid code';
        if (result['remainingAttempts'] != null) {
          message += ' (${result['remainingAttempts']} attempts remaining)';
        }
        _showError(message);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isVerifying = false);

      _showError(
        AppLocalizations.of(context)?.translate('error_unexpected') ??
            'An error occurred. Please try again.',
      );
    }
  }

  Future<void> _onResendCode() async {
    if (_resendCooldown > 0) {
      _showError('Please wait $_resendCooldown seconds before resending');
      return;
    }

    setState(() => _isResending = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.resendEmailVerification(widget.email);

      if (!mounted) return;

      setState(() => _isResending = false);

      if (success) {
        _showSuccess(
          AppLocalizations.of(context)?.translate('success_code_resent') ??
              'Code resent to your email',
        );

        // Start cooldown timer
        setState(() => _resendCooldown = 60);
        _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_resendCooldown > 0) {
            setState(() => _resendCooldown--);
          } else {
            timer.cancel();
          }
        });

        // Clear OTP fields
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      } else {
        _showError(authProvider.error ?? 'Failed to resend code');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isResending = false);

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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Title
              Text(
                AppLocalizations.of(context)?.translate('verify_email_title') ??
                    'Verify your email',
                style: GoogleFonts.dmSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge!.color,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                AppLocalizations.of(context)?.translate('verify_email_desc') ??
                    'We have sent a 5-digit code to\n${widget.email}',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall!.color,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  return Container(
                    width: 55,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _focusNodes[index].hasFocus
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).dividerColor,
                        width: _focusNodes[index].hasFocus ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          inputDecorationTheme: const InputDecorationTheme(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            filled: false,
                          ),
                        ),
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          cursorColor: Theme.of(context).primaryColor,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            filled: false,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 4) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                            setState(() {}); // Rebuild to update border
                          },
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 30),

              // Verify Button
              PrimaryButton(
                text:
                    AppLocalizations.of(
                      context,
                    )?.translate('verify_code_btn') ??
                    'Verify Code',
                isLoading: _isVerifying,
                onPressed: _isVerifying ? () {} : _onVerifyCode,
              ),

              const SizedBox(height: 20),

              // Resend Code Button
              TextButton(
                onPressed: _isResending || _resendCooldown > 0
                    ? null
                    : _onResendCode,
                child: _isResending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _resendCooldown > 0
                            ? 'Resend code in $_resendCooldown seconds'
                            : AppLocalizations.of(
                                    context,
                                  )?.translate('resend_code_btn') ??
                                  'Resend Code',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: _resendCooldown > 0
                              ? Colors.grey
                              : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),

              const SizedBox(height: 40),

              // Image
              Image.asset(
                'assets/others/ResetEmail.png',
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(height: 180);
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
