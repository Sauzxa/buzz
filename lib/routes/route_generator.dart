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
import '../pages/chat/support_chat_page.dart';
import '../core/splash_screen.dart';
import '../pages/settings/general_settings.dart';
import '../pages/orders/order_management_page.dart';
import '../pages/orders/order_history_page.dart';
import '../pages/orders/order_tracking_page.dart';
import '../pages/orders/order_details_page.dart';
import '../pages/orders/payment_upload_page.dart';
import '../pages/orders/payment_info_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

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

      case RouteNames.chat:
        return MaterialPageRoute(builder: (_) => const SupportChatPage());

      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const GeneralSettingsPage());

      // Order Management Routes
      case RouteNames.orderManagement:
        return MaterialPageRoute(builder: (_) => const OrderManagementPage());

      case RouteNames.orderHistory:
        return MaterialPageRoute(builder: (_) => const OrderHistoryPage());

      case RouteNames.orderTracking:
        return MaterialPageRoute(builder: (_) => const OrderTrackingPage());

      case RouteNames.orderDetails:
        final order = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OrderDetailsPage(order: order),
        );

      case RouteNames.paymentUpload:
        final order = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PaymentUploadPage(order: order),
        );

      case RouteNames.paymentInfo:
        return MaterialPageRoute(builder: (_) => const PaymentInfoPage());

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
