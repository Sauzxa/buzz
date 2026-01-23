import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../routes/route_names.dart';
import '../../Widgets/home_drawer.dart';
import '../../providers/user_provider.dart';
import 'widgets/settings_tile.dart';
import 'widgets/notification_toggle_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Notification toggle states
  bool _pushNotifications = true;
  bool _promotionalNotifications = true;

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, RouteNames.chat);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Feature coming soon!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.roseColor,
      drawer: const HomeDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              // Pink Header with Profile Section
              SafeArea(
                bottom: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // Top Bar (Back button, Title, Notification icon)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(
                                Icons.grid_view,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          Text(
                            'Edit Profile',
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              // TODO: Navigate to notifications
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Profile Section
                      Column(
                        children: [
                          // Profile Picture
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.yellow.shade700,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // User Name
                          Text(
                            userProvider.fullName.isNotEmpty
                                ? userProvider.fullName
                                : 'User Name',
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // User Email
                          Text(
                            userProvider.user.email ?? 'user@example.com',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Edit Button
                          OutlinedButton(
                            onPressed: () {
                              // TODO: Navigate to edit_user_account.dart
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Edit profile page coming soon!',
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              'Edit',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 05),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // White Content Body
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
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
                      padding: const EdgeInsets.only(top: 30, bottom: 100),
                      children: [
                        // GENERAL Section
                        _buildSectionHeader('GENERAL'),
                        SettingsTile(
                          icon: Icons.card_giftcard,
                          title: 'Refer to Friends',
                          subtitle: 'Get 10-5 / for referring friends',
                          onTap: () {
                            // TODO: Navigate to referral page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Referral page coming soon!'),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // NOTIFICATIONS Section
                        _buildSectionHeader('NOTIFICATIONS'),
                        NotificationToggleTile(
                          icon: Icons.notifications_outlined,
                          title: 'Push Notifications',
                          subtitle: 'For daily update and others',
                          value: _pushNotifications,
                          onChanged: (value) {
                            setState(() {
                              _pushNotifications = value;
                            });
                          },
                        ),
                        NotificationToggleTile(
                          icon: Icons.notifications_active_outlined,
                          title: 'Promotional Notifications',
                          subtitle: 'New Campaign & Offers',
                          value: _promotionalNotifications,
                          onChanged: (value) {
                            setState(() {
                              _promotionalNotifications = value;
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        // MORE Section
                        _buildSectionHeader('MORE'),
                        SettingsTile(
                          icon: Icons.headset_mic_outlined,
                          title: 'Contact Us',
                          subtitle: 'For more information',
                          onTap: () {
                            // TODO: Navigate to contact us page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contact page coming soon!'),
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

          // Floating Bottom Nav Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              currentIndex: 3,
              onTap: _onBottomNavTapped,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.roseColor,
        ),
      ),
    );
  }
}
