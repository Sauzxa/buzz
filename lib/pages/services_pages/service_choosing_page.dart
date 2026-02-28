import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/service_model.dart';
import '../../Widgets/button.dart';
import '../../theme/colors.dart';
import '../orders/service_order_form_page.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../Widgets/home_drawer.dart';
import '../../Widgets/notification_popup.dart';
import '../../Widgets/notification_badge.dart';
import '../../routes/route_names.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_provider.dart';
import '../../utils/profile_validator.dart';
import '../settings/profile/edit_profile_settings.dart';

class ServiceChoosingPage extends StatelessWidget {
  final ServiceModel service;
  final Color? categoryColor;

  const ServiceChoosingPage({
    Key? key,
    required this.service,
    this.categoryColor,
  }) : super(key: key);

  void _showNotificationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationBottomSheet(),
    );
  }

  Color _getServiceColor() {
    if (categoryColor != null) {
      return categoryColor!;
    }
    if (service.color == null || service.color!.isEmpty) {
      return AppColors.greenColor;
    }
    try {
      final hexCode = service.color!.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (_) {
      return AppColors.greenColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine image to show
    final String? imageToShow = service.mainImage?.isNotEmpty == true
        ? service.mainImage
        : service.imageUrl;

    final themeColor = _getServiceColor();

    return Scaffold(
      backgroundColor: themeColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.grid_view, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: Image.asset(
          'assets/Logos/WhiteLogo.png',
          height: 35,
          errorBuilder: (_, __, ___) => Text(
            AppLocalizations.of(context)?.translate('app_name') ?? 'artifex',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        actions: [
          NotificationIconWithBadge(
            onPressed: () => _showNotificationBottomSheet(context),
            iconColor: Colors.white,
            iconSize: 28,
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: const HomeDrawer(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        selectedItemColor: themeColor,
        onTap: (index) {
          if (index == 0) {
            // Home - Use pushNamedAndRemoveUntil for safer navigation
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.home,
              (route) => false,
            );
          } else if (index == 1) {
            // Search
            Navigator.pushNamed(context, RouteNames.search);
          } else if (index == 2) {
            // Orders
            Navigator.pushNamed(context, RouteNames.orderManagement);
          } else if (index == 3) {
            // Profile/Settings
            Navigator.pushNamed(context, RouteNames.settings);
          } else if (index == 4) {
            // Chat
            Navigator.pushNamed(context, RouteNames.chat);
          }
        },
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Full Screen Background Image
              if (imageToShow != null)
                Image.network(
                  imageToShow,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[900],
                      child: const Icon(
                        Icons.design_services_outlined,
                        size: 80,
                        color: Colors.white24,
                      ),
                    );
                  },
                )
              else
                Container(color: Colors.grey[900]),

              // 2. Dark Overlay for Contrast (Top and Bottom)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: const [0.0, 0.4, 0.8],
                  ),
                ),
              ),

              // 3. Content
              SafeArea(
                child: Column(
                  children: [
                    // Centered Service Name with Colored Background
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 20,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(
                              0.9,
                            ), // Slightly transparent
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Text(
                            service.name.replaceAll('-', ' '),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom Action Button
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: PrimaryButton(
                        text:
                            AppLocalizations.of(
                              context,
                            )?.translate('get_started_btn') ??
                            'Get Started',
                        backgroundColor: themeColor,
                        onPressed: () {
                          // Check if service has form fields
                          if (service.formFields == null ||
                              service.formFields!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                        context,
                                      )?.translate('no_order_form_available') ??
                                      'No order form available for this service yet',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          // Validate user profile completeness
                          final userProvider = context.read<UserProvider>();
                          final validationResult =
                              ProfileValidator.validateUserProfile(
                                userProvider.user,
                              );

                          if (!validationResult['isComplete']) {
                            // Show snackbar with missing fields message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context)?.translate(
                                        'complete_profile_before_order',
                                      ) ??
                                      'Please fill in all required information before creating an order.',
                                ),
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 3),
                              ),
                            );

                            // Navigate to Edit Profile page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileSettings(),
                              ),
                            );
                            return;
                          }

                          // Profile is complete, proceed to order form
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ServiceOrderFormPage(service: service),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10), // Spacing from bottom
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
