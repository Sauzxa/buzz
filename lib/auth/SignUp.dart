import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../Widgets/button.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../utils/algeriaWilayas.dart';
import '../routes/route_names.dart';
import '../l10n/app_localizations.dart';

class SignUpPage extends StatefulWidget {
  final String verifiedEmail;

  const SignUpPage({super.key, required this.verifiedEmail});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _selectedCountry = 'Algeria (+213)';
  String _countryCode = '+213';
  String? _selectedWilaya;
  bool _termsAccepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final Map<String, String> _countries = {
    'Algeria (+213)': '+213',
    'France (+33)': '+33',
    'Morocco (+212)': '+212',
    'Tunisia (+216)': '+216',
    'USA (+1)': '+1',
  };

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onCountryChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedCountry = newValue;
        _countryCode = _countries[newValue]!;
        _phoneController.clear();
      });
    }
  }

  String _getCountryFlag(String country) {
    if (country.contains('Algeria')) return '🇩🇿';
    if (country.contains('France')) return '🇫🇷';
    if (country.contains('Morocco')) return '🇲🇦';
    if (country.contains('Tunisia')) return '🇹🇳';
    if (country.contains('USA')) return '🇺🇸';
    return '🌍';
  }

  bool get _isFormValid {
    return _fullNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _postalCodeController.text.isNotEmpty &&
        _selectedWilaya != null &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _termsAccepted;
  }

  Future<void> _onSingup() async {
    if (!_isFormValid) {
      _showError(
        AppLocalizations.of(context)?.translate('error_fill_all') ??
            'Please fill all fields and accept terms and conditions',
      );
      return;
    }

    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.length != 9) {
      _showError(
        AppLocalizations.of(context)?.translate('error_phone_length') ??
            'Phone number must be 9 digits',
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError(
        AppLocalizations.of(context)?.translate('error_passwords_mismatch') ??
            'Passwords do not match',
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError(
        AppLocalizations.of(context)?.translate('error_password_length') ??
            'Password must be at least 6 characters',
      );
      return;
    }

    // Build signup data from form fields
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Local phone number with leading 0 (e.g., 0555123456)
    final localPhoneNumber = '0$phoneNumber';

    final signupData = {
      'phoneNumber': localPhoneNumber,
      'fullName': _fullNameController.text,
      'email': widget.verifiedEmail, // Use verified email from previous step
      'currentAddress': _addressController.text,
      'postalCode': int.tryParse(_postalCodeController.text) ?? 0,
      'wilaya': _selectedWilaya,
      'password': _passwordController.text,
      'role': 'CUSTOMER',
    };

    // Use AuthProvider to signup
    await authProvider.signup(signupData);

    if (!mounted) return;

    // Check if signup was successful
    if (authProvider.isAuthenticated && authProvider.user != null) {
      // Update UserProvider with complete user object from signup response
      userProvider.updateUser(authProvider.user!);

      // Navigate to Welcome Page after signup
      Navigator.pushReplacementNamed(context, RouteNames.welcome);
    } else {
      // Show error message
      _showError(
        authProvider.error ??
            (AppLocalizations.of(context)?.translate('error_signup_failed') ??
                'Signup failed. Please try again.'),
      );
    }
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppLocalizations.of(context)?.translate('signup_appbar_title') ??
              'Register',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge!.color,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: [
            const SizedBox(height: 20),

            // Getting Started Title
            Text(
              AppLocalizations.of(context)?.translate('signup_title') ??
                  'Getting Started',
              style: GoogleFonts.dmSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              AppLocalizations.of(context)?.translate('signup_subtitle') ??
                  'Seems you are new here,\nLet\'s set up your profile.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall!.color,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // Full Name
            _buildInputField(
              controller: _fullNameController,
              label:
                  AppLocalizations.of(context)?.translate('fullname_label') ??
                  'Full Name',
            ),

            const SizedBox(height: 16),

            // Phone Number with Country Selector
            _buildPhoneNumberField(),

            const SizedBox(height: 16),

            // Current Address
            _buildInputField(
              controller: _addressController,
              label:
                  AppLocalizations.of(
                    context,
                  )?.translate('current_address_label') ??
                  'Current Address',
            ),

            const SizedBox(height: 16),

            // Code Postal and Wilaya Row
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildInputField(
                    controller: _postalCodeController,
                    label:
                        AppLocalizations.of(
                          context,
                        )?.translate('postal_code_label') ??
                        'Code Postal',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(flex: 1, child: _buildWilayaDropdown()),
              ],
            ),

            const SizedBox(height: 16),

            // Password
            _buildInputField(
              controller: _passwordController,
              label:
                  AppLocalizations.of(context)?.translate('password_label') ??
                  'Password',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Confirm Password
            _buildInputField(
              controller: _confirmPasswordController,
              label:
                  AppLocalizations.of(
                    context,
                  )?.translate('confirm_password_label') ??
                  'Confirm Password',
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // Terms and Conditions Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        _termsAccepted = value ?? false;
                      });
                    },
                    activeColor: AppColors.roseColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _termsAccepted = !_termsAccepted;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                        children: [
                          TextSpan(
                            text:
                                AppLocalizations.of(
                                  context,
                                )?.translate('terms_aggrement') ??
                                'By creating an account, you agree to our ',
                          ),
                          TextSpan(
                            text:
                                AppLocalizations.of(
                                  context,
                                )?.translate('terms_link') ??
                                'Term and Conditions',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.roseColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Sign up Button
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Opacity(
                  opacity: _isFormValid ? 1.0 : 0.5,
                  child: PrimaryButton(
                    text:
                        AppLocalizations.of(context)?.translate('signup_btn') ??
                        'Sign up',
                    isLoading: authProvider.isLoading,
                    onPressed: _isFormValid ? _onSingup : () {},
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Already have account
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(
                        context,
                      )?.translate('already_have_account') ??
                      'Already have an account? ',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, RouteNames.signIn);
                  },
                  child: Text(
                    AppLocalizations.of(
                          context,
                        )?.translate('login_link_text') ??
                        'Login',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.roseColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: Theme.of(context).inputDecorationTheme.labelStyle!.color,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          onChanged: (value) => setState(() {}),
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.roseColor, width: 2),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Dropdown
        _CustomCountryDropdown(
          selectedCountry: _selectedCountry,
          countries: _countries,
          onChanged: _onCountryChanged,
          getFlagEmoji: _getCountryFlag,
        ),
        const SizedBox(height: 12),
        // Phone Number Input
        Text(
          AppLocalizations.of(context)?.translate('phone_number_label') ??
              'Phone Number',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: Theme.of(context).inputDecorationTheme.labelStyle!.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(
                _countryCode,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
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
                  onChanged: (value) => setState(() {}),
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(
                          context,
                        )?.translate('phone_number_hint') ??
                        'Phone number',
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).inputDecorationTheme.hintStyle!.color,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWilayaDropdown() {
    return _CustomWilayaDropdown(
      selectedWilaya: _selectedWilaya,
      onChanged: (value) {
        setState(() {
          _selectedWilaya = value;
        });
      },
    );
  }
}

// Custom Dropdown Field Widget for Wilaya
class _CustomWilayaDropdown extends StatefulWidget {
  final String? selectedWilaya;
  final Function(String?) onChanged;

  const _CustomWilayaDropdown({
    required this.selectedWilaya,
    required this.onChanged,
  });

  @override
  State<_CustomWilayaDropdown> createState() => _CustomWilayaDropdownState();
}

class _CustomWilayaDropdownState extends State<_CustomWilayaDropdown> {
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
                itemCount: algeriaWilayas.length,
                itemBuilder: (context, index) {
                  final wilaya = algeriaWilayas[index];
                  final wilayaName = wilaya['name'] as String;
                  final isSelected = widget.selectedWilaya == wilayaName;

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
                            widget.onChanged(wilayaName);
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Text(
                            wilayaName,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)?.translate('wilaya_label') ?? 'Wilaya',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Theme.of(context).inputDecorationTheme.labelStyle!.color,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isOpen
                      ? AppColors.roseColor
                      : Theme.of(context).dividerColor,
                  width: _isOpen ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.selectedWilaya ?? '',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: widget.selectedWilaya != null
                            ? Theme.of(context).textTheme.bodyLarge!.color
                            : Theme.of(
                                context,
                              ).inputDecorationTheme.hintStyle!.color,
                      ),
                    ),
                  ),
                  Icon(
                    _isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Dropdown Field Widget for Country
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
                          _removeOverlay();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)?.translate('country_label') ??
                'Country',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Theme.of(context).inputDecorationTheme.labelStyle!.color,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isOpen
                      ? AppColors.roseColor
                      : Theme.of(context).dividerColor,
                  width: _isOpen ? 2 : 1,
                ),
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
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
