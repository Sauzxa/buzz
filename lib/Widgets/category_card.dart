import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/category_model.dart';
import '../utils/image_decoder.dart';

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
    final imageBytes = ImageDecoder.decodeBase64Image(category.categoryImage);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: categoryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: categoryColor.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category Image
            if (imageBytes != null)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackIcon(categoryColor);
                    },
                  ),
                ),
              )
            else
              _buildFallbackIcon(categoryColor),

            const SizedBox(height: 12),

            // Category Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                category.categoryName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: categoryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.category_outlined, size: 40, color: color),
    );
  }
}
