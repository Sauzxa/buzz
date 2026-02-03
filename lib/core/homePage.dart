import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/user_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/services_provider.dart';
import '../providers/news_provider.dart';
import '../providers/saved_services_provider.dart';
import '../models/service_model.dart';
import '../models/discount_model.dart';

import '../Widgets/home_drawer.dart';
import '../Widgets/notification_popup.dart';
import '../Widgets/notification_badge.dart';
import '../Widgets/category_card.dart';
import '../Widgets/service_card.dart';
import '../Widgets/discount_service_card.dart';
import '../Widgets/long_press_service_wrapper.dart';
import '../Widgets/custom_bottom_nav_bar.dart';
import '../Widgets/skeleton_loader.dart';
import '../Widgets/multi_select_category_dropdown.dart';
import '../Widgets/search_scope_toggle.dart';

import '../utils/snackbar_helper.dart';
import '../utils/static_categories.dart';
import '../utils/category_theme.dart';
import '../pages/categories/category_page.dart';
import '../pages/services_pages/service_choosing_page.dart';
import '../pages/settings/profile/edit_profile_settings.dart';
import '../routes/route_names.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String?
  _selectedServiceFilter; // For services section - search by service name

  // Filter functionality
  List<String> _selectedCategories = []; // Empty = show all
  SearchScope _searchScope = SearchScope.allServices;

  // Search functionality
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<ServiceModel> _searchResults = [];
  bool _isSearchFocused = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Defer fetching data until after the first frame is built
    // Don't await - let it fetch in background while UI renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(); // Non-blocking - UI shows immediately with loading indicators
    });

    // Listen to search focus changes
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
        if (!_isSearchFocused) {
          // Clear search when focus is lost
          _searchController.clear();
          _searchResults.clear();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (query.length < 1) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Debounce search for 300ms
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    final servicesProvider = context.read<ServicesProvider>();

    // Determine which services to search based on scope
    List<ServiceModel> searchPool;
    if (_searchScope == SearchScope.allServices) {
      searchPool = servicesProvider.services; // All services
    } else {
      // Only services from selected categories
      searchPool = _selectedCategories.isEmpty
          ? servicesProvider.services
          : servicesProvider.services
                .where(
                  (service) =>
                      _selectedCategories.contains(service.categoryName),
                )
                .toList();
    }

    // Filter services by name or description (case-insensitive)
    final results = searchPool.where((service) {
      final queryLower = query.toLowerCase();
      return service.name.toLowerCase().contains(queryLower) ||
          service.description.toLowerCase().contains(queryLower);
    }).toList();

    // Sort by name and take top 10
    results.sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      _searchResults = results.take(10).toList();
      _isSearching = false;
    });
  }

  void _onServiceSelected(ServiceModel service) {
    // Clear search
    _searchController.clear();
    _searchResults.clear();
    _searchFocusNode.unfocus();

    // Navigate to service page
    final categoryTheme = CategoryTheme.fromCategoryName(service.categoryName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceChoosingPage(
          service: service,
          categoryColor: categoryTheme.color,
        ),
      ),
    );
  }

  // Helper method to parse service colors safely (handles slashes for gradients)
  Color _getServiceColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return AppColors.roseColor.withOpacity(0.2);
    }
    try {
      final firstColor = colorString
          .split('/')
          .first
          .trim()
          .replaceAll('#', '');
      return Color(int.parse('0xFF$firstColor'));
    } catch (e) {
      return AppColors.roseColor.withOpacity(0.2);
    }
  }

  // Helper method to get gradient for service icon background
  LinearGradient? _getServiceGradient(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;

    try {
      final colors = colorString.split('/').map((c) {
        final hex = c.trim().replaceAll('#', '');
        return Color(int.parse('0xFF$hex'));
      }).toList();

      if (colors.isEmpty) return null;
      if (colors.length == 1) {
        return LinearGradient(
          colors: [colors.first, colors.first.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }

      return LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } catch (e) {
      return null;
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      // Search - Navigate to search page
      Navigator.pushNamed(context, RouteNames.search);
    } else if (index == 2) {
      Navigator.pushNamed(context, RouteNames.orderManagement);
    } else if (index == 3) {
      // Profile/Settings button - Navigate to Edit Profile
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditProfileSettings()),
      );
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
    final userProvider = context.read<UserProvider>();
    final savedServicesProvider = context.read<SavedServicesProvider>();

    // Fetch all data in parallel (non-blocking)
    final futures = <Future>[
      categoriesProvider.fetchCategories(),
      servicesProvider.fetchServices(),
      servicesProvider.fetchDiscounts(),
      newsProvider.fetchNews(),
    ];

    if (userProvider.user.id != null) {
      futures.add(
        savedServicesProvider.loadSavedServices(userProvider.user.id!),
      );
      // Refresh user data to ensure it's up-to-date
      futures.add(userProvider.fetchUserById(userProvider.user.id!));
    }

    // Wait for all to complete, but don't block UI
    await Future.wait(futures, eagerError: false);

    // Only show error for critical failures (categories or services)
    if (mounted) {
      if (categoriesProvider.hasError || servicesProvider.hasError) {
        SnackBarHelper.showErrorSnackBar(
          context,
          'Failed to load some data. Pull to refresh.',
        );
      }
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      drawer: const HomeDrawer(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Header section - stays visible and unblurred
              Container(
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
                                    fontSize: 15,
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
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
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
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: TextField(
                                    controller: _searchController,
                                    focusNode: _searchFocusNode,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      hintText: 'Search services...',
                                      hintStyle: GoogleFonts.dmSans(
                                        color: Theme.of(context).hintColor,
                                        fontSize: 14,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: AppColors.roseColor,
                                        size: 22,
                                      ),
                                      suffixIcon:
                                          _searchController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.clear,
                                                color: Colors.grey,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(() {
                                                  _searchResults.clear();
                                                });
                                              },
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 15,
                                          ),
                                    ),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
                                    ),
                                    onChanged: _onSearchChanged,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Category Filter Dropdown
                            Consumer<CategoriesProvider>(
                              builder: (context, categoriesProvider, child) {
                                final allCategoryNames = categoriesProvider
                                    .categories
                                    .map((cat) => cat.categoryName)
                                    .toList();

                                return MultiSelectCategoryDropdown(
                                  allCategories: allCategoryNames,
                                  selectedCategories: _selectedCategories,
                                  onSelectionChanged: (selected) {
                                    setState(() {
                                      _selectedCategories = selected;
                                    });
                                  },
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            // Search Scope Toggle
                            SearchScopeToggle(
                              currentScope: _searchScope,
                              hasActiveFilter: _selectedCategories.isNotEmpty,
                              onScopeChanged: (scope) {
                                setState(() {
                                  _searchScope = scope;
                                });

                                final message = scope == SearchScope.allServices
                                    ? 'Search Scope: All Services'
                                    : 'Search Scope: Selected Categories Only';

                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      message,
                                      style: GoogleFonts.dmSans(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: AppColors.roseColor,
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Scrollable content below - wrapped in Stack for blur
              Expanded(
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: _fetchData,
                      color: AppColors.roseColor,
                      child: ListView(
                        children: [
                          const SizedBox(height: 24),

                          // Categories Section (no title)
                          _buildCategoriesSection(),

                          const SizedBox(height: 24),

                          // Limited Offers Section (Discount Services)
                          _buildDiscountSection(),

                          const SizedBox(height: 32),

                          // Pubs/Ads Section (News)
                          _buildAdsSection(),

                          const SizedBox(height: 32),

                          // Services Section (horizontal with service name filter)
                          _buildServicesSection(),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),

                    // Blur overlay when search is focused - only covers content below
                    if (_isSearchFocused)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            _searchFocusNode.unfocus();
                          },
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Autocomplete dropdown
          if (_isSearchFocused &&
              (_searchResults.isNotEmpty ||
                  _isSearching ||
                  _searchController.text.length >= 1))
            Positioned(
              top: MediaQuery.of(context).padding.top + 270,
              left: 16,
              right: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.roseColor,
                            ),
                          ),
                        )
                      : _searchResults.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No services found',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Try a different search term',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Theme.of(context).dividerColor,
                          ),
                          itemBuilder: (context, index) {
                            final service = _searchResults[index];
                            return ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: _getServiceGradient(service.color),
                                  color:
                                      _getServiceGradient(service.color) == null
                                      ? _getServiceColor(
                                          service.color,
                                        ).withOpacity(0.2)
                                      : null,
                                ),
                                child:
                                    service.imageUrl != null &&
                                        service.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          service.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.design_services,
                                                  color: AppColors.roseColor,
                                                  size: 24,
                                                );
                                              },
                                        ),
                                      )
                                    : Icon(
                                        Icons.design_services,
                                        color: AppColors.roseColor,
                                        size: 24,
                                      ),
                              ),
                              title: Text(
                                service.name,
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color,
                                ),
                              ),
                              subtitle: service.description.isNotEmpty
                                  ? Text(
                                      service.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    )
                                  : null,
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.roseColor,
                              ),
                              onTap: () => _onServiceSelected(service),
                            );
                          },
                        ),
                ),
              ),
            ),
        ],
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

        // Apply category filter if active
        final filteredCategories = _selectedCategories.isEmpty
            ? categoriesToShow
            : categoriesToShow.where((cat) {
                final categoryName = provider.hasData
                    ? cat.categoryName
                    : (cat as dynamic).name as String;
                return _selectedCategories.contains(categoryName);
              }).toList();

        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filteredCategories.length,
            itemBuilder: (context, index) {
              final category = filteredCategories[index];
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

  Widget _buildDiscountSection() {
    // Get categories for filtering
    final categoriesProvider = context.watch<CategoriesProvider>();
    final categories = categoriesProvider.hasData
        ? categoriesProvider.categories
        : [];

    return Consumer<ServicesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'News & Offers',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge!.color,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: SkeletonLoader(width: 320, height: 120),
                    );
                  },
                ),
              ),
            ],
          );
        }

        // Show nothing if no discounts
        if (provider.discounts.isEmpty) {
          return const SizedBox.shrink();
        }

        // Create a list of discount cards (one card per service name in each discount)
        // Each item contains: discount, serviceName, and categoryName
        final List<Map<String, dynamic>> discountCards = [];

        for (var discount in provider.discounts) {
          for (var serviceName in discount.serviceNames) {
            // Find the service to get its category
            final service = provider.services.firstWhere(
              (s) => s.name == serviceName,
              orElse: () => ServiceModel(
                id: '',
                name: '',
                description: '',
                categoryId: '',
                categoryName: '',
                imageUrl: '',
                formFields: [],
              ),
            );

            discountCards.add({
              'discount': discount,
              'serviceName': serviceName,
              'categoryName': service.categoryName ?? '',
              'service': service,
            });
          }
        }

        // Filter discount cards based on selected category
        final filteredCards = _selectedServiceFilter == null
            ? discountCards
            : discountCards.where((card) {
                return card['categoryName']?.toLowerCase() ==
                    _selectedServiceFilter!.toLowerCase();
              }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and See All button
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
                      color: Theme.of(context).textTheme.titleLarge!.color,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedServiceFilter = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedServiceFilter == null
                            ? AppColors.roseColor
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.roseColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'See All',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _selectedServiceFilter == null
                              ? Colors.white
                              : AppColors.roseColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Filter Chips (by category name)
            if (categories.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected =
                        _selectedServiceFilter == category.categoryName;

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          category.categoryName.replaceAll('-', ' '),
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.roseColor,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.roseColor,
                        backgroundColor: Theme.of(context).cardColor,
                        side: BorderSide(
                          color: AppColors.roseColor.withOpacity(0.3),
                          width: 1,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedServiceFilter = selected
                                ? category.categoryName
                                : null;
                          });
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

            // Discount Cards List
            if (filteredCards.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
                child: Center(
                  child: Text(
                    'No offers available',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height:
                    180, // Matches the new card height set by user (280x120)
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredCards.length,
                  itemBuilder: (context, index) {
                    final card = filteredCards[index];
                    final discount = card['discount'] as DiscountModel;
                    final serviceName = card['serviceName'] as String;
                    final service = card['service'] as ServiceModel;

                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: DiscountServiceCard(
                        discount: discount,
                        serviceName: serviceName,
                        onTap: () {
                          // Navigate to service if we have a valid service
                          if (service.id.isNotEmpty) {
                            final categoryTheme =
                                CategoryTheme.fromCategoryName(
                                  service.categoryName,
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceChoosingPage(
                                  service: service,
                                  categoryColor: categoryTheme.color,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),

        // Services List (Horizontal - no filtration)
        Consumer<ServicesProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return const SkeletonLoader(
                    width: double.infinity,
                    height: double.infinity,
                  );
                },
              );
            }

            // Show nothing if error or no data
            if (!provider.hasData) {
              return const SizedBox.shrink();
            }

            final services = provider.services;

            // Apply category filter if active
            final filteredServices = _selectedCategories.isEmpty
                ? services
                : services
                      .where(
                        (service) =>
                            _selectedCategories.contains(service.categoryName),
                      )
                      .toList();

            if (filteredServices.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
                child: Center(
                  child: Text(
                    _selectedCategories.isNotEmpty
                        ? 'No services matching filters'
                        : 'No services available',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0, // Square cards
              ),
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];
                return LongPressServiceWrapper(
                  service: service,
                  onTap: () {
                    final categoryTheme = CategoryTheme.fromCategoryName(
                      service.categoryName,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceChoosingPage(
                          service: service,
                          categoryColor: categoryTheme.color,
                        ),
                      ),
                    );
                  },
                  child: ServiceCard(
                    service: service,
                    // onTap is handled by wrapper
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdsSection() {
    return Consumer<NewsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.roseColor),
            ),
          );
        }

        if (!provider.hasData || provider.newsList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: provider.newsList.length,
                itemBuilder: (context, index) {
                  final news = provider.newsList[index];

                  return GestureDetector(
                    onTap: () {
                      if (news.newsLink != null && news.newsLink!.isNotEmpty) {
                        SnackBarHelper.showInfoSnackBar(
                          context,
                          'Opening ${news.title}',
                        );
                        // TODO: Open URL in browser
                        // You can use url_launcher package:
                        // launchUrl(Uri.parse(news.newsLink!));
                      }
                    },
                    child: Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child:
                            news.imageUrl != null && news.imageUrl!.isNotEmpty
                            ? Image.network(
                                news.imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.roseColor.withOpacity(0.2),
                                    child: Center(
                                      child: Icon(
                                        Icons.article,
                                        size: 60,
                                        color: AppColors.roseColor,
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.roseColor,
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                              )
                            : Container(
                                color: AppColors.roseColor.withOpacity(0.2),
                                child: Center(
                                  child: Icon(
                                    Icons.article,
                                    size: 60,
                                    color: AppColors.roseColor,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
