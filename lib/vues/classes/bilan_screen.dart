import 'package:flutter/material.dart';
import '../../theme/ayanna_theme.dart';

class BilanScreen extends StatelessWidget {
  const BilanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AyannaColors.orange,
        foregroundColor: AyannaColors.white,
        title: const Text('Bilan'),
        iconTheme: const IconThemeData(color: AyannaColors.white),
        elevation: 2,
      ),
      body: const Center(child: Text('Bilan - à implémenter')),
    );
  }
}
