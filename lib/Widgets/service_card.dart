import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/service_model.dart';
import '../theme/colors.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onLongPress,
  });

  LinearGradient? _getGradient(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;

    try {
      final colors = colorString.split('/').map((c) {
        final hex = c.trim().replaceAll('#', '');
        return Color(int.parse('0xFF$hex'));
      }).toList();

      if (colors.isEmpty) return null;
      if (colors.length == 1) {
        // If only one color, create a gradient with the same color to compatible with LinearGradient
        return LinearGradient(
          colors: [colors.first, colors.first],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }

      return LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          gradient: _getGradient(service.color),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                  ? Image.network(
                      service.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            color: AppColors.greenColor,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: _getGradient(service.color) != null
                              ? Colors.transparent
                              : Colors.grey[200],
                          child: Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: _getGradient(service.color) != null
                          ? Colors.transparent
                          : Colors.grey[200],
                      child: Icon(
                        Icons.design_services_outlined,
                        size: 40,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
            ),

            // Service Color Gradient Overlay (Tint)
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _getGradient(service.color),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            // Text and Logo Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  // Service Name
                  Text(
                    service.name.replaceAll('-', ' ').toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Limited Offer Logo
                  Image.asset(
                    'assets/Logos/LimitedOffre.png',
                    height: 18,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink(); // Hide if missing
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
