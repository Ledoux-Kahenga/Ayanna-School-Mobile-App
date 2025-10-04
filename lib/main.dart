import 'package:ayanna_school/services/app_preferences.dart';
import 'package:ayanna_school/services/auth_service.dart';
import 'package:ayanna_school/services/providers/database_provider.dart';
import 'package:ayanna_school/services/sync_manager.dart';
import 'package:ayanna_school/vues/eleves/add_eleve_screen.dart';
import 'package:ayanna_school/vues/gestions%20frais/paiement_frais.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'services/database_service.dart';
import 'theme/ayanna_theme.dart';
import 'vues/classes/auth_screen.dart';

void main() async {
  // Initialisation de Flutter et des services
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', '');
   initializeDatabase();
  // Initialisation de la base de données et des préférences
  final database = await DatabaseService.database;
  await AppPreferences().init();

  runApp(ProviderScope(child: MainApp(database: database)));
}

class MainApp extends ConsumerWidget {
  final sqflite.Database database;

  const MainApp({super.key, required this.database});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Ayanna School',
      theme: ayannaTheme,
      routes: {
        '/paiement-frais': (context) => PaiementDesFrais(),
        '/add-eleve': (context) => AddEleveScreen(),
        '/home':
            (context) => PaiementDesFrais(), // Route par défaut pour l'accueil
      },
      home: const AuthScreen(),
    );
  }
}
