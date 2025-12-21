import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class LoadingFallback extends StatelessWidget {
  final String? message;

  const LoadingFallback({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.roseColor, strokeWidth: 3),
          const SizedBox(height: 16),
          if (message != null)
            Text(
              message!,
              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }
}
