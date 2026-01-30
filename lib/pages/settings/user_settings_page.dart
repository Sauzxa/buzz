import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../Widgets/notification_popup.dart';
import '../../theme/colors.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../routes/route_names.dart';
import '../../Widgets/home_drawer.dart';
import '../../providers/user_provider.dart';
import '../../services/fcm_service.dart';
import 'widgets/settings_tile.dart';
import 'widgets/notification_toggle_tile.dart';
import 'contact_page.dart';
import 'profile/edit_profile_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Notification toggle states
  bool _pushNotifications = true;
  bool _promotionalNotifications = true;

  void _showNotificationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationBottomSheet(),
    );
  }

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
      // Already on settings/profile
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, RouteNames.chat);
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
              // Pink Header - Only Top Bar
              SafeArea(
                bottom: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Row(
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
                        onPressed: _showNotificationBottomSheet,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),

              // White Content Body with Profile Section
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
                      padding: const EdgeInsets.only(bottom: 100),
                      children: [
                        // Profile Section (on white background)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 30,
                          ),
                          child: Column(
                            children: [
                              // Profile Picture
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.yellow.shade700,
                                backgroundImage:
                                    (userProvider.user.profilePicture != null &&
                                        userProvider
                                            .user
                                            .profilePicture!
                                            .isNotEmpty)
                                    ? NetworkImage(
                                        userProvider.user.profilePicture!,
                                      )
                                    : null,
                                child:
                                    (userProvider.user.profilePicture == null ||
                                        userProvider
                                            .user
                                            .profilePicture!
                                            .isEmpty)
                                    ? const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),

                              const SizedBox(height: 8),

                              // User Name
                              Text(
                                userProvider.fullName.isNotEmpty
                                    ? userProvider.fullName
                                    : 'User Name',
                                style: GoogleFonts.dmSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),

                              const SizedBox(height: 2),

                              // User Email
                              Text(
                                userProvider.user.email ?? 'user@example.com',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: AppColors.roseColor,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Edit Button
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EditProfileSettings(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppColors.roseColor,
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
                                    color: AppColors.roseColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                          onChanged: (value) async {
                            setState(() {
                              _pushNotifications = value;
                            });

                            // Disable/Enable FCM notifications
                            final fcmService = FcmService();
                            if (value) {
                              // Enable notifications
                              await fcmService.requestPermission();
                              // Re-register token if we have one
                              if (fcmService.fcmToken != null) {
                                await fcmService.registerTokenWithBackend(
                                  fcmService.fcmToken!,
                                );
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Push notifications enabled',
                                      style: GoogleFonts.dmSans(),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              // Disable notifications by removing FCM token from backend
                              if (fcmService.fcmToken != null) {
                                await fcmService.removeTokenFromBackend();
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Push notifications disabled',
                                      style: GoogleFonts.dmSans(),
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            }
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ContactPage(),
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
