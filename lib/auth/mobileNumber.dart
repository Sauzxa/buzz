import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../Widgets/button.dart';
import '../providers/user_provider.dart';
import '../routes/route_names.dart';

class MobileNumberPage extends StatefulWidget {
  const MobileNumberPage({Key? key}) : super(key: key);

  @override
  State<MobileNumberPage> createState() => _MobileNumberPageState();
}

class _MobileNumberPageState extends State<MobileNumberPage> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountry = 'Algeria (+213)';
  String _countryCode = '+213';

  final Map<String, String> _countries = {
    'Algeria (+213)': '+213',
    'France (+33)': '+33',
    'Morocco (+212)': '+212',
    'Tunisia (+216)': '+216',
    'USA (+1)': '+1',
  };

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onCountryChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedCountry = newValue;
        _countryCode = _countries[newValue]!;
        _phoneController.clear(); // Clear phone input when country changes
      });
    }
  }

  void _onContinue() {
    final phoneNumber = _phoneController.text;

    if (phoneNumber.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }

    if (phoneNumber.length != 9) {
      _showError('Phone number must be 9 digits');
      return;
    }

    // Local phone number with leading 0 (e.g., 0555123456)
    final localPhoneNumber = '0$phoneNumber';

    // Save phone number to provider (local format, no country code)
    context.read<UserProvider>().setPhoneNumber(localPhoneNumber);

    // Navigate to OTP verification page
    Navigator.pushReplacementNamed(context, RouteNames.otpVerification);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: [
            const SizedBox(height: 40),

            // Logo
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/Logos/PinkLogo.png',
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.ac_unit,
                        size: 40,
                        color: AppColors.roseColor,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Welcome Text
            Text(
              'Welcome',
              style: GoogleFonts.dmSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Enter your phone number to get started',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
            ),

            const SizedBox(height: 40),

            // Country Dropdown
            _CustomCountryDropdown(
              selectedCountry: _selectedCountry,
              countries: _countries,
              onChanged: _onCountryChanged,
              getFlagEmoji: _getCountryFlag,
            ),

            const SizedBox(height: 20),

            // Phone Number Input
            Container(
              decoration: BoxDecoration(
                color:
                    Theme.of(context).inputDecorationTheme.fillColor ??
                    (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.grey[50]),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    _countryCode,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Phone number',
                        hintStyle: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).inputDecorationTheme.hintStyle!.color,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Privacy and agreements text
            Center(
              child: Text(
                'Privacy and agreements',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Continue Button
            PrimaryButton(text: 'Continue', onPressed: _onContinue),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getCountryFlag(String country) {
    if (country.contains('Algeria')) return '🇩🇿';
    if (country.contains('France')) return '🇫🇷';
    if (country.contains('Morocco')) return '🇲🇦';
    if (country.contains('Tunisia')) return '🇹🇳';
    if (country.contains('USA')) return '🇺🇸';
    return '🌍';
  }
}

// Custom Dropdown Field Widget
class _CustomCountryDropdown extends StatefulWidget {
  final String selectedCountry;
  final Map<String, String> countries;
  final Function(String?) onChanged;
  final String Function(String) getFlagEmoji;

  const _CustomCountryDropdown({
    required this.selectedCountry,
    required this.countries,
    required this.onChanged,
    required this.getFlagEmoji,
  });

  @override
  State<_CustomCountryDropdown> createState() => _CustomCountryDropdownState();
}

class _CustomCountryDropdownState extends State<_CustomCountryDropdown> {
  bool _isOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void deactivate() {
    // Just remove overlay without setState during deactivate
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
    super.deactivate();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _showOverlay() {
    if (!mounted) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      // Return a dummy overlay if render box is not ready
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    final size = renderBox.size;

    return OverlayEntry(
      builder: (overlayContext) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: widget.countries.length,
                itemBuilder: (context, index) {
                  final country = widget.countries.keys.elementAt(index);
                  final isSelected = widget.selectedCountry == country;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Remove overlay first, then trigger callback
                          _removeOverlay();
                          // Use post-frame callback to ensure overlay is removed
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            widget.onChanged(country);
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Text(
                                widget.getFlagEmoji(country),
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                country,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color:
                Theme.of(context).inputDecorationTheme.fillColor ??
                (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]
                    : Colors.grey[50]),
            borderRadius: BorderRadius.circular(12),
            border: _isOpen
                ? Border.all(color: AppColors.roseColor, width: 2)
                : Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    widget.getFlagEmoji(widget.selectedCountry),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.selectedCountry,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ],
              ),
              Icon(
                _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
