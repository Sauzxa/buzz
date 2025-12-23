import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data';
import '../models/category_model.dart';
import '../utils/image_decoder.dart';

class CategoryCard extends StatefulWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const CategoryCard({super.key, required this.category, this.onTap});

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  late Future<Uint8List?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = ImageDecoder.decodeBase64Image(
      widget.category.categoryImage,
      cacheKey: widget.category.id,
    );
  }

  @override
  void didUpdateWidget(covariant CategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.categoryImage != widget.category.categoryImage) {
      _imageFuture = ImageDecoder.decodeBase64Image(
        widget.category.categoryImage,
        cacheKey: widget
            .category
            .id, // Invalidate/update cache logic might be needed if image changes for same ID, but assuming ID maps to content usually.
        // Actually if image string changes, cache might need update.
        // My simple cache logic doesn't overwrite if key exists for a *new* hash,
        // but here we are just putting the same ID.
        // If content changes, we should probably update cache.
        // My ImageDecoder implementation overwrites: `_imageCache[cacheKey] = decoded;`
        // so it should be fine if we re-decode and cache.
      );
    }
  }

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
    final categoryColor = _parseColor(widget.category.categoryColor);

    return GestureDetector(
      onTap: widget.onTap,
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
            FutureBuilder<Uint8List?>(
              future: _imageFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data != null) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: categoryColor);
                    },
                  );
                }
                return Container(color: categoryColor);
              },
            ),

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
                  widget.category.categoryName.toUpperCase(),
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
