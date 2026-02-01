import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../providers/categories_provider.dart';
import '../../providers/services_provider.dart';
import '../../models/service_model.dart';
import '../../models/category_model.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../pages/categories/category_page.dart';
import '../../pages/services_pages/service_choosing_page.dart';
import '../../pages/settings/profile/edit_profile_settings.dart';
import '../../routes/route_names.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  List<ServiceModel> _serviceResults = [];
  List<CategoryModel> _categoryResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Auto-focus search field when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      setState(() {
        _serviceResults.clear();
        _categoryResults.clear();
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
    final categoriesProvider = context.read<CategoriesProvider>();

    final allServices = servicesProvider.services;
    final allCategories = categoriesProvider.categories;

    // Filter services by name (case-insensitive)
    final serviceResults = allServices.where((service) {
      return service.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // Filter categories by name (case-insensitive)
    final categoryResults = allCategories.where((category) {
      return category.categoryName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // Sort by name
    serviceResults.sort((a, b) => a.name.compareTo(b.name));
    categoryResults.sort((a, b) => a.categoryName.compareTo(b.categoryName));

    setState(() {
      _serviceResults = serviceResults;
      _categoryResults = categoryResults;
      _isSearching = false;
    });
  }

  Color _parseColor(String colorString) {
    try {
      // Remove any whitespace
      String cleanColor = colorString.trim();

      // Handle malformed data with slashes or other invalid characters
      // Extract only valid hex characters (0-9, A-F, a-f)
      cleanColor = cleanColor.replaceAll(RegExp(r'[^0-9A-Fa-f#xX]'), '');

      // If empty after cleaning, return default
      if (cleanColor.isEmpty) {
        return AppColors.roseColor;
      }

      // If it starts with #, replace # with 0xFF
      if (cleanColor.startsWith('#')) {
        cleanColor = cleanColor.replaceFirst('#', '0xFF');
      }
      // Remove any 0x or 0X prefix first
      else if (cleanColor.toLowerCase().startsWith('0x')) {
        cleanColor = cleanColor.substring(2);
        // Add 0xFF prefix
        cleanColor = '0xFF$cleanColor';
      }
      // If it doesn't have 0xFF prefix, add it
      else if (!cleanColor.startsWith('0xFF')) {
        cleanColor = '0xFF$cleanColor';
      }

      // Ensure we only take first 10 characters (0xFF + 6 hex digits)
      if (cleanColor.length > 10) {
        cleanColor = cleanColor.substring(0, 10);
      }

      return Color(int.parse(cleanColor));
    } catch (e) {
      // If parsing fails, return default rose color
      print('Error parsing color "$colorString": $e');
      return AppColors.roseColor;
    }
  }

  void _onServiceTapped(ServiceModel service) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServiceChoosingPage(service: service)),
    );
  }

  void _onCategoryTapped(CategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CategoryPage(category: category)),
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      // Home - Go back
      Navigator.pop(context);
    } else if (index == 1) {
      // Already on search page
      return;
    } else if (index == 2) {
      Navigator.pushNamed(context, RouteNames.orderManagement);
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditProfileSettings()),
      );
    } else if (index == 4) {
      Navigator.pushNamed(context, RouteNames.chat);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasResults =
        _serviceResults.isNotEmpty || _categoryResults.isNotEmpty;
    final showEmptyState =
        _searchQuery.isNotEmpty && !_isSearching && !hasResults;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _onSearchChanged,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            decoration: InputDecoration(
              hintText: 'Search services or categories...',
              hintStyle: GoogleFonts.dmSans(
                fontSize: 16,
                color: Theme.of(context).hintColor,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).iconTheme.color,
                size: 22,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).iconTheme.color,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(showEmptyState),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // Search index
        onTap: _onBottomNavTapped,
      ),
    );
  }

  Widget _buildBody(bool showEmptyState) {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.roseColor),
      );
    }

    if (showEmptyState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'No results found',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Search for services or categories',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start typing to see results',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Categories Section
        if (_categoryResults.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.category, size: 20, color: AppColors.roseColor),
              const SizedBox(width: 8),
              Text(
                'Categories',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge!.color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.roseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_categoryResults.length}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.roseColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_categoryResults.length, (index) {
            final category = _categoryResults[index];
            return _buildCategoryItem(category);
          }),
          const SizedBox(height: 24),
        ],

        // Services Section
        if (_serviceResults.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.design_services, size: 20, color: AppColors.roseColor),
              const SizedBox(width: 8),
              Text(
                'Services',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge!.color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.roseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_serviceResults.length}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.roseColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_serviceResults.length, (index) {
            final service = _serviceResults[index];
            return _buildServiceItem(service);
          }),
        ],
      ],
    );
  }

  Widget _buildCategoryItem(CategoryModel category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: ListTile(
        onTap: () => _onCategoryTapped(category),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: _parseColor(category.categoryColor).withOpacity(0.2),
          ),
          child: category.categoryImage.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    category.categoryImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.category,
                        color: _parseColor(category.categoryColor),
                        size: 24,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.category,
                  color: _parseColor(category.categoryColor),
                  size: 24,
                ),
        ),
        title: Text(
          category.categoryName,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        subtitle: Text(
          category.description,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }

  Widget _buildServiceItem(ServiceModel service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: ListTile(
        onTap: () => _onServiceTapped(service),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: service.color != null
                ? _parseColor(service.color!).withOpacity(0.2)
                : AppColors.roseColor.withOpacity(0.2),
          ),
          child: service.imageUrl != null && service.imageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    service.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.design_services,
                        color: service.color != null
                            ? _parseColor(service.color!)
                            : AppColors.roseColor,
                        size: 24,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.design_services,
                  color: service.color != null
                      ? _parseColor(service.color!)
                      : AppColors.roseColor,
                  size: 24,
                ),
        ),
        title: Text(
          service.name,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        subtitle: service.description.isNotEmpty
            ? Text(
                service.description,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }
}
