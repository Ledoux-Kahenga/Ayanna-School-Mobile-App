import 'package:ayanna_school/models/dao/entreprise_dao.dart';
import 'package:ayanna_school/models/dao/notes_periode_dao.dart';
import 'package:ayanna_school/models/dao/utilisateur_dao.dart';
import 'package:ayanna_school/models/dao/annee_scolaire_dao.dart';
import 'package:ayanna_school/models/dao/enseignant_dao.dart';
import 'package:ayanna_school/models/dao/classe_dao.dart';
import 'package:ayanna_school/models/dao/eleve_dao.dart';
import 'package:ayanna_school/models/dao/responsable_dao.dart';
import 'package:ayanna_school/models/dao/cours_dao.dart';
import 'package:ayanna_school/models/dao/periode_dao.dart';
import 'package:ayanna_school/models/dao/frais_scolaire_dao.dart';
import 'package:ayanna_school/models/dao/paiement_frais_dao.dart';
import 'package:ayanna_school/models/dao/creance_dao.dart';
import 'package:ayanna_school/models/dao/classe_comptable_dao.dart';
import 'package:ayanna_school/models/dao/compte_comptable_dao.dart';
import 'package:ayanna_school/models/dao/journal_comptable_dao.dart';
import 'package:ayanna_school/models/dao/ecriture_comptable_dao.dart';
import 'package:ayanna_school/models/dao/depense_dao.dart';
import 'package:ayanna_school/models/dao/licence_dao.dart';
import 'package:ayanna_school/models/dao/config_ecole_dao.dart';
import 'package:ayanna_school/models/dao/comptes_config_dao.dart';
import 'package:ayanna_school/models/dao/periodes_classes_dao.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/app_database.dart';

part 'database_provider.g.dart';

/// Provider pour l'instance de la base de données Floor
///
late AppDatabase floorDb;
void initializeDatabase() async {
  floorDb = await AppDatabase.create();
}

@riverpod
AppDatabase database(DatabaseRef ref) {
  // Dispose de la base de données quand le provider n'est plus utilisé
  ref.onDispose(() async {
    await floorDb.close();
  });
  return floorDb;
}

/// Providers pour chaque DAO
@riverpod
EntrepriseDao entrepriseDao(EntrepriseDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.entrepriseDao;
}

@riverpod
UtilisateurDao utilisateurDao(UtilisateurDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.utilisateurDao;
}

@riverpod
AnneeScolaireDao anneeScolaireDao(AnneeScolaireDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.anneeScolaireDao;
}

@riverpod
EnseignantDao enseignantDao(EnseignantDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.enseignantDao;
}

@riverpod
ClasseDao classeDao(ClasseDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.classeDao;
}

@riverpod
EleveDao eleveDao(EleveDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.eleveDao;
}

@riverpod
ResponsableDao responsableDao(ResponsableDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.responsableDao;
}

@riverpod
CoursDao coursDao(CoursDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.coursDao;
}

@riverpod
NotePeriodeDao notePeriodeDao(NotePeriodeDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.notePeriodeDao;
}

@riverpod
PeriodeDao periodeDao(PeriodeDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.periodeDao;
}

@riverpod
FraisScolaireDao fraisScolaireDao(FraisScolaireDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.fraisScolaireDao;
}

@riverpod
PaiementFraisDao paiementFraisDao(PaiementFraisDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.paiementFraisDao;
}

@riverpod
CreanceDao creanceDao(CreanceDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.creanceDao;
}

@riverpod
ClasseComptableDao classeComptableDao(ClasseComptableDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.classeComptableDao;
}

@riverpod
CompteComptableDao compteComptableDao(CompteComptableDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.compteComptableDao;
}

@riverpod
JournalComptableDao journalComptableDao(JournalComptableDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.journalComptableDao;
}

@riverpod
EcritureComptableDao ecritureComptableDao(EcritureComptableDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.ecritureComptableDao;
}

@riverpod
DepenseDao depenseDao(DepenseDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.depenseDao;
}

@riverpod
LicenceDao licenceDao(LicenceDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.licenceDao;
}

@riverpod
ConfigEcoleDao configEcoleDao(ConfigEcoleDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.configEcoleDao;
}

@riverpod
ComptesConfigDao comptesConfigDao(ComptesConfigDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.comptesConfigDao;
}

@riverpod
PeriodesClassesDao periodesClassesDao(PeriodesClassesDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return db.periodesClassesDao;
}
