import 'package:flutter/material.dart';
import '../theme/colors.dart';

class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int pageCount;

  const PageIndicator({
    Key? key,
    required this.currentIndex,
    this.pageCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _buildDot(active: index == currentIndex),
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

class WhitePageIndicator extends StatelessWidget {
  final int currentIndex;
  final int pageCount;

  const WhitePageIndicator({
    Key? key,
    required this.currentIndex,
    this.pageCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _buildDot(active: index == currentIndex),
        ),
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
