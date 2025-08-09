import 'package:flutter/material.dart';
import '../widgets/ayanna_appbar.dart';
import '../widgets/ayanna_widgets.dart';
import 'classes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AyannaAppBar(title: 'Accueil'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AyannaLogo(size: 80),
            const SizedBox(height: 24),
            const Text(
              'Bienvenue sur Ayanna School',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            AyannaButton(
              text: 'Voir les classes',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ClassesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
