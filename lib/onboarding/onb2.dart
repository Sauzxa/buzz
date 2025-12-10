import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class onb2 extends StatelessWidget {
  const onb2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define colors
    const Color lightBlueColor = Color(0xFF8DC9E8);
    const Color roseColor = Color(0xFFEC1968);

    return Scaffold(
      backgroundColor: lightBlueColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () {
                    // Navigate to next page or skip onboarding
                  },
                  child: Text(
                    'Skip',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Upper section with phone mockup and decorative elements
            Expanded(
              flex: 5,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Image.asset(
                    'lib/assets/others/phoneandeverything.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Lower section with text and button
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          // Main heading
                          Text(
                            'Everything through\nthe app',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              color: roseColor,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Subtitle
                          Text(
                            'You live far ? need a service ? No worries.\nOrder various services from the comfort\nof your sweet home.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              color: Colors.grey[600],
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Pagination dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDot(active: false),
                              const SizedBox(width: 8),
                              _buildDot(active: true),
                              const SizedBox(width: 8),
                              _buildDot(active: false),
                            ],
                          ),
                        ],
                      ),

                      // Next button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to next onboarding page
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: roseColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Next',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({required bool active}) {
    const Color roseColor = Color(0xFFEC1968);
    return Container(
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? roseColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
