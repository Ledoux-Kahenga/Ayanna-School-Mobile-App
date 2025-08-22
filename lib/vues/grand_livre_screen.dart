import 'package:flutter/material.dart';
import '../theme/ayanna_theme.dart';

class GrandLivreScreen extends StatelessWidget {
  const GrandLivreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AyannaColors.orange,
        foregroundColor: AyannaColors.white,
        title: const Text('Grand livre'),
        iconTheme: const IconThemeData(color: AyannaColors.white),
        elevation: 2,
      ),
      body: const Center(child: Text('Grand livre - à implémenter')),
    );
  }
}
