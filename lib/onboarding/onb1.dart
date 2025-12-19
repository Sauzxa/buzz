import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onb2.dart';
import '../theme/colors.dart';
import '../Widgets/button.dart';
import '../Widgets/page_indicator.dart';

class onb1 extends StatelessWidget {
  const onb1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.1),
                      // Logo
                      Image.asset(
                        'assets/Logos/WhiteLogo.png',
                        height: screenHeight * 0.15,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: screenHeight * 0.025),

                      const Spacer(),

                      // Main Text
                      Text(
                        "First remote services\nprovider in Algeria",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),

                      const Spacer(),

                      // Product of text
                      Text(
                        "Product Of",
                        style: GoogleFonts.dmSans(
                          color: Colors.white70,
                          fontSize: screenWidth * 0.03,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        "apex tech",
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      // Pagination Dots
                      const WhitePageIndicator(currentIndex: 0),

                      SizedBox(height: screenHeight * 0.04),

                      // Next Button
                      WhiteButton(
                        text: "Next",
                        fontSize: screenWidth * 0.045,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const onb2(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * 0.05),
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
}
