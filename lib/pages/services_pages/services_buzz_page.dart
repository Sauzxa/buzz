import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import '../../Widgets/home_drawer.dart';
import '../../Widgets/notification_popup.dart';
import '../../Widgets/notification_badge.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';

class ServicesBuzzPage extends StatefulWidget {
  const ServicesBuzzPage({super.key});

  @override
  State<ServicesBuzzPage> createState() => _ServicesBuzzPageState();
}

class _ServicesBuzzPageState extends State<ServicesBuzzPage> {
  int _selectedIndex = 0;

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      // Home
      Navigator.pop(context);
    } else if (index == 1) {
      // Search
      setState(() {
        _selectedIndex = 1;
      });
    } else if (index == 2) {
      // Orders
      Navigator.pushNamed(context, '/order-management');
    } else if (index == 3) {
      // Profile
      Navigator.pushNamed(context, '/settings');
    } else if (index == 4) {
      // Chat
      Navigator.pushNamed(context, '/chat');
    }
  }

  void _showNotificationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseColor,
      extendBody: true,
      drawer: const HomeDrawer(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
      ),
      body: CustomScrollView(
        slivers: [
          // Custom Header
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.roseColor,
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Menu, Logo, Notification
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
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
                            ),
                          ),
                          Image.asset(
                            'assets/Logos/WhiteLogo.png',
                            height: 35,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                'BUZZ',
                                style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              );
                            },
                          ),
                          NotificationIconWithBadge(
                            onPressed: _showNotificationBottomSheet,
                            iconColor: Colors.white,
                            iconSize: 28,
                          ),
                        ],
                      ),
                    ),

                    // Services Title
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Text(
                          'Services',
                          style: GoogleFonts.dmSans(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Pink section with content
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.roseColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Divider line
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Service items
                  _buildServiceItem('Printing'),
                  const SizedBox(height: 24),
                  _buildServiceItem('Audio Visual'),
                  const SizedBox(height: 24),
                  _buildServiceItem('Design'),
                  const SizedBox(height: 60),

                  // Divider line
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Contact section
                  Center(
                    child: Text(
                      'More contact us on',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Social media links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            'SOCIAL :',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildSocialIcon(Icons.facebook, () {
                                // Facebook link - to be provided
                              }),
                              const SizedBox(width: 12),
                              _buildSocialIcon(Icons.close, () {
                                // Twitter/X link - to be provided
                              }),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildSocialIcon(Icons.camera_alt, () {
                                // Instagram link - to be provided
                              }),
                              const SizedBox(width: 12),
                              _buildSocialIcon(Icons.link, () {
                                // LinkedIn link - to be provided
                              }),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Telephone:',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '+213 777 58 59 66',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '+213 777 58 59 66',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String title) {
    return Center(
      child: Text(
        title,
        style: GoogleFonts.abrilFatface(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.roseColor, size: 20),
      ),
    );
  }
}
