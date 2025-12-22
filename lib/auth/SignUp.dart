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

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedWilaya;
  bool _termsAccepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _fullNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _postalCodeController.text.isNotEmpty &&
        _selectedWilaya != null &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _termsAccepted;
  }

  Future<void> _onSingup() async {
    if (!_isFormValid) {
      _showError('Please fill all fields and accept terms and conditions');
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      _showError('Please enter a valid email address');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    // Build signup data from form fields
    // Get phone number from UserProvider (set in previous screen)
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final phoneNumber = userProvider.user.phoneNumber;

    final signupData = {
      'phoneNumber': phoneNumber,
      'fullName': _fullNameController.text,
      'email': _emailController.text,
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
      // Save user data to UserProvider
      userProvider.setFullName(_fullNameController.text);
      userProvider.setEmail(_emailController.text);
      userProvider.setCurrentAddress(_addressController.text);
      userProvider.setpostalCode(_postalCodeController.text);
      userProvider.setWilaya(_selectedWilaya!);
      userProvider.setPassword(_passwordController.text);

      // Navigate to HomePage
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else {
      // Show error message
      _showError(authProvider.error ?? 'Signup failed. Please try again.');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, RouteNames.mobileNumber);
          },
        ),
        title: Text(
          'Register',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
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
              'Getting Started',
              style: GoogleFonts.dmSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Seems you are new here,\nLet\'s set up your profile.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // Full Name
            _buildInputField(
              controller: _fullNameController,
              label: 'Full Name',
            ),

            const SizedBox(height: 16),

            // Email Address
            _buildInputField(
              controller: _emailController,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // Current Address
            _buildInputField(
              controller: _addressController,
              label: 'Current Address',
            ),

            const SizedBox(height: 16),

            // Code Postal and Wilaya Row
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildInputField(
                    controller: _postalCodeController,
                    label: 'Code Postal',
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
              label: 'Password',
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
              label: 'Confirm Password',
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
                          color: Colors.grey[600],
                        ),
                        children: [
                          const TextSpan(
                            text: 'By creating an account, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Term and Conditions',
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
            Opacity(
              opacity: _isFormValid ? 1.0 : 0.5,
              child: PrimaryButton(
                text: 'Sign up',
                onPressed: _isFormValid ? _onSingup : () {},
              ),
            ),

            const SizedBox(height: 20),

            // Already have account
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, RouteNames.signIn);
                  },
                  child: Text(
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
          style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[400]),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            inputFormatters: inputFormatters,
            onChanged: (value) => setState(() {}),
            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWilayaDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wilaya',
          style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[400]),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedWilaya,
              isExpanded: true,
              hint: Text(
                '',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
              items: algeriaWilayas.map((wilaya) {
                return DropdownMenuItem<String>(
                  value: wilaya['name'],
                  child: Text(
                    wilaya['name'],
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWilaya = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
