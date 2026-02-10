import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Widgets/notification_popup.dart';
import 'package:provider/provider.dart';
import '../../../theme/colors.dart';
import '../../../Widgets/home_drawer.dart';
import '../../../Widgets/button.dart';
import '../../../Widgets/custom_bottom_nav_bar.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/route_names.dart';
import '../../../l10n/app_localizations.dart';

class ChangePassSettings extends StatefulWidget {
  const ChangePassSettings({Key? key}) : super(key: key);

  @override
  State<ChangePassSettings> createState() => _ChangePassSettingsState();
}

class _ChangePassSettingsState extends State<ChangePassSettings> {
  final _formKey = GlobalKey<FormState>();

  void _showNotificationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationBottomSheet(),
    );
  }

  // Controllers
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // Visibility States
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true; // Now using eye icon like other fields

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, RouteNames.chat);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate('feature_coming_soon') ??
                'Feature coming soon!',
          ),
        ),
      );
    }
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      // Call the changePassword method from AuthProvider
      final success = await authProvider.changePassword(
        currentPassword: _currentPassController.text,
        newPassword: _newPassController.text,
        confirmPassword: _confirmPassController.text,
      );

      if (!mounted) return;

      if (success) {
        // Clear form fields
        _currentPassController.clear();
        _newPassController.clear();
        _confirmPassController.clear();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                    context,
                  )?.translate('password_changed_success') ??
                  'Password changed successfully!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Show error message from auth provider
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.error ??
                  AppLocalizations.of(
                    context,
                  )?.translate('password_change_failed') ??
                  'Failed to change password',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)?.translate('error_label') ?? 'Error'}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevent scaffold resize when keyboard appears
      backgroundColor: AppColors.roseColor,
      drawer:
          const HomeDrawer(), // Needed if using Grid View icon to open drawer
      body: Stack(
        children: [
          // Header Content (Pink Area)
          SafeArea(
            bottom: false,
            child: Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(
                        Icons.grid_view,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      AppLocalizations.of(
                            context,
                          )?.translate('change_pass_title') ??
                          'Change Password',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Notification icon
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: _showNotificationBottomSheet,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),

          // White Content Card
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 100),
                    children: [
                      const SizedBox(height: 20),

                      // Heading
                      Text(
                        AppLocalizations.of(
                              context,
                            )?.translate('change_pass_title') ??
                            'Change Password',
                        textAlign: TextAlign.start,
                        style: GoogleFonts.dmSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge!.color,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        AppLocalizations.of(
                              context,
                            )?.translate('change_pass_subtitle') ??
                            'Please note changing password will required\nagain login to the app.',
                        textAlign: TextAlign.start,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Current Password
                      _buildPasswordField(
                        controller: _currentPassController,
                        label:
                            AppLocalizations.of(
                              context,
                            )?.translate('current_password_label') ??
                            'Current Password',
                        hint: '',
                        isObscure: _obscureCurrent,
                        onVisibilityToggle: () {
                          setState(() => _obscureCurrent = !_obscureCurrent);
                        },
                      ),

                      const SizedBox(height: 24),

                      // New Password
                      _buildPasswordField(
                        controller: _newPassController,
                        label:
                            AppLocalizations.of(
                              context,
                            )?.translate('new_password_label') ??
                            'New Password',
                        hint: '',
                        isObscure: _obscureNew,
                        onVisibilityToggle: () {
                          setState(() => _obscureNew = !_obscureNew);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Confirm New Password
                      _buildPasswordFieldWithValidation(
                        controller: _confirmPassController,
                        label:
                            AppLocalizations.of(
                              context,
                            )?.translate('confirm_new_password_label') ??
                            'Confirm New Password',
                        hint: '',
                        isObscure: _obscureConfirm,
                        onVisibilityToggle: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                      ),

                      const SizedBox(height: 40),

                      // Save Button
                      PrimaryButton(
                        text:
                            AppLocalizations.of(
                              context,
                            )?.translate('save_password_btn') ??
                            'Save Password',
                        onPressed: _savePassword,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Bottom Nav Bar - Hide when keyboard is visible
          if (MediaQuery.of(context).viewInsets.bottom == 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNavBar(
                currentIndex: 3,
                onTap: _onBottomNavTapped,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isObscure,
    required VoidCallback onVisibilityToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleLarge!.color,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.dmSans(
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ), // Figma shows grey even when focused/active? Keeping it subtle
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).iconTheme.color,
                size: 22,
              ),
              onPressed: onVisibilityToggle,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(
                    context,
                  )?.translate('field_required_error') ??
                  'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  // New method for confirm password with validation
  Widget _buildPasswordFieldWithValidation({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isObscure,
    required VoidCallback onVisibilityToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleLarge!.color,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.dmSans(
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).iconTheme.color,
                size: 22,
              ),
              onPressed: onVisibilityToggle,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            if (value != _newPassController.text) {
              return AppLocalizations.of(
                    context,
                  )?.translate('error_passwords_mismatch') ??
                  'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }
}
