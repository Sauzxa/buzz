import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../Widgets/button.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../routes/route_names.dart';

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
  void initState() {
    super.initState();
    // Pre-fill controllers if data is available in UserProvider (optional UX improvement)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.user.email != null &&
          userProvider.user.email!.isNotEmpty) {
        _emailController.text = userProvider.user.email!;
      }
    });
  }

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
      final userProvider = context.read<UserProvider>();

      // 1. Initial populate from login response
      userProvider.updateUser(authProvider.user!);

      // 2. If ID is available, fetch full profile to ensure all fields (phone, address, etc.)
      // are populated, as login response might be partial.
      if (authProvider.user!.id != null) {
        // We don't await this to delay navigation, but we could if critical.
        // User requested "load infos", so fetching it is good practice here.
        // Given UX, maybe fetch in background or show loading?
        // Let's await it to be safe as per user request "not load infos... this is the probleme"
        await userProvider.fetchUserById(authProvider.user!.id!);
      }

      if (!mounted) return;

      // Navigate to HomePage
      Navigator.pushReplacementNamed(context, RouteNames.home);
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
    Navigator.pushNamed(context, RouteNames.forgetPassword);
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
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, RouteNames.signUp);
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
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Welcome back, you\'ve\nbeen missed!',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: const Color(0xFF888888),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            // Email Address
            _buildInputField(
              controller: _emailController,
              label: 'Email Address',
              hintText: userProvider.user.email?.isNotEmpty == true
                  ? userProvider.user.email
                  : '',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 24),

            // Password
            _buildInputField(
              controller: _passwordController,
              label: 'Password',
              // Use stored password as hint if available (per user request)
              hintText: userProvider.user.password?.isNotEmpty == true
                  ? userProvider.user.password
                  : '',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey[400],
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

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
                        side: BorderSide(
                          color: _rememberMe
                              ? AppColors.roseColor
                              : Colors.grey[400]!,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _onForgotPassword,
                  child: Text(
                    'Forgot Password ?',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.roseColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Login Button
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return PrimaryButton(
                  text: 'Login',
                  isLoading: authProvider.isLoading,
                  onPressed: _onLogin,
                );
              },
            ),

            const SizedBox(height: 24),

            // OR Divider
            Row(
              children: [
                const Spacer(),
                Text(
                  'OR',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF888888),
                  ),
                ),
                const Spacer(),
              ],
            ),

            const SizedBox(height: 24),

            // Continue with Google Button
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F7), // Light grey background
                borderRadius: BorderRadius.circular(28),
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

            const SizedBox(height: 48),

            // Don't have an account? Sign Up
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account ? ',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: const Color(0xFF888888),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      RouteNames.mobileNumber,
                    );
                  },
                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.roseColor,
                      fontWeight: FontWeight.bold,
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
    String? hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Using Stack to create custom floating label effect if needed or standard InputDecoration
        // Based on image, it looks like standard OutlineInputBorder with label behavior
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintStyle: GoogleFonts.dmSans(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            labelStyle: GoogleFonts.dmSans(
              color: const Color(0xFF888888),
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: AppColors.roseColor,
                width: 1.5,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
