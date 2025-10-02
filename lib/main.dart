import 'package:ayanna_school/services/app_preferences.dart';
import 'package:ayanna_school/services/auth_service.dart';
import 'package:ayanna_school/services/sync_manager.dart';
import 'package:ayanna_school/vues/eleves/add_eleve_screen.dart';
import 'package:ayanna_school/vues/gestions%20frais/paiement_frais.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'services/database_service.dart';
import 'theme/ayanna_theme.dart';
import 'vues/classes/auth_screen.dart';

void main() async {
  // 2. ADD THESE TWO LINES BEFORE runApp()
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', '');
  WidgetsFlutterBinding.ensureInitialized();
  final database = await DatabaseService.database;
  await AppPreferences().init();
  runApp(MainApp(database: database));
}

class MainApp extends StatelessWidget {
  final Database database;

  const MainApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Database>(create: (_) => database),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => SyncManager()),
      ],
      child: MaterialApp(
        title: 'Ayanna School',
        theme: ayannaTheme,
        routes: {
          '/paiement-frais': (context) => PaiementDesFrais(),
          '/add-eleve': (context) => AddEleveScreen(),
          '/home': (context) =>
              PaiementDesFrais(), // Route par défaut pour l'accueil
        },
        home: const AuthScreen(),
      ),
    );
  }
}
