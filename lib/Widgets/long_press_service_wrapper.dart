import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/service_model.dart';
import '../providers/saved_services_provider.dart';
import '../providers/user_provider.dart';
import '../theme/colors.dart';
import '../utils/snackbar_helper.dart';

class LongPressServiceWrapper extends StatefulWidget {
  final Widget child;
  final ServiceModel service;
  final double borderRadius;

  final VoidCallback? onTap;

  const LongPressServiceWrapper({
    super.key,
    required this.child,
    required this.service,
    this.borderRadius = 16.0,
    this.onTap,
  });

  @override
  State<LongPressServiceWrapper> createState() =>
      _LongPressServiceWrapperState();
}

class _LongPressServiceWrapperState extends State<LongPressServiceWrapper> {
  OverlayEntry? _overlayEntry;

  void _showOverlay(BuildContext context) {
    HapticFeedback.selectionClick();

    // Get position and size of the widget
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => _PreviewOverlay(
        originalOffset: offset,
        originalSize: size,
        service: widget.service,
        child: widget.child,
        onDismiss: _removeOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () => _showOverlay(context),
      onLongPressMoveUpdate: (details) {
        // Optional: Dismiss if moved too far, but Instagram keeps it open usually until release
      },
      child: widget.child,
    );
  }
}

class _PreviewOverlay extends StatefulWidget {
  final Offset originalOffset;
  final Size originalSize;
  final ServiceModel service;
  final Widget child;
  final VoidCallback onDismiss;

  const _PreviewOverlay({
    required this.originalOffset,
    required this.originalSize,
    required this.service,
    required this.child,
    required this.onDismiss,
  });

  @override
  State<_PreviewOverlay> createState() => _PreviewOverlayState();
}

class _PreviewOverlayState extends State<_PreviewOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    final savedProvider = context.read<SavedServicesProvider>();

    if (userProvider.user.id == null) {
      widget.onDismiss();
      SnackBarHelper.showErrorSnackBar(context, 'Please login to save');
      return;
    }

    // Toggle Save
    final wasSaved = savedProvider.isSaved(widget.service.id);
    await savedProvider.toggleSave(userProvider.user.id!, widget.service);

    // Haptic Feedback
    HapticFeedback.mediumImpact();

    // Close overlay
    widget.onDismiss();

    // Show feedback
    if (context.mounted) {
      SnackBarHelper.showSuccessSnackBar(
        context,
        wasSaved ? 'Removed from saved' : 'Saved to your collection',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedProvider = context.watch<SavedServicesProvider>();
    final isSaved = savedProvider.isSaved(widget.service.id);

    // Calculate vertical position to ensure menu stays on screen
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSpace =
        screenHeight - (widget.originalOffset.dy + widget.originalSize.height);
    final showMenuBelow = bottomSpace > 150; // Needs roughly 100px for menu

    // Calculate menu position logic
    final double cardHeight = widget.originalSize.height;
    // We add a bit of margin for the scale effect (1.05x)
    // 5% of height / 2 = 2.5% downwards expansion.
    // For a 200px card, that's 5px. 16px margin is safe.

    return Stack(
      children: [
        // 1. Blurred Background (Captures taps to dismiss)
        GestureDetector(
          onTap: widget.onDismiss,
          onPanEnd: (_) => widget.onDismiss(),
          child: AnimatedBuilder(
            animation: _opacityAnimation,
            builder: (context, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5 * _opacityAnimation.value,
                  sigmaY: 5 * _opacityAnimation.value,
                ),
                child: Container(
                  color: Colors.black.withOpacity(
                    0.4 * _opacityAnimation.value,
                  ),
                ),
              );
            },
          ),
        ),

        // 2. The Focused Item (Card)
        Positioned(
          left: widget.originalOffset.dx,
          top: widget.originalOffset.dy,
          width: widget.originalSize.width,
          height: widget.originalSize.height,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),

        // 3. The Action Menu (Moved out to be a sibling)
        Positioned(
          top: showMenuBelow
              ? widget.originalOffset.dy + cardHeight + 20
              : null,
          bottom: showMenuBelow
              ? null
              : (screenHeight - widget.originalOffset.dy) + 20,
          left: 0,
          right: 0,
          child: Center(
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: GestureDetector(
                onTap: () => _handleSave(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: AppColors.roseColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isSaved ? 'Unsave' : 'Save',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
