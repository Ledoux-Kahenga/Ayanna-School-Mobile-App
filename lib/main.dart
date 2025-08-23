import 'dart:convert';

import 'package:ayanna_school/database/database.dart';
import 'package:ayanna_school/models/anneeScolaire.dart';
import 'package:ayanna_school/models/classe.dart';
import 'package:ayanna_school/models/eleve.dart';
import 'package:ayanna_school/models/enseignant.dart';
import 'package:ayanna_school/models/entreprises.dart';
import 'package:ayanna_school/models/frais.dart';
import 'package:ayanna_school/models/fraisClasse.dart';
import 'package:ayanna_school/models/fraisScolaire.dart';
import 'package:ayanna_school/models/paiementFrais.dart';
import 'package:ayanna_school/models/responsable.dart';
import 'package:ayanna_school/models/utilisateurs.dart';
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
  await _insertionEntreprises(database);
  await _insertionResponsables(database);
  await _insertionFrais(database);
  await _insertionUtilisateurs(database);
  await _insertionAnneeScolaire(database);
  await _insertionEnseignants(database);
  await _insertionEleves(database);

  await _insertionClasse(database);

  await _insertionFraisScolaires(database);
  await _insertionFraisClasses(database);
  await _insertionPaiementsFrais(database);
  // EntrepriseModel,
  // ResponsableModel,
  // FraisModel,
  // UtilisateurModel,
  // AnneeScolaireModel,
  // EnseignantModel,
  // // FraisScolaireModel,
  // ClassModel,
  // EleveModel,
  // FraisClassesModel,
  // PaiementFraisModel,

  runApp(MainApp(database: database));
}

Future<void> _insertionAnneeScolaire(MainDatabaseAppFloor database) async {
  final jsonString = await rootBundle.loadString(
    'assets/annees_scolaires.json',
  );
  final List<dynamic> jsonList = json.decode(jsonString);
  final List<AnneeScolaireModel> donnees = jsonList
      .map((item) => AnneeScolaireModel.fromJson(item))
      .toList();

  try {
    await database.anneeScolaireDao.insertAll(donnees);
  } catch (e) {
    print("Erreur lors de l'insertion : $e");
  }
}

Future<void> _insertionEntreprises(MainDatabaseAppFloor database) async {
  final jsonString = await rootBundle.loadString('assets/entreprises.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  final List<EntrepriseModel> donnees = jsonList
      .map((item) => EntrepriseModel.fromJson(item))
      .toList();

  try {
    await database.entreprisesDao.insertAll(donnees);
  } catch (e) {
    print("Erreur lors de l'insertion : $e");
  }
}

Future<void> _insertionEnseignants(MainDatabaseAppFloor database) async {
  final jsonString = await rootBundle.loadString('assets/enseignants.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  final List<EnseignantModel> donnees = jsonList
      .map((item) => EnseignantModel.fromJson(item))
      .toList();

  try {
    await database.enseignantDao.insertAll(donnees);
  } catch (e) {
    print("Erreur lors de l'insertion : $e");
  }
}

Future<void> _insertionClasse(MainDatabaseAppFloor database) async {
  final jsonString = await rootBundle.loadString('assets/classes.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  final List<ClassModel> donnees = jsonList
      .map((item) => ClassModel.fromJson(item))
      .toList();

  try {
    await database.classDaos.insertAll(donnees);
  } catch (e) {
    print("Erreur lors de l'insertion : $e");
  }
}

Future<void> _insertionEleves(MainDatabaseAppFloor database) async {
  final jsonString = await rootBundle.loadString('assets/eleves.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  final List<EleveModel> donnees = jsonList
      .map((item) => EleveModel.fromJson(item))
      .toList();

  try {
    await database.elevesDao.insertAll(donnees);
  } catch (e) {
    print("Erreur lors de l'insertion : $e");
  }
}

Future<void> _insertionResponsables(MainDatabaseAppFloor database) async {
  final jsonString = await rootBundle.loadString('assets/responsables.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  final List<ResponsableModel> donnees = jsonList
      .map((item) => ResponsableModel.fromJson(item))
      .toList();

  try {
    await database.responsableDao.insertAll(donnees);
  } catch (e) {
    print("Erreur lors de l'insertion : $e");
  }
}

Future<void> _insertionFrais(MainDatabaseAppFloor database) async {
  final jsonString = await rootBundle.loadString('assets/frais.json');
  if (jsonString == null ||
      jsonString.trim() == '' ||
      jsonString.trim() == 'null') {
    print("Le fichier frais.json est vide ou null");
    return;
  }
  final dynamic decoded = json.decode(jsonString);
  if (decoded == null || decoded is! List) {
    print("Le contenu de frais.json n'est pas une liste valide");
    return;
  }
  final List<dynamic> jsonList = decoded;
  final List<FraisModel> donnees = jsonList
      .map((item) => FraisModel.fromJson(item))
      .toList();

  try {
    await database.fraisDao.insertAll(donnees);
  } catch (e) {
    print("Erreur lors de l'insertion : $e");
  }
}

Future<void> _insertionFraisScolaires(MainDatabaseAppFloor database) async {
  final jsonString = await rootBundle.loadString('assets/frais_scolaires.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  final List<FraisScolaireModel> donnees = jsonList
      .map((item) => FraisScolaireModel.fromJson(item))
      .toList();

  try {
    await database.fraisScolaireDao.insertAll(donnees);
  } catch (e) {
    print("Erreur lors de l'insertion : $e");
  }
}

Future<void> _insertionFraisClasses(MainDatabaseAppFloor database) async {
  final jsonString = await rootBundle.loadString('assets/frais_classes.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  final List<FraisClassesModel> donnees = jsonList
      .map((item) => FraisClassesModel.fromJson(item))
      .toList();

  try {
    await database.fraisclasseDao.insertAll(donnees);
  } catch (e) {
    print("Erreur lors de l'insertion : $e");
  }
}

Future<void> _insertionUtilisateurs(MainDatabaseAppFloor database) async {
  final jsonString = await rootBundle.loadString('assets/utilisateurs.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  final List<UtilisateurModel> donnees = jsonList
      .map((item) => UtilisateurModel.fromJson(item))
      .toList();

  try {
    await database.utilisateursDao.insertAll(donnees);
  } catch (e) {
    print("Erreur lors de l'insertion : $e");
  }
}

Future<void> _insertionPaiementsFrais(MainDatabaseAppFloor database) async {
  final jsonString = await rootBundle.loadString('assets/paiement_frais.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  final List<PaiementFraisModel> donnees = jsonList
      .map((item) => PaiementFraisModel.fromJson(item))
      .toList();

  try {
    await database.paiementFraisDao.insertAll(donnees);
  } catch (e) {
    print("Erreur lors de l'insertion : $e");
  }
}

class MainApp extends StatelessWidget {
  final MainDatabaseAppFloor database;
  const MainApp({super.key, required this.database});

  Future<AnneeScolaireModel?> getDefaultYear() {
    return database.anneeScolaireDao.getAnneescolaireEnCours();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<MainDatabaseAppFloor>(
      create: (_) => database,
      child: MaterialApp(
        title: 'Ayanna School',
        theme: ayannaTheme,
        home: FutureBuilder<AnneeScolaireModel?>(
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
    final database = Provider.of<MainDatabaseAppFloor>(context, listen: false);
    return Scaffold(
      backgroundColor: AyannaColors.lightGrey,
      body: FutureBuilder<AnneeScolaireModel?>(
        future: database.anneeScolaireDao.getAnneescolaireEnCours(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur: \\${snapshot.error}',
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
              'Année scolaire en cours: \\${annee.nom}',
              style: TextStyle(color: AyannaColors.darkGrey),
            );
          }
        },
      ),
    );
  }
}
