import 'package:flutter/material.dart';

class CategoryTheme {
  final Color color;
  final String logoPath;

  const CategoryTheme({required this.color, required this.logoPath});

  static CategoryTheme fromCategoryName(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'audio-visual':
        return const CategoryTheme(
          color: Color(0xFFD5183A),
          logoPath: 'assets/CategorySucces/AudioVisual.png',
        );
      case 'graphic-design':
        return const CategoryTheme(
          color: Color(0xFF4FBF67),
          logoPath: 'assets/CategorySucces/GraphicDesing.png',
        );
      case 'printing':
        return const CategoryTheme(
          color: Color(0xFFAF52DE),
          logoPath: 'assets/CategorySucces/Printing.png',
        );
      default:
        // Default to green if category not found
        return const CategoryTheme(
          color: Color(0xFF4FBF67),
          logoPath: 'assets/CategorySucces/GraphicDesing.png',
        );
    }
  }
}
