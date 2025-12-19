import 'package:flutter/material.dart';
import 'route_names.dart';
import '../onboarding/onb1.dart';
import '../onboarding/onb2.dart';
import '../onboarding/onb3.dart';
import '../onboarding/onb4.dart';
import '../onboarding/onb5.dart';
import '../auth/mobileNumber.dart';
import '../auth/otp.dart';
import '../auth/SignUp.dart';
import '../auth/SignIn.dart';
import '../auth/forgetPassword.dart';
import '../core/welcome.dart';
import '../core/homePage.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.onboarding1:
        return MaterialPageRoute(builder: (_) => const onb1());

      case RouteNames.onboarding2:
        return MaterialPageRoute(builder: (_) => const onb2());

      case RouteNames.onboarding3:
        return MaterialPageRoute(builder: (_) => const onb3());

      case RouteNames.onboarding4:
        return MaterialPageRoute(builder: (_) => const onb4());

      case RouteNames.onboarding5:
        return MaterialPageRoute(builder: (_) => const onb5());

      case RouteNames.mobileNumber:
        return MaterialPageRoute(builder: (_) => const MobileNumberPage());

      case RouteNames.otpVerification:
        return MaterialPageRoute(builder: (_) => const OTPPage());

      case RouteNames.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpPage());

      case RouteNames.signIn:
        return MaterialPageRoute(builder: (_) => const SignInPage());

      case RouteNames.forgetPassword:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordPage());

      case RouteNames.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());

      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('ERROR: Route not found')),
      ),
    );
  }
}
