import 'package:flutter/material.dart';
import 'route_names.dart';
import 'route_generator.dart';

class AppRoutes {
  static String get initialRoute => RouteNames.splash;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return RouteGenerator.generateRoute(settings);
  }

  // Helper method to navigate to email page with replacement
  static void navigateToEmailPage(BuildContext context) {
    Navigator.pushReplacementNamed(context, RouteNames.emailPage);
  }
}
