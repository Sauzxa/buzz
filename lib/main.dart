import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'onboarding/onb1.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (optional - will use defaults if not found)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('No .env file found, using default configuration');
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
      ],
      child: MaterialApp(home: onb1(), debugShowCheckedModeBanner: false),
    );
  }
}
