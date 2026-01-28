import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_routes.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/categories_provider.dart';
import 'providers/services_provider.dart';
import 'providers/news_provider.dart';
import 'providers/saved_services_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/invoice_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('No .env file found, using default configuration'); //
  }

  runApp(const Buzz());
}

class Buzz extends StatelessWidget {
  const Buzz({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => SavedServicesProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
      ],
      child: MaterialApp(
        initialRoute: AppRoutes.initialRoute,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
