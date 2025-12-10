import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onb2.dart';

class onb1 extends StatelessWidget {
  const onb1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define the rose color
    const Color roseColor = Color(0xFFEC1968);

    return Scaffold(
      backgroundColor: roseColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),
                      // Logo
                      Image.asset(
                        'lib/assets/Logos/WhiteLogo.png',
                        height: 120, // Adjust height as needed
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),

                      // App Name (Optional, if part of logo or separate)
                      // Based on image, "BUZZ" is part of logo or next to it.
                      // Assuming the logo image contains "BUZZ" text or just the icon.
                      // If just icon, I might need to add text.
                      // The user said "you will find the logo", usually implies the full logo.
                      // I'll assume the image has everything.
                      const Spacer(flex: 2),

                      // Main Text
                      Text(
                        "First remote services\nprovider in Algeria",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Product of text
                      Text(
                        "Product Of",
                        style: GoogleFonts.dmSans(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "apex tech",
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Pagination Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDot(active: true),
                          const SizedBox(width: 8),
                          _buildDot(active: false),
                          const SizedBox(width: 8),
                          _buildDot(active: false),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Next Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const onb2(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: roseColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Next",
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDot({required bool active}) {
    return Container(
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
