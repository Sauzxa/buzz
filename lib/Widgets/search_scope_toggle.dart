import 'package:flutter/material.dart';

import '../theme/colors.dart';

enum SearchScope { allServices, filteredCategories }

class SearchScopeToggle extends StatelessWidget {
  final SearchScope currentScope;
  final Function(SearchScope) onScopeChanged;
  final bool hasActiveFilter;

  const SearchScopeToggle({
    super.key,
    required this.currentScope,
    required this.onScopeChanged,
    this.hasActiveFilter = false,
  });

  void _toggleScope() {
    final newScope = currentScope == SearchScope.allServices
        ? SearchScope.filteredCategories
        : SearchScope.allServices;
    onScopeChanged(newScope);
  }

  String _getTooltipText() {
    if (currentScope == SearchScope.allServices) {
      return 'Search: All Services';
    } else {
      return hasActiveFilter
          ? 'Search: Filtered Categories'
          : 'Search: All Services (No filter active)';
    }
  }

  IconData _getIcon() {
    if (currentScope == SearchScope.allServices) {
      return Icons.gps_off; // GPS off for all services
    } else {
      return Icons.gps_fixed; // GPS fixed for filtered range
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _getTooltipText(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(_getIcon(), color: AppColors.roseColor, size: 22),
          onPressed: _toggleScope,
        ),
      ),
    );
  }
}
