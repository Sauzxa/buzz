import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color? selectedItemColor;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.selectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCard.withOpacity(0.9)
                  : Colors.white.withOpacity(0.7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? AppColors.darkBorder.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined),
                _buildNavItem(1, Icons.search, Icons.search),
                _buildNavItem(
                  2,
                  Icons.business_center_rounded,
                  Icons.business_center_outlined,
                ),
                _buildNavItem(3, Icons.person_rounded, Icons.person_outline),
                _buildNavItem(4, Icons.chat_rounded, Icons.chat_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    final bool isSelected = currentIndex == index;
    final activeColor = selectedItemColor ?? AppColors.roseColor;

    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return GestureDetector(
          onTap: () => onTap(index),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: isSelected
                ? BoxDecoration(
                    color: activeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  )
                : BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
            child: Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected
                  ? activeColor
                  : isDark
                  ? AppColors.darkTextSecondary
                  : Colors.grey[600],
              size: 22,
            ),
          ),
        );
      },
    );
  }
}
