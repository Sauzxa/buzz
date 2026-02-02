import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/theme_provider.dart';

import '../utils/fade_route.dart';
import '../pages/settings/general_settings.dart';
import '../pages/services_pages/saved_services.dart';
import '../auth/SignIn.dart';
import '../pages/settings/user_settings_page.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  bool _isLoggingOut = false; // Local loading state for entire logout flow

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return; // Prevent multiple taps

    // Start local loading state
    setState(() {
      _isLoggingOut = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();
      final notificationProvider = context.read<NotificationProvider>();

      // Logout from backend
      await authProvider.logout();

      // Clear local user data
      userProvider.clearUser();

      // Clear notifications
      notificationProvider.clearNotifications();

      if (!mounted) return;

      // Add a brief delay to show the loading state completed
      // This gives better visual feedback that the logout was successful
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Navigate to SignIn page with enhanced fade+scale transition
      // Loading state will remain visible during the animation
      Navigator.of(context).pushAndRemoveUntil(
        FadeRoute(page: const SignInPage()),
        (route) => false,
      );

      // Note: We don't set _isLoggingOut to false here because the page
      // is being replaced. The loading spinner will fade out with the drawer.
    } catch (e) {
      // Handle any unexpected errors
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;

    return Drawer(
      child: Container(
        color: isDarkMode ? AppColors.darkBackground : AppColors.roseColor,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Stack(
                children: [
                  // Theme Toggle Icon - Top Right
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ),
                  // User info column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Avatar
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: isDarkMode
                            ? AppColors.darkCard
                            : Colors.white,
                        child: ClipOval(
                          child:
                              userProvider.user.profilePicture != null &&
                                  userProvider.user.profilePicture!.isNotEmpty
                              ? Image.network(
                                  userProvider.user.profilePicture!,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      userProvider.fullName.isNotEmpty
                                          ? userProvider.fullName[0]
                                                .toUpperCase()
                                          : 'U',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.roseColor,
                                      ),
                                    );
                                  },
                                )
                              : Text(
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
                      ),
                      const SizedBox(height: 16),
                      // User Name
                      Text(
                        userProvider.fullName.isNotEmpty
                            ? userProvider.fullName
                            : 'User Name',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // User Phone
                      Text(
                        userProvider.fullPhoneNumber.isNotEmpty
                            ? userProvider.fullPhoneNumber
                            : '+213 777 58 59 66',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'My Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.call_outlined,
                    title: 'Services',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/services-buzz');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.bookmark_border,
                    title: 'Saved Services',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedServicesPage(),
                        ),
                      );
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Divider(color: Colors.white24, height: 1),
                  ),

                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GeneralSettingsPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.person_add_outlined,
                    title: 'Invite Friends',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Buzz Features',
                    onTap: () async {
                      Navigator.pop(context);

                      // Show confirmation dialog
                      final bool? shouldOpen = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: Text(
                              'Open in Browser',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              'This will open www.buzz-apex.com in your browser.',
                              style: GoogleFonts.dmSans(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                child: Text(
                                  'Open',
                                  style: GoogleFonts.dmSans(
                                    color: AppColors.roseColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldOpen == true) {
                        final Uri url = Uri.parse('https://www.buzz-apex.com');
                        try {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          debugPrint('Error launching URL: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open website'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

            // Logout Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: isDarkMode
                      ? Border.all(color: Colors.white12, width: 1)
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: _isLoggingOut ? null : _handleLogout,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: _isLoggingOut
                          ? Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: isDarkMode
                                      ? Colors.white
                                      : AppColors.roseColor,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: isDarkMode
                                      ? Colors.white
                                      : AppColors.roseColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Logout',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : AppColors.roseColor,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
