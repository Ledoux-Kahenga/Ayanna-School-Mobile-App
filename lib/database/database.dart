// Imports
import 'dart:async';
import 'package:ayanna_school/controlleur/anneeScolaireDao.dart';
import 'package:ayanna_school/controlleur/classeDao.dart';
import 'package:ayanna_school/controlleur/eleveDao.dart';
import 'package:ayanna_school/controlleur/enseignantDao.dart';
import 'package:ayanna_school/controlleur/entrepriseDao.dart';
import 'package:ayanna_school/controlleur/fraisClasseDao.dart';
import 'package:ayanna_school/controlleur/fraisDao.dart';
import 'package:ayanna_school/controlleur/fraisScolaireDao.dart';
import 'package:ayanna_school/controlleur/paiementFraisDao.dart';
import 'package:ayanna_school/controlleur/responsableDao.dart';
import 'package:ayanna_school/controlleur/utilisateursDao.dart';
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
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

final migration2to3 = Migration(1, 2, (database) async {
  // Ajoutez les instructions SQL pour créer les tables manquantes
  // La table "fraisScolaires" n'existait pas, donc on la crée.
  // Vous devez écrire la requête CREATE TABLE en entier.
  await database.execute(
    'CREATE TABLE IF NOT EXISTS `frais_scolaires` ('
    '`id` INTEGER NOT NULL, '
    '`nom` TEXT NOT NULL, '
    '`montant` REAL NOT NULL, '
    '`annee_scolaire_id` INTEGER NOT NULL, '
    '`entreprise_id` INTEGER NOT NULL, '
    '`date_limite` TEXT, '
    'FOREIGN KEY(`annee_scolaire_id`) REFERENCES `annees_scolaires`(`id`) ON UPDATE NO ACTION ON DELETE CASCADE, '
    'FOREIGN KEY(`entreprise_id`) REFERENCES `entreprises`(`id`) ON UPDATE NO ACTION ON DELETE CASCADE, '
    'PRIMARY KEY(`id`)'
    ');'
  );
  // Ajoutez d'autres requêtes pour créer les autres tables manquantes si nécessaire
});

@Database(
  version: 1, // Incrémenter la version ici pour les migrations
  entities: [
    EntrepriseModel,
    ResponsableModel,
    FraisModel,
    UtilisateurModel,
    AnneeScolaireModel,
    EnseignantModel,
    FraisScolaireModel,
    ClassModel,
    EleveModel,
    FraisClassesModel,
    PaiementFraisModel,
  ],
)
abstract class MainDatabaseAppFloor extends FloorDatabase {
  EntreprisesDao get entreprisesDao;
  AnneeScolaireDao get anneeScolaireDao;
  FraisScolaireDao get fraisScolaireDao;
  EnseignantDao get enseignantDao;
  ClassesDao get classDaos;
  ResponsableDao get responsableDao;
  ElevesDao get elevesDao;
  FraisDao get fraisDao;
  FraisclasseDao get fraisclasseDao;
  UtilisateursDao get utilisateursDao;
  Paiementfraisdao get paiementFraisDao;
}