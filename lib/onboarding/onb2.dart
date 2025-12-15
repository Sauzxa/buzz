import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onb3.dart';
import '../theme/colors.dart';
import '../Widgets/button.dart';
import '../Widgets/page_indicator.dart';
import '../auth/mobileNumber.dart';

class onb2 extends StatelessWidget {
  const onb2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueColor,
      appBar: AppBar(
        backgroundColor: AppColors.lightBlueColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MobileNumberPage(),
                  ),
                );
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
        ],
      ),
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
                                    const PageIndicator(currentIndex: 1),
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
}
