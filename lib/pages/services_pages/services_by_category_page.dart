import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/services_provider.dart';
import '../../models/service_model.dart';
import '../../Widgets/service_card.dart';
import '../../Widgets/button.dart';
import '../../Widgets/notification_badge.dart';
import '../../Widgets/notification_popup.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../utils/category_theme.dart';
import '../../routes/route_names.dart';
import '../../pages/settings/profile/edit_profile_settings.dart';
import 'service_choosing_page.dart';

class ServicesByCategoryPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ServicesByCategoryPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<ServicesByCategoryPage> createState() => _ServicesByCategoryPageState();
}

class _ServicesByCategoryPageState extends State<ServicesByCategoryPage> {
  ServiceModel? _selectedService;
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ServicesProvider>();
      if (provider.services.isEmpty) {
        provider.fetchServices();
      }
    });
  }

  void _onServiceSelected(ServiceModel service) {
    setState(() {
      _selectedService = service;
    });
  }

  void _proceedToServiceDetails() {
    if (_selectedService != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceChoosingPage(service: _selectedService!),
        ),
      );
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

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      // Home - pop back to home
      Navigator.pop(context);
    } else if (index == 1) {
      // Search
      Navigator.pushNamed(context, RouteNames.search);
    } else if (index == 2) {
      // Orders
      Navigator.pushNamed(context, RouteNames.orderManagement);
    } else if (index == 3) {
      // Profile
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
    final categoryTheme = CategoryTheme.fromCategoryName(widget.categoryName);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: categoryTheme.color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
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
        centerTitle: true,
        actions: [
          NotificationIconWithBadge(
            onPressed: _showNotificationBottomSheet,
            iconColor: Colors.white,
            iconSize: 28,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ServicesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? 'Failed to load services',
                    style: GoogleFonts.dmSans(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchServices(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final services = provider.services
              .where((s) => s.categoryId == widget.categoryId)
              .toList();

          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No services available',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Category Description Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.categoryName,
                      style: GoogleFonts.abrilFatface(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge!.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your demands with the most qualified designers at around algeries',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Services Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    final isSelected = _selectedService?.id == service.id;

                    return GestureDetector(
                      onTap: () => _onServiceSelected(service),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? categoryTheme.color
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: ServiceCard(
                          service: service,
                          onTap: () => _onServiceSelected(service),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Proceed Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: PrimaryButton(
                    text: 'Proceed',
                    backgroundColor: categoryTheme.color,
                    onPressed: _selectedService != null
                        ? _proceedToServiceDetails
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a service first'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}
