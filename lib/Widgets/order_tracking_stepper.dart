import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class OrderTrackingStepper extends StatelessWidget {
  final int currentStep; // 0 to 3

  const OrderTrackingStepper({Key? key, required this.currentStep})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildStepCircle(0),
            _buildLine(0),
            _buildStepCircle(1),
            _buildLine(1),
            _buildStepCircle(2),
            _buildLine(2),
            _buildStepCircle(3),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel('Demande'),
            _buildLabel('Recieved'),
            _buildLabel('Traitement'),
            _buildLabel('Ready'),
          ],
        ),
      ],
    );
  }

  Widget _buildStepCircle(int stepIndex) {
    bool isCompleted = currentStep >= stepIndex;
    bool isLast = stepIndex == 3;

    if (isLast && isCompleted) {
      // Last step completed (Checkmark)
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.roseColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 16, color: Colors.white),
      );
    } else if (isCompleted) {
      // Completed step (Colored circle)
      return Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(
          color: AppColors.roseColor,
          shape: BoxShape.circle,
        ),
      );
    } else {
      // Incomplete step (Black circle/dot)
      return Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
      );
    }
  }

  Widget _buildLine(int stepIndex) {
    bool isCompleted = currentStep > stepIndex;
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? AppColors.roseColor : Colors.grey,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return SizedBox(
      width: 60,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
