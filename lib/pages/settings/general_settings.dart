import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/colors.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../routes/route_names.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

import 'user_settings_page.dart';

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
  void _onBottomNavTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else if (index == 1) {
      // Search - Navigate to home
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else if (index == 2) {
      // Order Management
      Navigator.pushNamed(context, RouteNames.orderManagement);
    } else if (index == 3) {
      // Already on settings, do nothing
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, RouteNames.chat);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.roseColor,
      body: Stack(
        children: [
          Column(
            children: [
              // Pink Header
              SafeArea(
                bottom: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          RouteNames.home,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.settings, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Settings',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // White Content Body
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 100, top: 20),
                      children: [
                        // GENERAL Section
                        _buildSectionHeader('GENERAL'),
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Account',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsPage(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              RouteNames.notificationsBuzz,
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.local_offer_outlined,
                          title: 'Coupons',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Coupons page coming soon!'),
                              ),
                            );
                          },
                        ),

                        _buildMenuItem(
                          icon: Icons.language,
                          title: 'Language',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Language settings coming soon!'),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // FEEDBACK Section
                        _buildSectionHeader('FEEDBACK'),
                        _buildMenuItem(
                          icon: Icons.bug_report_outlined,
                          title: 'Report a bug',
                          onTap: () {
                            Navigator.pushNamed(context, RouteNames.bugReport);
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.feedback_outlined,
                          title: 'Send Feedback',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Feedback page coming soon!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating Bottom Nav Bar - Hide when keyboard is visible
          if (MediaQuery.of(context).viewInsets.bottom == 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNavBar(
                currentIndex: 0,
                onTap: _onBottomNavTapped,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodySmall!.color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).iconTheme.color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.titleLarge!.color,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).textTheme.bodySmall!.color,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
