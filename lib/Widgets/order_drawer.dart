import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes/route_names.dart';
import '../theme/colors.dart';

class OrderDrawer extends StatelessWidget {
  final String currentRoute;

  const OrderDrawer({Key? key, required this.currentRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.roseColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menu',
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Image.asset(
                    'assets/Logos/WhiteLogo.png',
                    height: 60,
                    width: 60,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            _buildDrawerItem(
              context,
              title: 'My Orders',
              route: RouteNames.orderManagement,
              isActive: currentRoute == RouteNames.orderManagement,
            ),
            const SizedBox(height: 12),
            _buildDrawerItem(
              context,
              title: 'History',
              route: RouteNames.orderHistory,
              isActive: currentRoute == RouteNames.orderHistory,
            ),
            const SizedBox(height: 12),
            _buildDrawerItem(
              context,
              title: 'Tracking',
              route: RouteNames.orderTracking,
              isActive: currentRoute == RouteNames.orderTracking,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required String route,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.black : Colors.white,
          ),
        ),
        trailing: isActive
            ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black)
            : null,
        onTap: () {
          Navigator.pop(context); // Always close drawer first
          if (!isActive) {
            Navigator.pushNamed(context, route); // Then navigate
          }
        },
      ),
    );
  }
}
