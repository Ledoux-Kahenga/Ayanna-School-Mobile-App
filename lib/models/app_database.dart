import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'entities/entreprise.dart';
import 'entities/utilisateur.dart';
import 'entities/annee_scolaire.dart';
import 'entities/enseignant.dart';
import 'entities/classe.dart';
import 'entities/eleve.dart';
import 'entities/responsable.dart';
import 'entities/classe_comptable.dart';
import 'entities/compte_comptable.dart';
import 'entities/licence.dart';
import 'entities/periode.dart';
import 'entities/frais_scolaire.dart';
import 'entities/frais_classes.dart';
import 'entities/cours.dart';
import 'entities/note_periode.dart';
import 'entities/paiement_frais.dart';
import 'entities/config_ecole.dart';
import 'entities/comptes_config.dart';
import 'entities/periodes_classes.dart';
import 'entities/journal_comptable.dart';
import 'entities/depense.dart';
import 'entities/ecriture_comptable.dart';
import 'entities/creance.dart';
import 'converters/datetime_converter.dart';

import 'dao/entreprise_dao.dart';
import 'dao/utilisateur_dao.dart';
import 'dao/annee_scolaire_dao.dart';
import 'dao/enseignant_dao.dart';
import 'dao/classe_dao.dart';
import 'dao/eleve_dao.dart';
import 'dao/responsable_dao.dart';
import 'dao/classe_comptable_dao.dart';
import 'dao/compte_comptable_dao.dart';
import 'dao/licence_dao.dart';
import 'dao/periode_dao.dart';
import 'dao/frais_scolaire_dao.dart';
import 'dao/frais_classes_dao.dart';
import 'dao/cours_dao.dart';
import 'dao/notes_periode_dao.dart';
import 'dao/paiement_frais_dao.dart';
import 'dao/config_ecole_dao.dart';
import 'dao/comptes_config_dao.dart';
import 'dao/periodes_classes_dao.dart';
import 'dao/journal_comptable_dao.dart';
import 'dao/depense_dao.dart';
import 'dao/ecriture_comptable_dao.dart';
import 'dao/creance_dao.dart';

part 'app_database.g.dart';

@TypeConverters([DateTimeConverter, DateTimeNullableConverter])
@Database(
  version: 4,
  entities: [
    Entreprise,
    Utilisateur,
    AnneeScolaire,
    Enseignant,
    Classe,
    Eleve,
    Responsable,
    ClasseComptable,
    CompteComptable,
    Licence,
    Periode,
    FraisScolaire,
    FraisClasses,
    Cours,
    NotePeriode,
    PaiementFrais,
    ConfigEcole,
    ComptesConfig,
    PeriodesClasses,
    JournalComptable,
    Depense,
    EcritureComptable,
    Creance,
  ],
)
abstract class AppDatabase extends FloorDatabase {
  EntrepriseDao get entrepriseDao;
  UtilisateurDao get utilisateurDao;
  AnneeScolaireDao get anneeScolaireDao;
  EnseignantDao get enseignantDao;
  ClasseDao get classeDao;
  EleveDao get eleveDao;
  ResponsableDao get responsableDao;
  ClasseComptableDao get classeComptableDao;
  CompteComptableDao get compteComptableDao;
  LicenceDao get licenceDao;
  PeriodeDao get periodeDao;
  FraisScolaireDao get fraisScolaireDao;
  FraisClassesDao get fraisClassesDao;
  CoursDao get coursDao;
  NotePeriodeDao get notePeriodeDao;
  PaiementFraisDao get paiementFraisDao;
  ConfigEcoleDao get configEcoleDao;
  ComptesConfigDao get comptesConfigDao;
  PeriodesClassesDao get periodesClassesDao;
  JournalComptableDao get journalComptableDao;
  DepenseDao get depenseDao;
  EcritureComptableDao get ecritureComptableDao;
  CreanceDao get creanceDao;

  static Future<AppDatabase> create() async {
    return await $FloorAppDatabase
        .databaseBuilder('ayanna_school_database.db')
        .addMigrations([])
        .build();
  }
}
