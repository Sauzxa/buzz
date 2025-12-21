import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/service_model.dart';
import '../theme/colors.dart';

class OtherServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const OtherServiceCard({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            // Service Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.roseColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.roseColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: service.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
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

            const SizedBox(height: 8),

            // Service Name
            Text(
              service.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Icon(
      Icons.miscellaneous_services_outlined,
      size: 40,
      color: AppColors.roseColor,
    );
  }
}
