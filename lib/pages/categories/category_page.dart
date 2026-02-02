import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/category_model.dart';
import '../services_pages/services_by_category_page.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../Widgets/home_drawer.dart';
import '../../Widgets/notification_popup.dart';
import '../../Widgets/notification_badge.dart';
import '../../utils/category_theme.dart';
import '../../routes/route_names.dart';
import '../settings/profile/edit_profile_settings.dart';

class CategoryPage extends StatefulWidget {
  final CategoryModel category;

  const CategoryPage({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // ... existing methods ...
  void _showNotificationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationBottomSheet(),
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      // Home - Go back to home
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 1) {
      // Search
      Navigator.pushNamed(context, RouteNames.search);
    } else if (index == 2) {
      // Orders
      Navigator.pushNamed(context, RouteNames.orderManagement);
    } else if (index == 3) {
      // Profile/Settings
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditProfileSettings()),
      );
    } else if (index == 4) {
      // Chat
      Navigator.pushNamed(context, RouteNames.chat);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryTheme = CategoryTheme.fromCategoryName(
      widget.category.categoryName,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFF1A1A1A),
      drawer: const HomeDrawer(),
      // Add Bottom Navigation Bar to match design
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0, // Default to Home for visual consistency
        onTap: _onBottomNavTapped,
        selectedItemColor: categoryTheme.color,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-screen background image
          if (widget.category.categoryImage.isNotEmpty)
            Image.network(
              widget.category.categoryImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(
                      Icons.category_outlined,
                      size: 100,
                      color: Colors.white24,
                    ),
                  ),
                );
              },
            )
          else
            Container(color: Colors.grey[900]),

          // 2. Dark Gradient Overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3), // Top darkening for header
                  Colors.transparent,
                  Colors.black.withOpacity(0.6), // Bottom darkening for text
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // 3. Content Area
          SafeArea(
            child: Column(
              children: [
                // Header (Menu, Logo, Notification)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menu Button
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

                      // Logo
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

                      // Notification Button
                      NotificationIconWithBadge(
                        onPressed: () => _showNotificationBottomSheet(context),
                        iconColor: Colors.white,
                        iconSize: 28,
                      ),
                    ],
                  ),
                ),

                const Spacer(), // Pushes content to the bottom
                // Bottom Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Wrap content
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align text to start
                    children: [
                      // "Create, Don't hate!" Text
                      Text(
                        // If category has specific styling description, use it, else default
                        widget.category.description.isNotEmpty
                            ? widget.category.description
                            : "Create,\nDon't hate!",
                        style: GoogleFonts.playfairDisplay(
                          // Serif font for elegance
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // "Continue" Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServicesByCategoryPage(
                                  categoryId: widget.category.id,
                                  categoryName: widget.category.categoryName,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF4FBF67,
                            ), // Green color
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            'Continue',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Extra space below button
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
