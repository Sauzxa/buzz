import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onb3.dart';
import '../theme/colors.dart';
import '../Widgets/button.dart';

class onb2 extends StatelessWidget {
  const onb2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Skip button
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: TextButton(
                            onPressed: () {
                              // Navigate to next page or skip onboarding
                            },
                            child: Text(
                              'Skip',
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Upper section with phone mockup and decorative elements
                      SizedBox(
                        height: screenHeight * 0.45,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                            ),
                            child: Image.asset(
                              'assets/others/onb2.png',
                              fit: BoxFit.contain,
                              height: screenHeight * 0.4,
                            ),
                          ),
                        ),
                      ),

                      // Lower section with text and button
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06,
                              vertical: screenHeight * 0.025,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(height: screenHeight * 0.02),
                                    // Main heading
                                    Text(
                                      'Everything through\nthe app',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.dmSans(
                                        color: AppColors.roseColor,
                                        fontSize: screenWidth * 0.075,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.015),

                                    // Subtitle
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.02,
                                      ),
                                      child: Text(
                                        'You live far ? need a service ? No worries. Order various services from the comfort of your sweet home.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.dmSans(
                                          color: Colors.grey[600],
                                          fontSize: screenWidth * 0.035,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.02),

                                    // Pagination dots
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: screenHeight * 0.02,
                                  ),
                                  child: PrimaryButton(
                                    text: 'Next',
                                    fontSize: screenWidth * 0.045,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const onb3(),
                                        ),
                                      );
                                    },
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDot({required bool active}) {
    return Container(
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.roseColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
