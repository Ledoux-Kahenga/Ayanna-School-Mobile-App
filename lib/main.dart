import 'package:ayanna_school/models/models.dart';
import 'package:ayanna_school/services/app_preferences.dart';
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

  Future<AnneeScolaire?> getDefaultYear() async {
    final result = await database.query(
      'annees_scolaires',
      where: 'en_cours = ?',
      whereArgs: [1],
    );
    if (result.isNotEmpty) {
      return AnneeScolaire.fromMap(result.first);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Provider<Database>(
      create: (_) => database,
      child: MaterialApp(
        title: 'Ayanna School',
        theme: ayannaTheme,
        routes: {
          '/paiement-frais': (context) => PaiementDesFrais(),
          '/add-eleve': (context) => AddEleveScreen()
        },
        home: FutureBuilder<AnneeScolaire?>(
          future: getDefaultYear(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return const Error();
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Error();
            } else {
              // Ajout du dialog de confirmation de sortie
              return const AuthScreen();
            }
          },
        ),
      ),
    );
  }
}

class Error extends StatelessWidget {
  const Error({super.key});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return Scaffold(
      backgroundColor: AyannaColors.lightGrey,
      body: FutureBuilder<AnneeScolaire?>(
        future: () async {
          final result = await database.query(
            'annees_scolaires',
            where: 'en_cours = ?',
            whereArgs: [0],
          );
          if (result.isNotEmpty) {
            return AnneeScolaire.fromMap(result.first);
          }
          return null;
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur: ${snapshot.error}',
                style: TextStyle(color: AyannaColors.darkGrey),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'Aucune année scolaire en cours',
                style: TextStyle(color: AyannaColors.darkGrey),
              ),
            );
          } else {
            final annee = snapshot.data!;
            return Text(
              'Année scolaire en cours: ${annee.nom}',
              style: TextStyle(color: AyannaColors.darkGrey),
            );
          }
        },
      ),
    );
  }
}
