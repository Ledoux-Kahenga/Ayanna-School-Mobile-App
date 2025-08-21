import 'package:flutter/material.dart';
import 'theme/ayanna_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/classes_screen.dart';
import 'screens/configuration_screen.dart';
import 'services/app_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayanna School',
      theme: ayannaTheme,
      home: const StartupScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/classes': (context) => const ClassesScreen(),
        '/configuration': (context) =>
            const ConfigurationScreen(isFirstSetup: false),
      },
    );
  }
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    // Petite pause pour éviter le flash
    await Future.delayed(const Duration(milliseconds: 500));

    final isConfigured = await AppPreferences.isConfigured();

    if (mounted) {
      if (isConfigured) {
        // Application déjà configurée, on authentifie puis on va aux classes
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const AuthScreen(navigateToClasses: true),
          ),
        );
      } else {
        // Premier lancement, on authentifie puis on configure
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const AuthScreen(navigateToClasses: false),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AyannaColors.lightGrey,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Chargement...',
              style: TextStyle(color: AyannaColors.darkGrey),
            ),
          ],
        ),
      ),
    );
  }
}
