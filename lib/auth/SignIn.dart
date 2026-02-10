import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../Widgets/button.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../routes/route_names.dart';
import '../core/homePage.dart';
import '../utils/fade_route.dart';
import '../l10n/app_localizations.dart';

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
  bool _isLoggingIn = false; // Local loading state for entire login flow
  bool _isGoogleSigningIn = false; // Loading state for Google Sign-In

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
      _showError(
        AppLocalizations.of(context)?.translate('error_enter_email_password') ??
            'Please enter email and password',
      );
      return;
    }

    if (!_isValidEmail(email)) {
      _showError(
        AppLocalizations.of(context)?.translate('error_invalid_email') ??
            'Please enter a valid email address',
      );
      return;
    }

    // Start local loading state
    setState(() {
      _isLoggingIn = true;
    });

    try {
      // Use AuthProvider to login
      final authProvider = context.read<AuthProvider>();
      await authProvider.login(email, password);

      if (!mounted) return;

      // Check if login was successful
      if (authProvider.isAuthenticated && authProvider.user != null) {
        final userProvider = context.read<UserProvider>();

        // Update UserProvider with user data from login response
        userProvider.updateUser(authProvider.user!);

        // Fetch complete profile if userId is available
        // Login response has: userId, email, fullName, role, tokens
        // But missing: phoneNumber, currentAddress, postalCode, wilaya
        if (authProvider.user!.id != null) {
          await userProvider.fetchUserById(authProvider.user!.id!);
        }

        if (!mounted) return;

        // Add a brief delay to show the loading state completed
        // This gives better visual feedback that the login was successful
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // Navigate to HomePage with enhanced fade+scale transition
        // Loading state will remain visible during the animation
        Navigator.pushReplacement(context, FadeRoute(page: const HomePage()));

        // Note: We don't set _isLoggingIn to false here because the page
        // is being replaced. The loading button will fade out with the page.
      } else {
        // Login failed - stop loading and show error
        setState(() {
          _isLoggingIn = false;
        });
        _showError(
          authProvider.error ??
              (AppLocalizations.of(context)?.translate('error_login_failed') ??
                  'Login failed. Please try again.'),
        );
      }
    } catch (e) {
      // Handle any unexpected errors
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
        _showError(
          AppLocalizations.of(context)?.translate('error_unexpected') ??
              'An unexpected error occurred. Please try again.',
        );
      }
    }
  }

  Future<void> _onGoogleSignIn() async {
    setState(() {
      _isGoogleSigningIn = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signInWithGoogle();

      if (!mounted) return;

      // Check if Google Sign-In was successful
      if (authProvider.isAuthenticated && authProvider.user != null) {
        final userProvider = context.read<UserProvider>();

        // Update UserProvider with user data from Google login response
        userProvider.updateUser(authProvider.user!);

        // Fetch complete profile if userId is available
        if (authProvider.user!.id != null) {
          await userProvider.fetchUserById(authProvider.user!.id!);
        }

        if (!mounted) return;

        // Add a brief delay for visual feedback
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // Navigate to HomePage
        Navigator.pushReplacement(context, FadeRoute(page: const HomePage()));
      } else {
        // Google Sign-In failed - stop loading and show error
        setState(() {
          _isGoogleSigningIn = false;
        });

        // Show error message (but not if user cancelled)
        if (authProvider.error != null &&
            !authProvider.error!.contains('cancelled')) {
          _showError(authProvider.error!);
        }
      }
    } catch (e) {
      // Handle any unexpected errors
      if (mounted) {
        setState(() {
          _isGoogleSigningIn = false;
        });
        _showError(
          AppLocalizations.of(
                context,
              )?.translate('error_google_signin_failed') ??
              'Google Sign-In failed. Please try again.',
        );
      }
    }
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
              AppLocalizations.of(context)?.translate('login_title') ??
                  'Let\'s Sign You In',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              AppLocalizations.of(context)?.translate('login_subtitle') ??
                  'Welcome back, you\'ve\nbeen missed!',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodySmall!.color,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            // Email Address
            _buildInputField(
              controller: _emailController,
              label:
                  AppLocalizations.of(context)?.translate('email_label') ??
                  'Email Address',
              hintText: userProvider.user.email?.isNotEmpty == true
                  ? userProvider.user.email
                  : '',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 24),

            // Password
            _buildInputField(
              controller: _passwordController,
              label:
                  AppLocalizations.of(context)?.translate('password_label') ??
                  'Password',
              // Use stored password as hint if available (per user request)
              hintText: userProvider.user.password?.isNotEmpty == true
                  ? userProvider.user.password
                  : '',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
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
                        AppLocalizations.of(
                              context,
                            )?.translate('remember_me') ??
                            'Remember Me',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _onForgotPassword,
                  child: Text(
                    AppLocalizations.of(
                          context,
                        )?.translate('forgot_password') ??
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
            PrimaryButton(
              text:
                  AppLocalizations.of(context)?.translate('login_btn') ??
                  'Login',
              isLoading: _isLoggingIn, // Use local state for entire flow
              onPressed: _onLogin,
            ),

            const SizedBox(height: 24),

            // OR Divider
            Row(
              children: [
                const Spacer(),
                Text(
                  AppLocalizations.of(context)?.translate('or_divider') ?? 'OR',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodySmall!.color,
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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isGoogleSigningIn
                      ? null
                      : _onGoogleSignIn, // Disable when loading
                  borderRadius: BorderRadius.circular(28),
                  child: _isGoogleSigningIn
                      ? Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.roseColor,
                              ),
                            ),
                          ),
                        )
                      : Row(
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
                              AppLocalizations.of(
                                    context,
                                  )?.translate('continue_google') ??
                                  'Continue with Google',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color,
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
                  AppLocalizations.of(context)?.translate('no_account') ??
                      'Don\'t have an account ? ',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall!.color,
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
                    AppLocalizations.of(context)?.translate('signup_link') ??
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
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            hintStyle: GoogleFonts.dmSans(
              color: Theme.of(context).inputDecorationTheme.hintStyle!.color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            labelStyle: GoogleFonts.dmSans(
              color: Theme.of(context).inputDecorationTheme.labelStyle!.color,
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
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
