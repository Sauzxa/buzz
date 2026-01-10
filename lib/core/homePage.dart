import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/user_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/services_provider.dart';
import '../providers/news_provider.dart';
import '../Widgets/home_drawer.dart';
import '../Widgets/notification_popup.dart';
import '../Widgets/category_card.dart';
import '../Widgets/service_card.dart';
import '../Widgets/custom_bottom_nav_bar.dart';
import '../Widgets/skeleton_loader.dart';
import '../Widgets/ad_banner.dart';
import '../utils/snackbar_helper.dart';
import '../utils/static_categories.dart';
import '../pages/categories/category_page.dart';
import '../routes/route_names.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Defer fetching data until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 4) {
      Navigator.pushNamed(context, RouteNames.chat);
    } else {
      SnackBarHelper.showInfoSnackBar(
        context,
        'Feature available in the future',
      );
    }
  }

  Future<void> _fetchData() async {
    final categoriesProvider = context.read<CategoriesProvider>();
    final servicesProvider = context.read<ServicesProvider>();
    final newsProvider = context.read<NewsProvider>();

    // Fetch all data
    await Future.wait([
      categoriesProvider.fetchCategories(),
      servicesProvider.fetchServices(),
      newsProvider.fetchNews(),
    ]);

    // Show error if any provider has an error
    if (mounted) {
      if (categoriesProvider.hasError) {
        SnackBarHelper.showErrorSnackBar(
          context,
          categoriesProvider.errorMessage ?? 'Failed to load categories',
        );
      }
      if (servicesProvider.hasError) {
        SnackBarHelper.showErrorSnackBar(
          context,
          servicesProvider.errorMessage ?? 'Failed to load services',
        );
      }
      if (newsProvider.hasError) {
        SnackBarHelper.showErrorSnackBar(
          context,
          newsProvider.errorMessage ?? 'Failed to load news',
        );
      }
    }
  }

  void _showNotificationPopup() {
    showDialog(
      context: context,
      builder: (context) => const NotificationPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      drawer: const HomeDrawer(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: AppColors.roseColor,
        child: CustomScrollView(
          slivers: [
            // Custom Header (replaces AppBar)
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
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: _showNotificationPopup,
                            ),
                          ],
                        ),
                      ),

                      // User Greeting
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<UserProvider>(
                              builder: (context, userProvider, child) {
                                if (userProvider.isLoading) {
                                  return const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  );
                                }
                                return Text(
                                  'Salam ${userProvider.fullName}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'What are you looking for today?',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Search and Filter Row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: Row(
                          children: [
                            // Search Input
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search...',
                                    hintStyle: GoogleFonts.dmSans(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: AppColors.roseColor,
                                      size: 22,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                  ),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  onChanged: (value) {
                                    // TODO: Implement search
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Filter Button
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.tune,
                                  color: AppColors.roseColor,
                                  size: 22,
                                ),
                                onPressed: () {
                                  SnackBarHelper.showInfoSnackBar(
                                    context,
                                    'Filter coming soon!',
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Location Button
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.roseColor,
                                  size: 22,
                                ),
                                onPressed: () {
                                  SnackBarHelper.showInfoSnackBar(
                                    context,
                                    'Location coming soon!',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Rest of the content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Categories Section (no title)
                  _buildCategoriesSection(),

                  const SizedBox(height: 32),

                  // News & Offers Section (horizontal with filter chips)
                  _buildNewsSection(),

                  const SizedBox(height: 24),

                  // Pubs/Ads Section
                  _buildAdsSection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Consumer<CategoriesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 4,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SkeletonLoader(width: 200, height: 120),
                );
              },
            ),
          );
        }

        // Use static categories if error or no API data
        final categoriesToShow = provider.hasData
            ? provider.categories
            : staticCategories;

        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categoriesToShow.length,
            itemBuilder: (context, index) {
              final category = categoriesToShow[index];
              return CategoryCard(
                category: category,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryPage(category: category),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNewsSection() {
    // Mock filter chips
    final filters = [
      'Logo Design',
      'Print',
      'Video Editing',
      'Charte Graphic',
      'Promotion',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'News & Offers',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  SnackBarHelper.showInfoSnackBar(
                    context,
                    'View all services coming soon!',
                  );
                },
                child: Text(
                  'See All',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.roseColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Filter Chips (Visual only for now)
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final isFirst = index == 0;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    filters[index],
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isFirst ? Colors.white : AppColors.roseColor,
                    ),
                  ),
                  selected: isFirst,
                  selectedColor: AppColors.roseColor,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: AppColors.roseColor.withOpacity(0.3),
                    width: 1,
                  ),
                  onSelected: (selected) {
                    // TODO: Implement filter logic
                  },
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Services List (Horizontal)
        Consumer<ServicesProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: SkeletonLoader(width: 200, height: 120),
                    );
                  },
                ),
              );
            }

            // Show nothing if error or no data
            if (!provider.hasData) {
              return const SizedBox.shrink();
            }

            // Limit to a reasonable number if needed, or show all
            // For "News & Offers" section maybe we just show the first few?
            final services = provider.services;

            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return SizedBox(
                    width: 200,
                    child: ServiceCard(
                      service: service,
                      onTap: () {
                        SnackBarHelper.showInfoSnackBar(
                          context,
                          'Service: ${service.name}',
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          AdBanner(
            title: 'apex tech',
            subtitle: 'Powered by innovation',
            backgroundColor: AppColors.roseColor,
            onTap: () {
              SnackBarHelper.showInfoSnackBar(
                context,
                'Learn more about apex tech',
              );
            },
          ),
        ],
      ),
    );
  }
}
