import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'onboarding/onb1.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const Buzz(),
    ),
  );
}

class Buzz extends StatelessWidget {
  const Buzz({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: onb1(), debugShowCheckedModeBanner: false);
  }
}
