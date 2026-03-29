import 'package:flutter/material.dart';
import 'screens/greeting_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FarmerFriendApp());
}

class FarmerFriendApp extends StatelessWidget {
  const FarmerFriendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer Friend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D32),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const GreetingScreen(),
    );
  }
}
