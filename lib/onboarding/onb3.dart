import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onb4.dart';
import '../theme/colors.dart';
import '../Widgets/button.dart';
import '../Widgets/page_indicator.dart';
import '../auth/mobileNumber.dart';

class onb3 extends StatelessWidget {
  const onb3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.orangeLight, AppColors.orangeDark],
          ),
        ),
        child: SafeArea(
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
                        // Upper section with illustration
                        SizedBox(
                          height: screenHeight * 0.45,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05,
                              ),
                              child: Image.asset(
                                'assets/others/onb3.png',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(height: screenHeight * 0.02),
                                      // Main heading
                                      Text(
                                        'Delivery service',
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
                                          'We provide the best transportation service and organize your furniture properly to prevent any damage.',
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
                                      const PageIndicator(currentIndex: 2),
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
                                            builder: (context) => const onb4(),
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
      ),
    );
  }
}
