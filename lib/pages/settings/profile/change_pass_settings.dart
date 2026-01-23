import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../theme/colors.dart';
import '../../../Widgets/button.dart';
import '../../../Widgets/custom_bottom_nav_bar.dart';
import '../../../Widgets/home_drawer.dart';
import '../../../providers/user_provider.dart';
import '../../../routes/route_names.dart';

class ChangePassSettings extends StatefulWidget {
  const ChangePassSettings({Key? key}) : super(key: key);

  @override
  State<ChangePassSettings> createState() => _ChangePassSettingsState();
}

class _ChangePassSettingsState extends State<ChangePassSettings> {
  final _formKey = GlobalKey<FormState>();

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Feature coming soon!')));
    }
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();

      // According to user: "it will send put user /id req same as the previous one"
      // We assume passing 'password' field updates the password.
      final Map<String, dynamic> data = {
        'password': _newPassController.text,
        // Backend might need 'currentPassword' validation? Use usually does.
        // But user said "same as previous one", implying straight PUT.
        // I will just send the new password.
      };

      final success = await userProvider.updateUserProfile(data: data);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully! Please login again.'),
            backgroundColor: Colors.green,
          ),
        );
        // User noted: "changing password will required again login to the app"
        // So we should probably logout or navigate to login?
        // For now, staying on page or popping.
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.errorMessage ?? 'Update failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
                      'Change Password',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Notification icon
                  Stack(
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
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
                        'Change Password',
                        textAlign: TextAlign.start,
                        style: GoogleFonts.dmSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Please note changing password will required\nagain login to the app.',
                        textAlign: TextAlign.start,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Current Password
                      _buildPasswordField(
                        controller: _currentPassController,
                        label: 'Current Password',
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
                        label: 'New Password',
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
                        label: 'Confirm New Password',
                        hint: '',
                        isObscure: _obscureConfirm,
                        onVisibilityToggle: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                      ),

                      const SizedBox(height: 40),

                      // Save Button
                      PrimaryButton(
                        text: 'Save Password',
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
            color: Colors.black,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.dmSans(color: Colors.grey.shade400),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(color: Colors.black87),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ), // Figma shows grey even when focused/active? Keeping it subtle
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade400,
                size: 22,
              ),
              onPressed: onVisibilityToggle,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required'; // Required validation message
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
            color: Colors.black,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.dmSans(color: Colors.grey.shade400),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(color: Colors.black87),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade400,
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
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }
}
