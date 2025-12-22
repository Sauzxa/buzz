import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../Widgets/button.dart';
import '../providers/user_provider.dart';
import '../routes/route_names.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({Key? key}) : super(key: key);

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  // Controllers for 4 OTP input fields
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  // Focus nodes for 4 OTP input fields
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  // Timer
  Timer? _timer;
  int _remainingSeconds = 180; // 3 minutes = 180 seconds

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 180;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void _onOTPChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    }

    // Check if all fields are filled
    if (_otpControllers.every((controller) => controller.text.isNotEmpty)) {
      // Auto-submit when all 4 digits are entered
      _onSubmit();
    }
  }

  void _onSubmit() {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 4) {
      _showError('Please enter the complete 4-digit code');
      return;
    }

    // For now, accept any OTP and navigate to next page
    print('OTP entered: $otp');

    // Navigate to SignUp page
    Navigator.pushReplacementNamed(context, RouteNames.signUp);
  }

  void _onResendCode() {
    if (_remainingSeconds > 0) return;

    // Resend code logic here
    print('Resending code');

    // Clear OTP fields
    for (var controller in _otpControllers) {
      controller.clear();
    }

    // Restart timer
    setState(() {
      _startTimer();
    });

    // Focus first field
    _focusNodes[0].requestFocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification code sent!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
    final phoneNumber = context.watch<UserProvider>().fullPhoneNumber;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, RouteNames.mobileNumber);
          },
        ),
        title: Text(
          'OTP Verification',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Info text
              Text(
                'An Authentication code has been sent to',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 8),

              // Phone number in pink
              Text(
                phoneNumber.isNotEmpty
                    ? '+(213) ${phoneNumber}'
                    : '(+213) 999 999 999',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.roseColor,
                ),
              ),

              const SizedBox(height: 40),

              // OTP Input boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return _buildOTPBox(index);
                }),
              ),

              const SizedBox(height: 40),

              // Submit Button
              PrimaryButton(text: 'Submit', onPressed: _onSubmit),

              const SizedBox(height: 20),

              // Resend code section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Code Sent. Resend Code in ',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _remainingSeconds > 0
                          ? AppColors.roseColor
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Resend button
              if (_remainingSeconds == 0)
                TextButton(
                  onPressed: _onResendCode,
                  child: Text(
                    'Resend Code',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.roseColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: _otpControllers[index].text.isNotEmpty
              ? AppColors.roseColor
              : Colors.grey[300]!,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.dmSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          _onOTPChanged(index, value);
        },
        onTap: () {
          // Clear the field when tapped for better UX
          if (_otpControllers[index].text.isNotEmpty) {
            _otpControllers[index].clear();
          }
        },
        onEditingComplete: () {
          if (index < 3 && _otpControllers[index].text.isNotEmpty) {
            _focusNodes[index + 1].requestFocus();
          }
        },
      ),
    );
  }
}
