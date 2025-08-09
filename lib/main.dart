import 'package:flutter/material.dart';
import 'ayanna_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayanna School',
      theme: AyannaTheme.themeData,
      home: const AuthScreen(),
      routes: {'/home': (context) => const HomeScreen()},
    );
  }
}
