import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Widgets/button.dart';
import '../auth/SignIn.dart';
import '../utils/fade_route.dart';

class ResetEmailSentPage extends StatelessWidget {
  const ResetEmailSentPage({Key? key}) : super(key: key);

  void _onProceed(BuildContext context) {
    // Navigate back to SignIn page
    Navigator.pushReplacement(context, FadeRoute(page: const SignInPage()));
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Title
              Text(
                'Reset email sent',
                style: GoogleFonts.dmSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge!.color,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'We have sent all required\ninstructions details to your\nmail.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall!.color,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 60),

              // Image
              Image.asset(
                'assets/others/ResetEmail.png',
                height: 200,
                fit: BoxFit.contain,
              ),

              const Spacer(),

              // Proceed Button
              PrimaryButton(
                text: 'Proceed',
                onPressed: () => _onProceed(context),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
