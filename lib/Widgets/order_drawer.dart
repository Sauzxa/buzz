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
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Menu',
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const Divider(),
            _buildDrawerItem(
              context,
              title: 'My Orders',
              route: RouteNames.orderManagement,
              isActive: currentRoute == RouteNames.orderManagement,
            ),
            _buildDrawerItem(
              context,
              title: 'History',
              route: RouteNames.orderHistory,
              isActive: currentRoute == RouteNames.orderHistory,
            ),
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
      color: isActive ? Colors.grey.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.greenColor : Colors.black87,
          ),
        ),
        trailing: isActive
            ? const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.greenColor,
              )
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
