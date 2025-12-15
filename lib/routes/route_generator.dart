import 'package:flutter/material.dart';
import 'route_names.dart';
import '../onboarding/onb1.dart';
import '../onboarding/onb2.dart';
import '../onboarding/onb3.dart';
import '../onboarding/onb4.dart';
import '../onboarding/onb5.dart';
import '../auth/mobileNumber.dart';
import '../auth/otp.dart';

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
