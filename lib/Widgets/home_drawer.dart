import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/user_provider.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.roseColor,
                  AppColors.roseColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Text(
                    userProvider.fullName.isNotEmpty
                        ? userProvider.fullName[0].toUpperCase()
                        : 'U',
                    style: GoogleFonts.dmSans(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.roseColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // User Name
                Text(
                  userProvider.fullName,
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // User Email
                if (userProvider.user.email != null)
                  Text(
                    userProvider.user.email!,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  icon: Icons.home_outlined,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: () {
                    // TODO: Navigate to profile
                    Navigator.pop(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'My Orders',
                  onTap: () {
                    // TODO: Navigate to orders
                    Navigator.pop(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.favorite_outline,
                  title: 'Favorites',
                  onTap: () {
                    // TODO: Navigate to favorites
                    Navigator.pop(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    // TODO: Navigate to settings
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    // TODO: Navigate to help
                    Navigator.pop(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    // TODO: Navigate to about
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Logout',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                // TODO: Implement logout
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
