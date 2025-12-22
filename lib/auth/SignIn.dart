import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../Widgets/button.dart';
import '../providers/auth_provider.dart';
import '../core/homePage.dart';
import 'mobileNumber.dart';
import 'SignUp.dart';
import 'forgetPassword.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    // Use AuthProvider to login
    final authProvider = context.read<AuthProvider>();
    await authProvider.login(email, password);

    if (!mounted) return;

    // Check if login was successful
    if (authProvider.isAuthenticated && authProvider.user != null) {
      // Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Show error message
      _showError(authProvider.error ?? 'Login failed. Please try again.');
    }
  }

  void _onGoogleSignIn() {
    // TODO: Implement Google Sign In
    print('Google Sign In');
  }

  void _onForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgetPasswordPage()),
    );
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignUpPage()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: [
            const SizedBox(height: 20),

            // Let's Sign You In Title
            Text(
              'Let\'s Sign You In',
              style: GoogleFonts.dmSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Welcome back, you\'ve\nbeen missed!',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            // Email Address
            _buildInputField(
              controller: _emailController,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

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

            const SizedBox(height: 20),

            // Remember Me and Forgot Password Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: AppColors.roseColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _rememberMe = !_rememberMe;
                        });
                      },
                      child: Text(
                        'Remember Me',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _onForgotPassword,
                  child: Text(
                    'Forget Password ?',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.roseColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Login Button
            PrimaryButton(text: 'Login', onPressed: _onLogin),

            const SizedBox(height: 20),

            // OR Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
              ],
            ),

            const SizedBox(height: 20),

            // Continue with Google Button
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onGoogleSignIn,
                  borderRadius: BorderRadius.circular(28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/googleIcon.png',
                        height: 24,
                        width: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.g_mobiledata,
                            size: 24,
                            color: Colors.grey[600],
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continue with Google',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Don't have an account? Sign Up
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account ? ',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MobileNumberPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Sign Up',
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
}
