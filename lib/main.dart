import 'package:ayanna_school/screens/eleve_global_screen.dart';
import 'package:flutter/material.dart';
import 'theme/ayanna_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/classes_screen.dart';
import 'screens/configuration_screen.dart';
import 'services/app_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<bool> _isFirstLaunch() async {
    return !(await AppPreferences.isConfigured());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayanna School',
      theme: ayannaTheme,
      home: FutureBuilder<bool>(
        future: _isFirstLaunch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final isFirstLaunch = snapshot.data!;
          return AuthScreen(navigateToClasses: !isFirstLaunch);
        },
      ),
      routes: {
        '/classes': (context) => const EleveGlobalScreen(),
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
