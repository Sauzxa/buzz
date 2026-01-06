import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const CategoryCard({super.key, required this.category, this.onTap});

  Color _parseColor(String colorString) {
    try {
      // Remove # if present
      String hexColor = colorString.replaceAll('#', '');

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

  @override
  Widget build(BuildContext context) {
    final categoryColor = _parseColor(category.categoryColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200, // Wider rectangular shape
        height: 120, // Specific height for the card
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: categoryColor, // Fallback color
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge, // Ensure image doesn't bleed out
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            if (category.categoryImage.isNotEmpty)
              Image.network(
                category.categoryImage,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  // Show color background while loading
                  return Container(color: categoryColor);
                },
                errorBuilder: (context, error, stackTrace) {
                  // Show color background on error
                  return Container(color: categoryColor);
                },
              )
            else
              Container(color: categoryColor),

            // Gradient Overlay (optional, to ensure text readability)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Centered Text
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  category.categoryName.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 24, // Larger font size as per design
                    fontWeight: FontWeight.w900, // Extra bold
                    color: Colors.white,
                    height: 1.0,
                    shadows: [
                      const Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4.0,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
