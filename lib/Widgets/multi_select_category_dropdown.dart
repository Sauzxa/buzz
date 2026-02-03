import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class MultiSelectCategoryDropdown extends StatefulWidget {
  final List<String> allCategories;
  final List<String> selectedCategories;
  final Function(List<String>) onSelectionChanged;

  const MultiSelectCategoryDropdown({
    super.key,
    required this.allCategories,
    required this.selectedCategories,
    required this.onSelectionChanged,
  });

  @override
  State<MultiSelectCategoryDropdown> createState() =>
      _MultiSelectCategoryDropdownState();
}

class _MultiSelectCategoryDropdownState
    extends State<MultiSelectCategoryDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown({bool isDisposing = false}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (!isDisposing) {
      if (mounted) {
        setState(() {
          _isOpen = false;
        });
      }
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeDropdown,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              width: 280,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(-280 + size.width, size.height + 8),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).cardColor,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.roseColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Category list
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: widget.allCategories.length,
                            itemBuilder: (context, index) {
                              final category = widget.allCategories[index];
                              final isSelected = widget.selectedCategories
                                  .contains(category);

                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  List<String> newSelection = List.from(
                                    widget.selectedCategories,
                                  );
                                  if (value == true) {
                                    newSelection.add(category);
                                  } else {
                                    newSelection.remove(category);
                                  }
                                  widget.onSelectionChanged(newSelection);
                                },
                                title: Text(
                                  category,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.roseColor
                                        : Theme.of(
                                            context,
                                          ).textTheme.bodyLarge!.color,
                                  ),
                                ),
                                activeColor: AppColors.roseColor,
                                checkColor: Colors.white,
                                dense: true,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(MultiSelectCategoryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategories != widget.selectedCategories) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  @override
  void dispose() {
    _closeDropdown(isDisposing: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            IconButton(
              icon: Icon(
                _isOpen ? Icons.close : Icons.tune_sharp,
                color: AppColors.roseColor,
                size: 22,
              ),
              onPressed: _toggleDropdown,
            ),
            // Badge showing count
            if (widget.selectedCategories.isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.roseColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.selectedCategories.length}',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
