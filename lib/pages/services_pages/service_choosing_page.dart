import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: Colors.black,
      extendBody: true,
      extendBodyBehindAppBar: true,
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
            AppLocalizations.of(context)?.translate('app_name') ?? 'BUZZ',
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
            // Use pushNamedAndRemoveUntil for safer navigation
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.home,
              (route) => false,
            );
          } else if (index == 4) {
            Navigator.pushNamed(context, RouteNames.chat);
          }
        },
      ),
      body: Stack(
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
                // Spacer for AppBar since we removed the custom header
                // But SafeArea handles the top notch.
                // Since we have an AppBar with extendBodyBehindAppBar: true,
                // the body goes behind it. SafeArea will push content down below the notch.
                // BUT AppBar is also consuming space.
                // Standard AppBar height is usually handled by Scaffold body unless extending.
                // When extending, we might need a transparent spacer if the visual design requires it,
                // OR just let the content center.
                // The original code had a custom header in column. We removed it.
                // We want the content to be centered vertically mostly?
                // The original code had Expanded -> Center -> Container.
                // So it should be fine.

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
    );
  }
}
