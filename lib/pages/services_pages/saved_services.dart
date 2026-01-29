import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../providers/saved_services_provider.dart';
import '../../providers/user_provider.dart';
import '../../Widgets/service_card.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../routes/route_names.dart';
import 'service_choosing_page.dart';

class SavedServicesPage extends StatefulWidget {
  const SavedServicesPage({super.key});

  @override
  State<SavedServicesPage> createState() => _SavedServicesPageState();
}

class _SavedServicesPageState extends State<SavedServicesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final savedServicesProvider = context.read<SavedServicesProvider>();
      if (userProvider.user.id != null) {
        savedServicesProvider.loadSavedServices(userProvider.user.id!);
      } else {
        // Optionally show empty or prompt to login
      }
    });
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else if (index == 3) {
      // Navigate to Settings
      Navigator.pushReplacementNamed(context, RouteNames.settings);
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
    return Scaffold(
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
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_border,
                          color: AppColors.roseColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Saved',
                        style: GoogleFonts.dmSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Consumer<SavedServicesProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.savedServices.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bookmark_border,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No saved services yet',
                                style: GoogleFonts.dmSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: provider.savedServices.length,
                        itemBuilder: (context, index) {
                          final service = provider.savedServices[index];
                          return ServiceCard(
                            service: service,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ServiceChoosingPage(service: service),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
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
              currentIndex:
                  0, // Highlight Home as requested (user is still "in home")
              onTap: _onBottomNavTapped,
            ),
          ),
        ],
      ),
    );
  }
}
