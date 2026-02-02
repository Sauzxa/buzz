import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double fontSize;
  final bool isLoading;
  final Color? backgroundColor;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.fontSize = 18,
    this.isLoading = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Disable while loading
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.roseColor,
          disabledBackgroundColor: (backgroundColor ?? AppColors.roseColor)
              .withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class WhiteButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double fontSize;

  const WhiteButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.fontSize = 18,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).cardColor,
          foregroundColor: AppColors.roseColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.dmSans(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
