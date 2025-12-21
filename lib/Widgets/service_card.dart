import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/service_model.dart';
import '../theme/colors.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Service Icon/Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.roseColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: service.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        service.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackIcon();
                        },
                      ),
                    )
                  : _buildFallbackIcon(),
            ),

            const SizedBox(width: 16),

            // Service Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (service.price != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${service.price!.toStringAsFixed(0)} DZD',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.roseColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow Icon
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Icon(
      Icons.design_services_outlined,
      size: 30,
      color: AppColors.roseColor,
    );
  }
}
