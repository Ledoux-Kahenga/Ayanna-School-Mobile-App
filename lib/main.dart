import 'package:ayanna_school/services/app_preferences.dart';
import 'package:ayanna_school/services/providers/connectivity_provider.dart';
import 'package:ayanna_school/services/providers/database_provider.dart';
import 'package:ayanna_school/vues/eleves/add_eleve_screen.dart';
import 'package:ayanna_school/vues/gestions%20frais/paiement_frais.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'theme/ayanna_theme.dart';
import 'vues/classes/auth_screen.dart';

void main() async {
  // Initialisation de Flutter et des services
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', '');

  // Initialisation de sqflite selon la plateforme
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    // Pour desktop (Linux/Windows/MacOS) - seulement si sqlite3 est disponible
    try {
      sqfliteFfiInit();
      sqflite.databaseFactory = databaseFactoryFfi;
      print('✅ Sqflite FFI initialisé pour desktop');
    } catch (e) {
      print('⚠️ Sqflite FFI non disponible, utilisation de sqflite normal: $e');
      // Ne pas définir databaseFactory, utiliser l'implémentation par défaut
    }
  }
  // Pour mobile (Android/iOS), sqflite utilise l'implémentation native automatiquement

  initializeDatabase();
  // Initialisation de la base de données et des préférences
  await AppPreferences().init();

  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(connectivityNotifierProvider.notifier).checkConnectivity();
    return MaterialApp(
      title: 'Ayanna School',
      theme: ayannaTheme,
      routes: {
        '/paiement-frais': (context) => PaiementDesFrais(),
        '/add-eleve': (context) => AddEleveScreen(),
        '/login': (context) => const AuthScreen(),
        '/home': (context) =>
            PaiementDesFrais(), // Route par défaut pour l'accueil
      },
      home: const AuthScreen(),
    );
  }
}
