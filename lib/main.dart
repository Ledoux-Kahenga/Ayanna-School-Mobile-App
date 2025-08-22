import 'dart:convert';

import 'package:ayanna_school/database/database.dart';
import 'package:ayanna_school/models/anneeScolaire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/ayanna_theme.dart';
import 'vues/classes/auth_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorMainDatabaseAppFloor
      .databaseBuilder('ayanna_school_database.db')
      .build();
  await _insertionAnneeScolaire(database);

  runApp(MainApp(database: database));
}


Future<void> _insertionAnneeScolaire(MainDatabaseAppFloor database) async {
  final jsonString = await rootBundle.loadString('assets/annees_scolaires.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  final List<AnneeScolaireModel> donnees = jsonList.map((item) => AnneeScolaireModel.fromJson(item)).toList();

 try {
  await database.anneeScolaireDao.insertAll(donnees);
  } catch (e) {
    print("Erreur lors de l'insertion : $e");
  }
}

class MainApp extends StatelessWidget {
  final MainDatabaseAppFloor database;
  const MainApp({super.key, required this.database});
  
  Future<AnneeScolaireModel?> get defaultYear => database.anneeScolaireDao.getAnneescolaireEnCours();
  
  
  @override
  Widget build(BuildContext context) {
    return Provider<MainDatabaseAppFloor>(
      create: (_) => database,
      child: MaterialApp(
            title: 'Ayanna School',
            theme: ayannaTheme,
            home: defaultYear == 1
                ? AuthScreen()
                : Error(),
          ),
    );
  }
}

class Error extends StatelessWidget {

  const Error({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AyannaColors.lightGrey,
      body: Center(
        child: Text('Erreur : Année scolaire non trouvée',
          style: TextStyle(color: AyannaColors.darkGrey),
        ),
      ),
    );
  }
}

