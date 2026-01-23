import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../routes/route_names.dart';
import '../utils/fade_route.dart';
import '../pages/settings/general_settings.dart';
import '../auth/SignIn.dart';

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

      // Logout from backend
      await authProvider.logout();

      // Clear local user data
      userProvider.clearUser();

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

    return Drawer(
      child: Container(
        color: AppColors.roseColor,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
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
                                      ? userProvider.fullName[0].toUpperCase()
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
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.call_outlined,
                    title: 'Services',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.bookmark_border,
                    title: 'Saved Services',
                    onTap: () {
                      Navigator.pop(context);
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
                    onTap: () {
                      Navigator.pop(context);
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
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
                          ? const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.roseColor,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                const Icon(
                                  Icons.logout,
                                  color: AppColors.roseColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Logout',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.roseColor,
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
