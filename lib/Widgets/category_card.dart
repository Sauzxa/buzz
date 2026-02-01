import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const CategoryCard({super.key, required this.category, this.onTap});

  /// Parse a single color string (e.g., "#07A0c1" or "07A0c1")
  Color _parseColor(String colorString) {
    try {
      // Remove # if present
      String hexColor = colorString.replaceAll('#', '').trim();

      // Add FF for full opacity if not present
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }

      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      // Default to rose color if parsing fails
      return const Color(0xFFEC1968);
    }
  }

  /// Parse gradient colors from backend format: "#color1/#color2/#color3"
  List<Color> _parseGradientColors(String colorString) {
    try {
      // Split by "/" to get individual colors
      List<String> colorParts = colorString.split('/');

      if (colorParts.isEmpty) {
        return [const Color(0xFFEC1968), const Color(0xFFB91450)];
      }

      // Parse each color
      List<Color> colors = colorParts
          .map((colorStr) => _parseColor(colorStr))
          .toList();

      // Ensure we have at least 2 colors for gradient
      if (colors.length == 1) {
        // If only one color, create a darker version for gradient
        Color baseColor = colors[0];
        Color darkerColor = Color.fromARGB(
          baseColor.alpha,
          (baseColor.red * 0.7).toInt(),
          (baseColor.green * 0.7).toInt(),
          (baseColor.blue * 0.7).toInt(),
        );
        return [baseColor, darkerColor];
      }

      return colors;
    } catch (e) {
      // Default gradient if parsing fails
      return [const Color(0xFFEC1968), const Color(0xFFB91450)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _parseGradientColors(category.categoryColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280, // Wider as per Figma design
        height: 120, // Shorter as per Figma design
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon at top-center
            Image.asset(
              'assets/icons/Groups.png',
              width: 45,
              height: 45,
              color: Colors.white,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if icon not found
                return const Icon(Icons.group, color: Colors.white, size: 28);
              },
            ),

            // Category name text
            Padding(
              padding: const EdgeInsets.only(
                left: 14.0,
                right: 14.0,
                bottom: 12.0,
              ),
              child: Text(
                category.categoryName.replaceAll('-', ' ').toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 38, // Larger font size to match Figma
                  fontWeight: FontWeight.w900, // Extra bold
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
