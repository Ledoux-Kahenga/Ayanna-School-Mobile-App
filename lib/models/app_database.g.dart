// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  EntrepriseDao? _entrepriseDaoInstance;

  UtilisateurDao? _utilisateurDaoInstance;

  AnneeScolaireDao? _anneeScolaireDaoInstance;

  EnseignantDao? _enseignantDaoInstance;

  ClasseDao? _classeDaoInstance;

  EleveDao? _eleveDaoInstance;

  ResponsableDao? _responsableDaoInstance;

  ClasseComptableDao? _classeComptableDaoInstance;

  CompteComptableDao? _compteComptableDaoInstance;

  LicenceDao? _licenceDaoInstance;

  PeriodeDao? _periodeDaoInstance;

  FraisScolaireDao? _fraisScolaireDaoInstance;

  FraisClassesDao? _fraisClassesDaoInstance;

  CoursDao? _coursDaoInstance;

  NotePeriodeDao? _notePeriodeDaoInstance;

  PaiementFraisDao? _paiementFraisDaoInstance;

  ConfigEcoleDao? _configEcoleDaoInstance;

  ComptesConfigDao? _comptesConfigDaoInstance;

  PeriodesClassesDao? _periodesClassesDaoInstance;

  JournalComptableDao? _journalComptableDaoInstance;

  DepenseDao? _depenseDaoInstance;

  EcritureComptableDao? _ecritureComptableDaoInstance;

  CreanceDao? _creanceDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 4,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `entreprises` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `nom` TEXT NOT NULL, `adresse` TEXT, `numero_id` TEXT, `devise` TEXT, `telephone` TEXT, `email` TEXT, `logo` TEXT, `timezone` TEXT NOT NULL, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `utilisateurs` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `nom` TEXT NOT NULL, `prenom` TEXT NOT NULL, `email` TEXT NOT NULL, `mot_de_passe_hash` TEXT NOT NULL, `role` TEXT NOT NULL, `actif` INTEGER, `entreprise_id` INTEGER NOT NULL, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `annees_scolaires` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `nom` TEXT NOT NULL, `date_debut` INTEGER NOT NULL, `date_fin` INTEGER NOT NULL, `entreprise_id` INTEGER NOT NULL, `en_cours` INTEGER, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `enseignants` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `matricule` TEXT, `nom` TEXT NOT NULL, `prenom` TEXT NOT NULL, `sexe` TEXT, `niveau` TEXT, `discipline` TEXT, `email` TEXT, `telephone` TEXT, `entreprise_id` INTEGER NOT NULL, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `classes` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `code` TEXT, `nom` TEXT NOT NULL, `niveau` TEXT, `effectif` INTEGER, `annee_scolaire_id` INTEGER NOT NULL, `enseignant_id` INTEGER, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`annee_scolaire_id`) REFERENCES `annees_scolaires` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`enseignant_id`) REFERENCES `enseignants` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `eleves` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `nom` TEXT NOT NULL, `postnom` TEXT, `prenom` TEXT NOT NULL, `sexe` TEXT, `statut` TEXT, `date_naissance` INTEGER, `lieu_naissance` TEXT, `matricule` TEXT, `numero_permanent` TEXT, `classe_id` INTEGER, `responsable_id` INTEGER, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`classe_id`) REFERENCES `classes` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`responsable_id`) REFERENCES `responsables` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `responsables` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `nom` TEXT, `code` TEXT, `telephone` TEXT, `adresse` TEXT, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `classes_comptables` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `code` TEXT, `nom` TEXT NOT NULL, `libelle` TEXT NOT NULL, `type` TEXT NOT NULL, `entreprise_id` INTEGER NOT NULL, `actif` INTEGER, `document` TEXT, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `comptes_comptables` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `numero` TEXT NOT NULL, `nom` TEXT NOT NULL, `libelle` TEXT NOT NULL, `actif` INTEGER, `classe_comptable_id` INTEGER NOT NULL, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`classe_comptable_id`) REFERENCES `classes_comptables` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `licence` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `cle` TEXT NOT NULL, `type` TEXT NOT NULL, `date_activation` INTEGER NOT NULL, `date_expiration` INTEGER NOT NULL, `signature` TEXT NOT NULL, `active` INTEGER, `entreprise_id` INTEGER, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `periodes` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `code` TEXT, `nom` TEXT NOT NULL, `semestre` INTEGER NOT NULL, `poids` INTEGER, `date_debut` INTEGER, `date_fin` INTEGER, `annee_scolaire_id` INTEGER, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`annee_scolaire_id`) REFERENCES `annees_scolaires` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `frais_scolaires` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `nom` TEXT NOT NULL, `montant` REAL NOT NULL, `date_limite` INTEGER, `entreprise_id` INTEGER NOT NULL, `annee_scolaire_id` INTEGER NOT NULL, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`annee_scolaire_id`) REFERENCES `annees_scolaires` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `frais_classes` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `frais_id` INTEGER NOT NULL, `classe_id` INTEGER NOT NULL, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`frais_id`) REFERENCES `frais_scolaires` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`classe_id`) REFERENCES `classes` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `cours` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `code` TEXT, `nom` TEXT NOT NULL, `coefficient` INTEGER, `enseignant_id` INTEGER NOT NULL, `classe_id` INTEGER NOT NULL, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`enseignant_id`) REFERENCES `enseignants` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`classe_id`) REFERENCES `classes` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `notes_periode` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `eleve_id` INTEGER NOT NULL, `cours_id` INTEGER NOT NULL, `periode_id` INTEGER NOT NULL, `valeur` REAL, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`eleve_id`) REFERENCES `eleves` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`cours_id`) REFERENCES `cours` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`periode_id`) REFERENCES `periodes` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `paiement_frais` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `eleve_id` INTEGER NOT NULL, `frais_scolaire_id` INTEGER NOT NULL, `montant_paye` REAL NOT NULL, `date_paiement` INTEGER NOT NULL, `user_id` INTEGER, `reste_a_payer` REAL, `statut` TEXT, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`eleve_id`) REFERENCES `eleves` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`frais_scolaire_id`) REFERENCES `frais_scolaires` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`user_id`) REFERENCES `utilisateurs` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `config_ecole` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `entreprise_id` INTEGER NOT NULL, `annee_scolaire_en_cours_id` INTEGER, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`annee_scolaire_en_cours_id`) REFERENCES `annees_scolaires` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `comptes_config` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `entreprise_id` INTEGER NOT NULL, `compte_caisse_id` INTEGER NOT NULL, `compte_frais_id` INTEGER NOT NULL, `compte_client_id` INTEGER NOT NULL, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`compte_caisse_id`) REFERENCES `comptes_comptables` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`compte_frais_id`) REFERENCES `comptes_comptables` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`compte_client_id`) REFERENCES `comptes_comptables` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `periodes_classes` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `classe_id` INTEGER NOT NULL, `periode_id` INTEGER NOT NULL, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`classe_id`) REFERENCES `classes` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`periode_id`) REFERENCES `periodes` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `journaux_comptables` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `date_operation` INTEGER NOT NULL, `libelle` TEXT NOT NULL, `montant` REAL NOT NULL, `type_operation` TEXT NOT NULL, `paiement_frais_id` INTEGER, `entreprise_id` INTEGER NOT NULL, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`paiement_frais_id`) REFERENCES `paiement_frais` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `depenses` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `libelle` TEXT NOT NULL, `montant` REAL NOT NULL, `date_depense` INTEGER NOT NULL, `entreprise_id` INTEGER NOT NULL, `observation` TEXT, `journal_id` INTEGER, `user_id` INTEGER, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`journal_id`) REFERENCES `journaux_comptables` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`user_id`) REFERENCES `utilisateurs` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ecritures_comptables` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `journal_id` INTEGER NOT NULL, `compte_comptable_id` INTEGER NOT NULL, `debit` REAL, `credit` REAL, `ordre` INTEGER NOT NULL, `date_ecriture` INTEGER NOT NULL, `libelle` TEXT, `reference` TEXT, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`journal_id`) REFERENCES `journaux_comptables` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`compte_comptable_id`) REFERENCES `comptes_comptables` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `creances` (`id` INTEGER, `server_id` INTEGER, `is_sync` INTEGER NOT NULL, `eleve_id` INTEGER NOT NULL, `frais_scolaire_id` INTEGER NOT NULL, `montant` REAL NOT NULL, `date_echeance` INTEGER NOT NULL, `active` INTEGER, `date_creation` INTEGER NOT NULL, `date_modification` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, FOREIGN KEY (`eleve_id`) REFERENCES `eleves` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`frais_scolaire_id`) REFERENCES `frais_scolaires` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE UNIQUE INDEX `index_entreprises_server_id` ON `entreprises` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_utilisateurs_server_id` ON `utilisateurs` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_annees_scolaires_server_id` ON `annees_scolaires` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_enseignants_server_id` ON `enseignants` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_classes_server_id` ON `classes` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_eleves_server_id` ON `eleves` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_responsables_server_id` ON `responsables` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_classes_comptables_server_id` ON `classes_comptables` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_comptes_comptables_server_id` ON `comptes_comptables` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_licence_server_id` ON `licence` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_periodes_server_id` ON `periodes` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_frais_scolaires_server_id` ON `frais_scolaires` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_frais_classes_server_id` ON `frais_classes` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_cours_server_id` ON `cours` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_notes_periode_server_id` ON `notes_periode` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_paiement_frais_server_id` ON `paiement_frais` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_config_ecole_server_id` ON `config_ecole` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_comptes_config_server_id` ON `comptes_config` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_periodes_classes_server_id` ON `periodes_classes` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_journaux_comptables_server_id` ON `journaux_comptables` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_depenses_server_id` ON `depenses` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_ecritures_comptables_server_id` ON `ecritures_comptables` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_creances_server_id` ON `creances` (`server_id`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  EntrepriseDao get entrepriseDao {
    return _entrepriseDaoInstance ??= _$EntrepriseDao(database, changeListener);
  }

  @override
  UtilisateurDao get utilisateurDao {
    return _utilisateurDaoInstance ??=
        _$UtilisateurDao(database, changeListener);
  }

  @override
  AnneeScolaireDao get anneeScolaireDao {
    return _anneeScolaireDaoInstance ??=
        _$AnneeScolaireDao(database, changeListener);
  }

  @override
  EnseignantDao get enseignantDao {
    return _enseignantDaoInstance ??= _$EnseignantDao(database, changeListener);
  }

  @override
  ClasseDao get classeDao {
    return _classeDaoInstance ??= _$ClasseDao(database, changeListener);
  }

  @override
  EleveDao get eleveDao {
    return _eleveDaoInstance ??= _$EleveDao(database, changeListener);
  }

  @override
  ResponsableDao get responsableDao {
    return _responsableDaoInstance ??=
        _$ResponsableDao(database, changeListener);
  }

  @override
  ClasseComptableDao get classeComptableDao {
    return _classeComptableDaoInstance ??=
        _$ClasseComptableDao(database, changeListener);
  }

  @override
  CompteComptableDao get compteComptableDao {
    return _compteComptableDaoInstance ??=
        _$CompteComptableDao(database, changeListener);
  }

  @override
  LicenceDao get licenceDao {
    return _licenceDaoInstance ??= _$LicenceDao(database, changeListener);
  }

  @override
  PeriodeDao get periodeDao {
    return _periodeDaoInstance ??= _$PeriodeDao(database, changeListener);
  }

  @override
  FraisScolaireDao get fraisScolaireDao {
    return _fraisScolaireDaoInstance ??=
        _$FraisScolaireDao(database, changeListener);
  }

  @override
  FraisClassesDao get fraisClassesDao {
    return _fraisClassesDaoInstance ??=
        _$FraisClassesDao(database, changeListener);
  }

  @override
  CoursDao get coursDao {
    return _coursDaoInstance ??= _$CoursDao(database, changeListener);
  }

  @override
  NotePeriodeDao get notePeriodeDao {
    return _notePeriodeDaoInstance ??=
        _$NotePeriodeDao(database, changeListener);
  }

  @override
  PaiementFraisDao get paiementFraisDao {
    return _paiementFraisDaoInstance ??=
        _$PaiementFraisDao(database, changeListener);
  }

  @override
  ConfigEcoleDao get configEcoleDao {
    return _configEcoleDaoInstance ??=
        _$ConfigEcoleDao(database, changeListener);
  }

  @override
  ComptesConfigDao get comptesConfigDao {
    return _comptesConfigDaoInstance ??=
        _$ComptesConfigDao(database, changeListener);
  }

  @override
  PeriodesClassesDao get periodesClassesDao {
    return _periodesClassesDaoInstance ??=
        _$PeriodesClassesDao(database, changeListener);
  }

  @override
  JournalComptableDao get journalComptableDao {
    return _journalComptableDaoInstance ??=
        _$JournalComptableDao(database, changeListener);
  }

  @override
  DepenseDao get depenseDao {
    return _depenseDaoInstance ??= _$DepenseDao(database, changeListener);
  }

  @override
  EcritureComptableDao get ecritureComptableDao {
    return _ecritureComptableDaoInstance ??=
        _$EcritureComptableDao(database, changeListener);
  }

  @override
  CreanceDao get creanceDao {
    return _creanceDaoInstance ??= _$CreanceDao(database, changeListener);
  }
}

class _$EntrepriseDao extends EntrepriseDao {
  _$EntrepriseDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _entrepriseInsertionAdapter = InsertionAdapter(
            database,
            'entreprises',
            (Entreprise item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'adresse': item.adresse,
                  'numero_id': item.numeroId,
                  'devise': item.devise,
                  'telephone': item.telephone,
                  'email': item.email,
                  'logo': item.logo,
                  'timezone': item.timezone,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _entrepriseUpdateAdapter = UpdateAdapter(
            database,
            'entreprises',
            ['id'],
            (Entreprise item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'adresse': item.adresse,
                  'numero_id': item.numeroId,
                  'devise': item.devise,
                  'telephone': item.telephone,
                  'email': item.email,
                  'logo': item.logo,
                  'timezone': item.timezone,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _entrepriseDeletionAdapter = DeletionAdapter(
            database,
            'entreprises',
            ['id'],
            (Entreprise item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'adresse': item.adresse,
                  'numero_id': item.numeroId,
                  'devise': item.devise,
                  'telephone': item.telephone,
                  'email': item.email,
                  'logo': item.logo,
                  'timezone': item.timezone,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Entreprise> _entrepriseInsertionAdapter;

  final UpdateAdapter<Entreprise> _entrepriseUpdateAdapter;

  final DeletionAdapter<Entreprise> _entrepriseDeletionAdapter;

  @override
  Future<List<Entreprise>> getAllEntreprises() async {
    return _queryAdapter.queryList('SELECT * FROM entreprises',
        mapper: (Map<String, Object?> row) => Entreprise(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            adresse: row['adresse'] as String?,
            numeroId: row['numero_id'] as String?,
            devise: row['devise'] as String?,
            telephone: row['telephone'] as String?,
            email: row['email'] as String?,
            logo: row['logo'] as String?,
            timezone: row['timezone'] as String,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<Entreprise?> getEntrepriseById(int id) async {
    return _queryAdapter.query('SELECT * FROM entreprises WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Entreprise(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            adresse: row['adresse'] as String?,
            numeroId: row['numero_id'] as String?,
            devise: row['devise'] as String?,
            telephone: row['telephone'] as String?,
            email: row['email'] as String?,
            logo: row['logo'] as String?,
            timezone: row['timezone'] as String,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<Entreprise?> getEntrepriseByServerId(int serverId) async {
    return _queryAdapter.query('SELECT * FROM entreprises WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => Entreprise(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            adresse: row['adresse'] as String?,
            numeroId: row['numero_id'] as String?,
            devise: row['devise'] as String?,
            telephone: row['telephone'] as String?,
            email: row['email'] as String?,
            logo: row['logo'] as String?,
            timezone: row['timezone'] as String,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<List<Entreprise>> getUnsyncedEntreprises() async {
    return _queryAdapter.queryList(
        'SELECT * FROM entreprises WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => Entreprise(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            adresse: row['adresse'] as String?,
            numeroId: row['numero_id'] as String?,
            devise: row['devise'] as String?,
            telephone: row['telephone'] as String?,
            email: row['email'] as String?,
            logo: row['logo'] as String?,
            timezone: row['timezone'] as String,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteEntrepriseById(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM entreprises WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteAllEntreprises() async {
    await _queryAdapter.queryNoReturn('DELETE FROM entreprises');
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE entreprises SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE entreprises SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<int> insertEntreprise(Entreprise entreprise) {
    return _entrepriseInsertionAdapter.insertAndReturnId(
        entreprise, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertEntreprises(List<Entreprise> entreprises) {
    return _entrepriseInsertionAdapter.insertListAndReturnIds(
        entreprises, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateEntreprise(Entreprise entreprise) async {
    await _entrepriseUpdateAdapter.update(entreprise, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateEntreprises(List<Entreprise> entreprises) async {
    await _entrepriseUpdateAdapter.updateList(
        entreprises, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteEntreprise(Entreprise entreprise) async {
    await _entrepriseDeletionAdapter.delete(entreprise);
  }
}

class _$UtilisateurDao extends UtilisateurDao {
  _$UtilisateurDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _utilisateurInsertionAdapter = InsertionAdapter(
            database,
            'utilisateurs',
            (Utilisateur item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'prenom': item.prenom,
                  'email': item.email,
                  'mot_de_passe_hash': item.motDePasseHash,
                  'role': item.role,
                  'actif': item.actif == null ? null : (item.actif! ? 1 : 0),
                  'entreprise_id': item.entrepriseId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _utilisateurUpdateAdapter = UpdateAdapter(
            database,
            'utilisateurs',
            ['id'],
            (Utilisateur item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'prenom': item.prenom,
                  'email': item.email,
                  'mot_de_passe_hash': item.motDePasseHash,
                  'role': item.role,
                  'actif': item.actif == null ? null : (item.actif! ? 1 : 0),
                  'entreprise_id': item.entrepriseId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _utilisateurDeletionAdapter = DeletionAdapter(
            database,
            'utilisateurs',
            ['id'],
            (Utilisateur item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'prenom': item.prenom,
                  'email': item.email,
                  'mot_de_passe_hash': item.motDePasseHash,
                  'role': item.role,
                  'actif': item.actif == null ? null : (item.actif! ? 1 : 0),
                  'entreprise_id': item.entrepriseId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Utilisateur> _utilisateurInsertionAdapter;

  final UpdateAdapter<Utilisateur> _utilisateurUpdateAdapter;

  final DeletionAdapter<Utilisateur> _utilisateurDeletionAdapter;

  @override
  Future<List<Utilisateur>> getAllUtilisateurs() async {
    return _queryAdapter.queryList('SELECT * FROM utilisateurs',
        mapper: (Map<String, Object?> row) => Utilisateur(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            email: row['email'] as String,
            motDePasseHash: row['mot_de_passe_hash'] as String,
            role: row['role'] as String,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<Utilisateur?> loginLocalement(
    String email,
    String password,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM utilisateurs WHERE email = ?1 AND mot_de_passe_hash = ?2 limit 1',
        mapper: (Map<String, Object?> row) => Utilisateur(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, nom: row['nom'] as String, prenom: row['prenom'] as String, email: row['email'] as String, motDePasseHash: row['mot_de_passe_hash'] as String, role: row['role'] as String, actif: row['actif'] == null ? null : (row['actif'] as int) != 0, entrepriseId: row['entreprise_id'] as int, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [email, password]);
  }

  @override
  Future<Utilisateur?> getUtilisateurById(int id) async {
    return _queryAdapter.query('SELECT * FROM utilisateurs WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Utilisateur(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            email: row['email'] as String,
            motDePasseHash: row['mot_de_passe_hash'] as String,
            role: row['role'] as String,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<Utilisateur?> getUtilisateurByEmail(String email) async {
    return _queryAdapter.query('SELECT * FROM utilisateurs WHERE email = ?1',
        mapper: (Map<String, Object?> row) => Utilisateur(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            email: row['email'] as String,
            motDePasseHash: row['mot_de_passe_hash'] as String,
            role: row['role'] as String,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [email]);
  }

  @override
  Future<List<Utilisateur>> getUtilisateursByEntreprise(
      int entrepriseId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM utilisateurs WHERE entreprise_id = ?1',
        mapper: (Map<String, Object?> row) => Utilisateur(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            email: row['email'] as String,
            motDePasseHash: row['mot_de_passe_hash'] as String,
            role: row['role'] as String,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [entrepriseId]);
  }

  @override
  Future<List<Utilisateur>> getUnsyncedUtilisateurs() async {
    return _queryAdapter.queryList(
        'SELECT * FROM utilisateurs WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => Utilisateur(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            email: row['email'] as String,
            motDePasseHash: row['mot_de_passe_hash'] as String,
            role: row['role'] as String,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteAllUtilisateurs() async {
    await _queryAdapter.queryNoReturn('DELETE FROM utilisateurs');
  }

  @override
  Future<void> deleteUtilisateursByEntreprise(int entrepriseId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM utilisateurs WHERE entreprise_id = ?1',
        arguments: [entrepriseId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE utilisateurs SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE utilisateurs SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<int> insertUtilisateur(Utilisateur utilisateur) {
    return _utilisateurInsertionAdapter.insertAndReturnId(
        utilisateur, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertUtilisateurs(List<Utilisateur> utilisateurs) {
    return _utilisateurInsertionAdapter.insertListAndReturnIds(
        utilisateurs, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateUtilisateur(Utilisateur utilisateur) async {
    await _utilisateurUpdateAdapter.update(
        utilisateur, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateUtilisateurs(List<Utilisateur> utilisateurs) async {
    await _utilisateurUpdateAdapter.updateList(
        utilisateurs, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteUtilisateur(Utilisateur utilisateur) async {
    await _utilisateurDeletionAdapter.delete(utilisateur);
  }
}

class _$AnneeScolaireDao extends AnneeScolaireDao {
  _$AnneeScolaireDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _anneeScolaireInsertionAdapter = InsertionAdapter(
            database,
            'annees_scolaires',
            (AnneeScolaire item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'date_debut': _dateTimeConverter.encode(item.dateDebut),
                  'date_fin': _dateTimeConverter.encode(item.dateFin),
                  'entreprise_id': item.entrepriseId,
                  'en_cours': item.enCours,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _anneeScolaireUpdateAdapter = UpdateAdapter(
            database,
            'annees_scolaires',
            ['id'],
            (AnneeScolaire item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'date_debut': _dateTimeConverter.encode(item.dateDebut),
                  'date_fin': _dateTimeConverter.encode(item.dateFin),
                  'entreprise_id': item.entrepriseId,
                  'en_cours': item.enCours,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _anneeScolaireDeletionAdapter = DeletionAdapter(
            database,
            'annees_scolaires',
            ['id'],
            (AnneeScolaire item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'date_debut': _dateTimeConverter.encode(item.dateDebut),
                  'date_fin': _dateTimeConverter.encode(item.dateFin),
                  'entreprise_id': item.entrepriseId,
                  'en_cours': item.enCours,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AnneeScolaire> _anneeScolaireInsertionAdapter;

  final UpdateAdapter<AnneeScolaire> _anneeScolaireUpdateAdapter;

  final DeletionAdapter<AnneeScolaire> _anneeScolaireDeletionAdapter;

  @override
  Future<List<AnneeScolaire>> getAllAnneesScolaires() async {
    return _queryAdapter.queryList('SELECT * FROM annees_scolaires',
        mapper: (Map<String, Object?> row) => AnneeScolaire(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            dateDebut: _dateTimeConverter.decode(row['date_debut'] as int),
            dateFin: _dateTimeConverter.decode(row['date_fin'] as int),
            entrepriseId: row['entreprise_id'] as int,
            enCours: row['en_cours'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<AnneeScolaire?> getAnneeScolaireById(int id) async {
    return _queryAdapter.query('SELECT * FROM annees_scolaires WHERE id = ?1',
        mapper: (Map<String, Object?> row) => AnneeScolaire(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            dateDebut: _dateTimeConverter.decode(row['date_debut'] as int),
            dateFin: _dateTimeConverter.decode(row['date_fin'] as int),
            entrepriseId: row['entreprise_id'] as int,
            enCours: row['en_cours'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<AnneeScolaire?> getAnneeScolaireByServerId(int serverId) async {
    return _queryAdapter.query(
        'SELECT * FROM annees_scolaires WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => AnneeScolaire(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            dateDebut: _dateTimeConverter.decode(row['date_debut'] as int),
            dateFin: _dateTimeConverter.decode(row['date_fin'] as int),
            entrepriseId: row['entreprise_id'] as int,
            enCours: row['en_cours'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<List<AnneeScolaire>> getAnneesScolairesByEntreprise(
      int entrepriseId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM annees_scolaires WHERE entreprise_id = ?1',
        mapper: (Map<String, Object?> row) => AnneeScolaire(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            dateDebut: _dateTimeConverter.decode(row['date_debut'] as int),
            dateFin: _dateTimeConverter.decode(row['date_fin'] as int),
            entrepriseId: row['entreprise_id'] as int,
            enCours: row['en_cours'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [entrepriseId]);
  }

  @override
  Future<AnneeScolaire?> getAnneeScolaireEnCours(int entrepriseId) async {
    return _queryAdapter.query(
        'SELECT * FROM annees_scolaires WHERE en_cours = 1 AND entreprise_id = ?1',
        mapper: (Map<String, Object?> row) => AnneeScolaire(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, nom: row['nom'] as String, dateDebut: _dateTimeConverter.decode(row['date_debut'] as int), dateFin: _dateTimeConverter.decode(row['date_fin'] as int), entrepriseId: row['entreprise_id'] as int, enCours: row['en_cours'] as int?, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [entrepriseId]);
  }

  @override
  Future<List<AnneeScolaire>> getUnsyncedAnneesScolaires() async {
    return _queryAdapter.queryList(
        'SELECT * FROM annees_scolaires WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => AnneeScolaire(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            dateDebut: _dateTimeConverter.decode(row['date_debut'] as int),
            dateFin: _dateTimeConverter.decode(row['date_fin'] as int),
            entrepriseId: row['entreprise_id'] as int,
            enCours: row['en_cours'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteAllAnneesScolaires() async {
    await _queryAdapter.queryNoReturn('DELETE FROM annees_scolaires');
  }

  @override
  Future<void> deleteAnneesScolairesByEntreprise(int entrepriseId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM annees_scolaires WHERE entreprise_id = ?1',
        arguments: [entrepriseId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE annees_scolaires SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE annees_scolaires SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<void> resetAnneesEnCours(int entrepriseId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE annees_scolaires SET en_cours = 0 WHERE entreprise_id = ?1',
        arguments: [entrepriseId]);
  }

  @override
  Future<void> setAnneeScolaireEnCours(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE annees_scolaires SET en_cours = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<int> insertAnneeScolaire(AnneeScolaire anneeScolaire) {
    return _anneeScolaireInsertionAdapter.insertAndReturnId(
        anneeScolaire, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertAnneesScolaires(List<AnneeScolaire> anneesScolaires) {
    return _anneeScolaireInsertionAdapter.insertListAndReturnIds(
        anneesScolaires, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateAnneeScolaire(AnneeScolaire anneeScolaire) async {
    await _anneeScolaireUpdateAdapter.update(
        anneeScolaire, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAnneesScolaires(
      List<AnneeScolaire> anneesScolaires) async {
    await _anneeScolaireUpdateAdapter.updateList(
        anneesScolaires, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAnneeScolaire(AnneeScolaire anneeScolaire) async {
    await _anneeScolaireDeletionAdapter.delete(anneeScolaire);
  }
}

class _$EnseignantDao extends EnseignantDao {
  _$EnseignantDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _enseignantInsertionAdapter = InsertionAdapter(
            database,
            'enseignants',
            (Enseignant item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'matricule': item.matricule,
                  'nom': item.nom,
                  'prenom': item.prenom,
                  'sexe': item.sexe,
                  'niveau': item.niveau,
                  'discipline': item.discipline,
                  'email': item.email,
                  'telephone': item.telephone,
                  'entreprise_id': item.entrepriseId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _enseignantUpdateAdapter = UpdateAdapter(
            database,
            'enseignants',
            ['id'],
            (Enseignant item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'matricule': item.matricule,
                  'nom': item.nom,
                  'prenom': item.prenom,
                  'sexe': item.sexe,
                  'niveau': item.niveau,
                  'discipline': item.discipline,
                  'email': item.email,
                  'telephone': item.telephone,
                  'entreprise_id': item.entrepriseId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _enseignantDeletionAdapter = DeletionAdapter(
            database,
            'enseignants',
            ['id'],
            (Enseignant item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'matricule': item.matricule,
                  'nom': item.nom,
                  'prenom': item.prenom,
                  'sexe': item.sexe,
                  'niveau': item.niveau,
                  'discipline': item.discipline,
                  'email': item.email,
                  'telephone': item.telephone,
                  'entreprise_id': item.entrepriseId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Enseignant> _enseignantInsertionAdapter;

  final UpdateAdapter<Enseignant> _enseignantUpdateAdapter;

  final DeletionAdapter<Enseignant> _enseignantDeletionAdapter;

  @override
  Future<List<Enseignant>> getAllEnseignants() async {
    return _queryAdapter.queryList('SELECT * FROM enseignants',
        mapper: (Map<String, Object?> row) => Enseignant(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            matricule: row['matricule'] as String?,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            niveau: row['niveau'] as String?,
            discipline: row['discipline'] as String?,
            email: row['email'] as String?,
            telephone: row['telephone'] as String?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<Enseignant?> getEnseignantById(int id) async {
    return _queryAdapter.query('SELECT * FROM enseignants WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Enseignant(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            matricule: row['matricule'] as String?,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            niveau: row['niveau'] as String?,
            discipline: row['discipline'] as String?,
            email: row['email'] as String?,
            telephone: row['telephone'] as String?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<Enseignant?> getEnseignantByServerId(int serverId) async {
    return _queryAdapter.query('SELECT * FROM enseignants WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => Enseignant(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            matricule: row['matricule'] as String?,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            niveau: row['niveau'] as String?,
            discipline: row['discipline'] as String?,
            email: row['email'] as String?,
            telephone: row['telephone'] as String?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<Enseignant?> getEnseignantByMatricule(String matricule) async {
    return _queryAdapter.query('SELECT * FROM enseignants WHERE matricule = ?1',
        mapper: (Map<String, Object?> row) => Enseignant(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            matricule: row['matricule'] as String?,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            niveau: row['niveau'] as String?,
            discipline: row['discipline'] as String?,
            email: row['email'] as String?,
            telephone: row['telephone'] as String?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [matricule]);
  }

  @override
  Future<Enseignant?> getEnseignantByEmail(String email) async {
    return _queryAdapter.query('SELECT * FROM enseignants WHERE email = ?1',
        mapper: (Map<String, Object?> row) => Enseignant(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            matricule: row['matricule'] as String?,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            niveau: row['niveau'] as String?,
            discipline: row['discipline'] as String?,
            email: row['email'] as String?,
            telephone: row['telephone'] as String?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [email]);
  }

  @override
  Future<List<Enseignant>> getEnseignantsByEntreprise(int entrepriseId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM enseignants WHERE entreprise_id = ?1',
        mapper: (Map<String, Object?> row) => Enseignant(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            matricule: row['matricule'] as String?,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            niveau: row['niveau'] as String?,
            discipline: row['discipline'] as String?,
            email: row['email'] as String?,
            telephone: row['telephone'] as String?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [entrepriseId]);
  }

  @override
  Future<List<Enseignant>> getEnseignantsByDiscipline(
    String discipline,
    int entrepriseId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM enseignants WHERE discipline = ?1 AND entreprise_id = ?2',
        mapper: (Map<String, Object?> row) => Enseignant(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, matricule: row['matricule'] as String?, nom: row['nom'] as String, prenom: row['prenom'] as String, sexe: row['sexe'] as String?, niveau: row['niveau'] as String?, discipline: row['discipline'] as String?, email: row['email'] as String?, telephone: row['telephone'] as String?, entrepriseId: row['entreprise_id'] as int, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [discipline, entrepriseId]);
  }

  @override
  Future<List<Enseignant>> getEnseignantsByNiveau(
    String niveau,
    int entrepriseId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM enseignants WHERE niveau = ?1 AND entreprise_id = ?2',
        mapper: (Map<String, Object?> row) => Enseignant(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            matricule: row['matricule'] as String?,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            niveau: row['niveau'] as String?,
            discipline: row['discipline'] as String?,
            email: row['email'] as String?,
            telephone: row['telephone'] as String?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [niveau, entrepriseId]);
  }

  @override
  Future<List<Enseignant>> getEnseignantsBySexe(
    String sexe,
    int entrepriseId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM enseignants WHERE sexe = ?1 AND entreprise_id = ?2',
        mapper: (Map<String, Object?> row) => Enseignant(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            matricule: row['matricule'] as String?,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            niveau: row['niveau'] as String?,
            discipline: row['discipline'] as String?,
            email: row['email'] as String?,
            telephone: row['telephone'] as String?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [sexe, entrepriseId]);
  }

  @override
  Future<List<Enseignant>> searchEnseignants(String searchTerm) async {
    return _queryAdapter.queryList(
        'SELECT * FROM enseignants WHERE nom LIKE ?1 OR prenom LIKE ?1',
        mapper: (Map<String, Object?> row) => Enseignant(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            matricule: row['matricule'] as String?,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            niveau: row['niveau'] as String?,
            discipline: row['discipline'] as String?,
            email: row['email'] as String?,
            telephone: row['telephone'] as String?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [searchTerm]);
  }

  @override
  Future<List<Enseignant>> getUnsyncedEnseignants() async {
    return _queryAdapter.queryList(
        'SELECT * FROM enseignants WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => Enseignant(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            matricule: row['matricule'] as String?,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            niveau: row['niveau'] as String?,
            discipline: row['discipline'] as String?,
            email: row['email'] as String?,
            telephone: row['telephone'] as String?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteAllEnseignants() async {
    await _queryAdapter.queryNoReturn('DELETE FROM enseignants');
  }

  @override
  Future<void> deleteEnseignantsByEntreprise(int entrepriseId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM enseignants WHERE entreprise_id = ?1',
        arguments: [entrepriseId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE enseignants SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE enseignants SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<int> insertEnseignant(Enseignant enseignant) {
    return _enseignantInsertionAdapter.insertAndReturnId(
        enseignant, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertEnseignants(List<Enseignant> enseignants) {
    return _enseignantInsertionAdapter.insertListAndReturnIds(
        enseignants, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateEnseignant(Enseignant enseignant) async {
    await _enseignantUpdateAdapter.update(enseignant, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateEnseignants(List<Enseignant> enseignants) async {
    await _enseignantUpdateAdapter.updateList(
        enseignants, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteEnseignant(Enseignant enseignant) async {
    await _enseignantDeletionAdapter.delete(enseignant);
  }
}

class _$ClasseDao extends ClasseDao {
  _$ClasseDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _classeInsertionAdapter = InsertionAdapter(
            database,
            'classes',
            (Classe item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'code': item.code,
                  'nom': item.nom,
                  'niveau': item.niveau,
                  'effectif': item.effectif,
                  'annee_scolaire_id': item.anneeScolaireId,
                  'enseignant_id': item.enseignantId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _classeUpdateAdapter = UpdateAdapter(
            database,
            'classes',
            ['id'],
            (Classe item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'code': item.code,
                  'nom': item.nom,
                  'niveau': item.niveau,
                  'effectif': item.effectif,
                  'annee_scolaire_id': item.anneeScolaireId,
                  'enseignant_id': item.enseignantId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _classeDeletionAdapter = DeletionAdapter(
            database,
            'classes',
            ['id'],
            (Classe item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'code': item.code,
                  'nom': item.nom,
                  'niveau': item.niveau,
                  'effectif': item.effectif,
                  'annee_scolaire_id': item.anneeScolaireId,
                  'enseignant_id': item.enseignantId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Classe> _classeInsertionAdapter;

  final UpdateAdapter<Classe> _classeUpdateAdapter;

  final DeletionAdapter<Classe> _classeDeletionAdapter;

  @override
  Future<List<Classe>> getAllClasses() async {
    return _queryAdapter.queryList('SELECT * FROM classes',
        mapper: (Map<String, Object?> row) => Classe(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            niveau: row['niveau'] as String?,
            effectif: row['effectif'] as int?,
            anneeScolaireId: row['annee_scolaire_id'] as int,
            enseignantId: row['enseignant_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<Classe?> getClasseById(int id) async {
    return _queryAdapter.query('SELECT * FROM classes WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Classe(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            niveau: row['niveau'] as String?,
            effectif: row['effectif'] as int?,
            anneeScolaireId: row['annee_scolaire_id'] as int,
            enseignantId: row['enseignant_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<Classe?> getClasseByServerId(int serverId) async {
    return _queryAdapter.query('SELECT * FROM classes WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => Classe(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            niveau: row['niveau'] as String?,
            effectif: row['effectif'] as int?,
            anneeScolaireId: row['annee_scolaire_id'] as int,
            enseignantId: row['enseignant_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<Classe?> getClasseByCode(String code) async {
    return _queryAdapter.query('SELECT * FROM classes WHERE code = ?1',
        mapper: (Map<String, Object?> row) => Classe(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            niveau: row['niveau'] as String?,
            effectif: row['effectif'] as int?,
            anneeScolaireId: row['annee_scolaire_id'] as int,
            enseignantId: row['enseignant_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [code]);
  }

  @override
  Future<List<Classe>> getClassesByAnneeScolaire(int anneeScolaireId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM classes WHERE annee_scolaire_id = ?1',
        mapper: (Map<String, Object?> row) => Classe(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            niveau: row['niveau'] as String?,
            effectif: row['effectif'] as int?,
            anneeScolaireId: row['annee_scolaire_id'] as int,
            enseignantId: row['enseignant_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [anneeScolaireId]);
  }

  @override
  Future<List<Classe>> getClassesByEnseignant(int enseignantId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM classes WHERE enseignant_id = ?1',
        mapper: (Map<String, Object?> row) => Classe(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            niveau: row['niveau'] as String?,
            effectif: row['effectif'] as int?,
            anneeScolaireId: row['annee_scolaire_id'] as int,
            enseignantId: row['enseignant_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [enseignantId]);
  }

  @override
  Future<List<Classe>> getClassesByNiveau(
    String niveau,
    int anneeScolaireId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM classes WHERE niveau = ?1 AND annee_scolaire_id = ?2',
        mapper: (Map<String, Object?> row) => Classe(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            niveau: row['niveau'] as String?,
            effectif: row['effectif'] as int?,
            anneeScolaireId: row['annee_scolaire_id'] as int,
            enseignantId: row['enseignant_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [niveau, anneeScolaireId]);
  }

  @override
  Future<List<Classe>> getUnsyncedClasses() async {
    return _queryAdapter.queryList('SELECT * FROM classes WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => Classe(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            niveau: row['niveau'] as String?,
            effectif: row['effectif'] as int?,
            anneeScolaireId: row['annee_scolaire_id'] as int,
            enseignantId: row['enseignant_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteAllClasses() async {
    await _queryAdapter.queryNoReturn('DELETE FROM classes');
  }

  @override
  Future<void> deleteClassesByAnneeScolaire(int anneeScolaireId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM classes WHERE annee_scolaire_id = ?1',
        arguments: [anneeScolaireId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE classes SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE classes SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<void> updateEffectif(
    int id,
    int effectif,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE classes SET effectif = ?2 WHERE id = ?1',
        arguments: [id, effectif]);
  }

  @override
  Future<int> insertClasse(Classe classe) {
    return _classeInsertionAdapter.insertAndReturnId(
        classe, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertClasses(List<Classe> classes) {
    return _classeInsertionAdapter.insertListAndReturnIds(
        classes, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateClasse(Classe classe) async {
    await _classeUpdateAdapter.update(classe, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateClasses(List<Classe> classes) async {
    await _classeUpdateAdapter.updateList(classes, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteClasse(Classe classe) async {
    await _classeDeletionAdapter.delete(classe);
  }
}

class _$EleveDao extends EleveDao {
  _$EleveDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _eleveInsertionAdapter = InsertionAdapter(
            database,
            'eleves',
            (Eleve item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'postnom': item.postnom,
                  'prenom': item.prenom,
                  'sexe': item.sexe,
                  'statut': item.statut,
                  'date_naissance':
                      _dateTimeNullableConverter.encode(item.dateNaissance),
                  'lieu_naissance': item.lieuNaissance,
                  'matricule': item.matricule,
                  'numero_permanent': item.numeroPermanent,
                  'classe_id': item.classeId,
                  'responsable_id': item.responsableId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _eleveUpdateAdapter = UpdateAdapter(
            database,
            'eleves',
            ['id'],
            (Eleve item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'postnom': item.postnom,
                  'prenom': item.prenom,
                  'sexe': item.sexe,
                  'statut': item.statut,
                  'date_naissance':
                      _dateTimeNullableConverter.encode(item.dateNaissance),
                  'lieu_naissance': item.lieuNaissance,
                  'matricule': item.matricule,
                  'numero_permanent': item.numeroPermanent,
                  'classe_id': item.classeId,
                  'responsable_id': item.responsableId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _eleveDeletionAdapter = DeletionAdapter(
            database,
            'eleves',
            ['id'],
            (Eleve item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'postnom': item.postnom,
                  'prenom': item.prenom,
                  'sexe': item.sexe,
                  'statut': item.statut,
                  'date_naissance':
                      _dateTimeNullableConverter.encode(item.dateNaissance),
                  'lieu_naissance': item.lieuNaissance,
                  'matricule': item.matricule,
                  'numero_permanent': item.numeroPermanent,
                  'classe_id': item.classeId,
                  'responsable_id': item.responsableId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Eleve> _eleveInsertionAdapter;

  final UpdateAdapter<Eleve> _eleveUpdateAdapter;

  final DeletionAdapter<Eleve> _eleveDeletionAdapter;

  @override
  Future<List<Eleve>> getAllEleves() async {
    return _queryAdapter.queryList('SELECT * FROM eleves',
        mapper: (Map<String, Object?> row) => Eleve(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            postnom: row['postnom'] as String?,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            statut: row['statut'] as String?,
            dateNaissance: _dateTimeNullableConverter
                .decode(row['date_naissance'] as int?),
            lieuNaissance: row['lieu_naissance'] as String?,
            matricule: row['matricule'] as String?,
            numeroPermanent: row['numero_permanent'] as String?,
            classeId: row['classe_id'] as int?,
            responsableId: row['responsable_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<Eleve?> getEleveById(int id) async {
    return _queryAdapter.query('SELECT * FROM eleves WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Eleve(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            postnom: row['postnom'] as String?,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            statut: row['statut'] as String?,
            dateNaissance: _dateTimeNullableConverter
                .decode(row['date_naissance'] as int?),
            lieuNaissance: row['lieu_naissance'] as String?,
            matricule: row['matricule'] as String?,
            numeroPermanent: row['numero_permanent'] as String?,
            classeId: row['classe_id'] as int?,
            responsableId: row['responsable_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<Eleve?> getEleveByServerId(int serverId) async {
    return _queryAdapter.query('SELECT * FROM eleves WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => Eleve(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            postnom: row['postnom'] as String?,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            statut: row['statut'] as String?,
            dateNaissance: _dateTimeNullableConverter
                .decode(row['date_naissance'] as int?),
            lieuNaissance: row['lieu_naissance'] as String?,
            matricule: row['matricule'] as String?,
            numeroPermanent: row['numero_permanent'] as String?,
            classeId: row['classe_id'] as int?,
            responsableId: row['responsable_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<Eleve?> getEleveByMatricule(String matricule) async {
    return _queryAdapter.query('SELECT * FROM eleves WHERE matricule = ?1',
        mapper: (Map<String, Object?> row) => Eleve(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            postnom: row['postnom'] as String?,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            statut: row['statut'] as String?,
            dateNaissance: _dateTimeNullableConverter
                .decode(row['date_naissance'] as int?),
            lieuNaissance: row['lieu_naissance'] as String?,
            matricule: row['matricule'] as String?,
            numeroPermanent: row['numero_permanent'] as String?,
            classeId: row['classe_id'] as int?,
            responsableId: row['responsable_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [matricule]);
  }

  @override
  Future<Eleve?> getEleveByNumeroPermanent(String numeroPermanent) async {
    return _queryAdapter.query(
        'SELECT * FROM eleves WHERE numero_permanent = ?1',
        mapper: (Map<String, Object?> row) => Eleve(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            postnom: row['postnom'] as String?,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            statut: row['statut'] as String?,
            dateNaissance: _dateTimeNullableConverter
                .decode(row['date_naissance'] as int?),
            lieuNaissance: row['lieu_naissance'] as String?,
            matricule: row['matricule'] as String?,
            numeroPermanent: row['numero_permanent'] as String?,
            classeId: row['classe_id'] as int?,
            responsableId: row['responsable_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [numeroPermanent]);
  }

  @override
  Future<List<Eleve>> getElevesByClasse(int classeId) async {
    return _queryAdapter.queryList('SELECT * FROM eleves WHERE classe_id = ?1',
        mapper: (Map<String, Object?> row) => Eleve(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            postnom: row['postnom'] as String?,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            statut: row['statut'] as String?,
            dateNaissance: _dateTimeNullableConverter
                .decode(row['date_naissance'] as int?),
            lieuNaissance: row['lieu_naissance'] as String?,
            matricule: row['matricule'] as String?,
            numeroPermanent: row['numero_permanent'] as String?,
            classeId: row['classe_id'] as int?,
            responsableId: row['responsable_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [classeId]);
  }

  @override
  Future<List<Eleve>> getElevesByResponsable(int responsableId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM eleves WHERE responsable_id = ?1',
        mapper: (Map<String, Object?> row) => Eleve(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            postnom: row['postnom'] as String?,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            statut: row['statut'] as String?,
            dateNaissance: _dateTimeNullableConverter
                .decode(row['date_naissance'] as int?),
            lieuNaissance: row['lieu_naissance'] as String?,
            matricule: row['matricule'] as String?,
            numeroPermanent: row['numero_permanent'] as String?,
            classeId: row['classe_id'] as int?,
            responsableId: row['responsable_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [responsableId]);
  }

  @override
  Future<List<Eleve>> getElevesBySexeAndClasse(
    String sexe,
    int classeId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM eleves WHERE sexe = ?1 AND classe_id = ?2',
        mapper: (Map<String, Object?> row) => Eleve(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            postnom: row['postnom'] as String?,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            statut: row['statut'] as String?,
            dateNaissance: _dateTimeNullableConverter
                .decode(row['date_naissance'] as int?),
            lieuNaissance: row['lieu_naissance'] as String?,
            matricule: row['matricule'] as String?,
            numeroPermanent: row['numero_permanent'] as String?,
            classeId: row['classe_id'] as int?,
            responsableId: row['responsable_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [sexe, classeId]);
  }

  @override
  Future<List<Eleve>> getElevesByStatut(String statut) async {
    return _queryAdapter.queryList('SELECT * FROM eleves WHERE statut = ?1',
        mapper: (Map<String, Object?> row) => Eleve(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            postnom: row['postnom'] as String?,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            statut: row['statut'] as String?,
            dateNaissance: _dateTimeNullableConverter
                .decode(row['date_naissance'] as int?),
            lieuNaissance: row['lieu_naissance'] as String?,
            matricule: row['matricule'] as String?,
            numeroPermanent: row['numero_permanent'] as String?,
            classeId: row['classe_id'] as int?,
            responsableId: row['responsable_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [statut]);
  }

  @override
  Future<List<Eleve>> searchEleves(String searchTerm) async {
    return _queryAdapter.queryList(
        'SELECT * FROM eleves WHERE nom LIKE ?1 OR prenom LIKE ?1 OR postnom LIKE ?1',
        mapper: (Map<String, Object?> row) => Eleve(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, nom: row['nom'] as String, postnom: row['postnom'] as String?, prenom: row['prenom'] as String, sexe: row['sexe'] as String?, statut: row['statut'] as String?, dateNaissance: _dateTimeNullableConverter.decode(row['date_naissance'] as int?), lieuNaissance: row['lieu_naissance'] as String?, matricule: row['matricule'] as String?, numeroPermanent: row['numero_permanent'] as String?, classeId: row['classe_id'] as int?, responsableId: row['responsable_id'] as int?, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [searchTerm]);
  }

  @override
  Future<List<Eleve>> getUnsyncedEleves() async {
    return _queryAdapter.queryList('SELECT * FROM eleves WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => Eleve(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            postnom: row['postnom'] as String?,
            prenom: row['prenom'] as String,
            sexe: row['sexe'] as String?,
            statut: row['statut'] as String?,
            dateNaissance: _dateTimeNullableConverter
                .decode(row['date_naissance'] as int?),
            lieuNaissance: row['lieu_naissance'] as String?,
            matricule: row['matricule'] as String?,
            numeroPermanent: row['numero_permanent'] as String?,
            classeId: row['classe_id'] as int?,
            responsableId: row['responsable_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<int?> getEffectifByClasse(int classeId) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM eleves WHERE classe_id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [classeId]);
  }

  @override
  Future<int?> getEffectifBySexeAndClasse(
    String sexe,
    int classeId,
  ) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM eleves WHERE classe_id = ?2 AND sexe = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [sexe, classeId]);
  }

  @override
  Future<void> deleteAllEleves() async {
    await _queryAdapter.queryNoReturn('DELETE FROM eleves');
  }

  @override
  Future<void> deleteElevesByClasse(int classeId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM eleves WHERE classe_id = ?1',
        arguments: [classeId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE eleves SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE eleves SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<void> changerClasse(
    int eleveId,
    int nouvelleClasseId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE eleves SET classe_id = ?2 WHERE id = ?1',
        arguments: [eleveId, nouvelleClasseId]);
  }

  @override
  Future<void> changerStatut(
    int eleveId,
    String nouveauStatut,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE eleves SET statut = ?2 WHERE id = ?1',
        arguments: [eleveId, nouveauStatut]);
  }

  @override
  Future<int> insertEleve(Eleve eleve) {
    return _eleveInsertionAdapter.insertAndReturnId(
        eleve, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertEleves(List<Eleve> eleves) {
    return _eleveInsertionAdapter.insertListAndReturnIds(
        eleves, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateEleve(Eleve eleve) async {
    await _eleveUpdateAdapter.update(eleve, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateEleves(List<Eleve> eleves) async {
    await _eleveUpdateAdapter.updateList(eleves, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteEleve(Eleve eleve) async {
    await _eleveDeletionAdapter.delete(eleve);
  }
}

class _$ResponsableDao extends ResponsableDao {
  _$ResponsableDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _responsableInsertionAdapter = InsertionAdapter(
            database,
            'responsables',
            (Responsable item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'code': item.code,
                  'telephone': item.telephone,
                  'adresse': item.adresse,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _responsableUpdateAdapter = UpdateAdapter(
            database,
            'responsables',
            ['id'],
            (Responsable item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'code': item.code,
                  'telephone': item.telephone,
                  'adresse': item.adresse,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _responsableDeletionAdapter = DeletionAdapter(
            database,
            'responsables',
            ['id'],
            (Responsable item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'code': item.code,
                  'telephone': item.telephone,
                  'adresse': item.adresse,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Responsable> _responsableInsertionAdapter;

  final UpdateAdapter<Responsable> _responsableUpdateAdapter;

  final DeletionAdapter<Responsable> _responsableDeletionAdapter;

  @override
  Future<List<Responsable>> getAllResponsables() async {
    return _queryAdapter.queryList('SELECT * FROM responsables',
        mapper: (Map<String, Object?> row) => Responsable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String?,
            code: row['code'] as String?,
            telephone: row['telephone'] as String?,
            adresse: row['adresse'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<Responsable?> getResponsableById(int id) async {
    return _queryAdapter.query('SELECT * FROM responsables WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Responsable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String?,
            code: row['code'] as String?,
            telephone: row['telephone'] as String?,
            adresse: row['adresse'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<Responsable?> getResponsableByServerId(int serverId) async {
    return _queryAdapter.query(
        'SELECT * FROM responsables WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => Responsable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String?,
            code: row['code'] as String?,
            telephone: row['telephone'] as String?,
            adresse: row['adresse'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<List<Responsable>> searchResponsablesByName(String searchTerm) async {
    return _queryAdapter.queryList(
        'SELECT * FROM responsables WHERE nom LIKE ?1 OR prenom LIKE ?1',
        mapper: (Map<String, Object?> row) => Responsable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String?,
            code: row['code'] as String?,
            telephone: row['telephone'] as String?,
            adresse: row['adresse'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [searchTerm]);
  }

  @override
  Future<Responsable?> getResponsableByTelephone(String telephone) async {
    return _queryAdapter.query(
        'SELECT * FROM responsables WHERE telephone = ?1',
        mapper: (Map<String, Object?> row) => Responsable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String?,
            code: row['code'] as String?,
            telephone: row['telephone'] as String?,
            adresse: row['adresse'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [telephone]);
  }

  @override
  Future<Responsable?> getResponsableByEmail(String email) async {
    return _queryAdapter.query('SELECT * FROM responsables WHERE email = ?1',
        mapper: (Map<String, Object?> row) => Responsable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String?,
            code: row['code'] as String?,
            telephone: row['telephone'] as String?,
            adresse: row['adresse'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [email]);
  }

  @override
  Future<List<Responsable>> getResponsablesByType(
      String typeResponsable) async {
    return _queryAdapter.queryList(
        'SELECT * FROM responsables WHERE type_responsable = ?1',
        mapper: (Map<String, Object?> row) => Responsable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String?,
            code: row['code'] as String?,
            telephone: row['telephone'] as String?,
            adresse: row['adresse'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [typeResponsable]);
  }

  @override
  Future<List<Responsable>> getResponsablesByProfession(
      String profession) async {
    return _queryAdapter.queryList(
        'SELECT * FROM responsables WHERE profession = ?1',
        mapper: (Map<String, Object?> row) => Responsable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String?,
            code: row['code'] as String?,
            telephone: row['telephone'] as String?,
            adresse: row['adresse'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [profession]);
  }

  @override
  Future<List<Responsable>> getResponsablesByAdresse(String searchTerm) async {
    return _queryAdapter.queryList(
        'SELECT * FROM responsables WHERE adresse LIKE ?1',
        mapper: (Map<String, Object?> row) => Responsable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String?,
            code: row['code'] as String?,
            telephone: row['telephone'] as String?,
            adresse: row['adresse'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [searchTerm]);
  }

  @override
  Future<List<Responsable>> getResponsablesByNomPrenom(
    String nom,
    String prenom,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM responsables WHERE nom = ?1 AND prenom = ?2',
        mapper: (Map<String, Object?> row) => Responsable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String?,
            code: row['code'] as String?,
            telephone: row['telephone'] as String?,
            adresse: row['adresse'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [nom, prenom]);
  }

  @override
  Future<List<Responsable>> getUnsyncedResponsables() async {
    return _queryAdapter.queryList(
        'SELECT * FROM responsables WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => Responsable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String?,
            code: row['code'] as String?,
            telephone: row['telephone'] as String?,
            adresse: row['adresse'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteAllResponsables() async {
    await _queryAdapter.queryNoReturn('DELETE FROM responsables');
  }

  @override
  Future<void> deleteResponsablesByType(String typeResponsable) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM responsables WHERE type_responsable = ?1',
        arguments: [typeResponsable]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE responsables SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE responsables SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<void> updateTelephone(
    int id,
    String nouveauTelephone,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE responsables SET telephone = ?2 WHERE id = ?1',
        arguments: [id, nouveauTelephone]);
  }

  @override
  Future<void> updateEmail(
    int id,
    String nouveauEmail,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE responsables SET email = ?2 WHERE id = ?1',
        arguments: [id, nouveauEmail]);
  }

  @override
  Future<void> updateAdresse(
    int id,
    String nouvelleAdresse,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE responsables SET adresse = ?2 WHERE id = ?1',
        arguments: [id, nouvelleAdresse]);
  }

  @override
  Future<int> insertResponsable(Responsable responsable) {
    return _responsableInsertionAdapter.insertAndReturnId(
        responsable, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertResponsables(List<Responsable> responsables) {
    return _responsableInsertionAdapter.insertListAndReturnIds(
        responsables, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateResponsable(Responsable responsable) async {
    await _responsableUpdateAdapter.update(
        responsable, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateResponsables(List<Responsable> responsables) async {
    await _responsableUpdateAdapter.updateList(
        responsables, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteResponsable(Responsable responsable) async {
    await _responsableDeletionAdapter.delete(responsable);
  }
}

class _$ClasseComptableDao extends ClasseComptableDao {
  _$ClasseComptableDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _classeComptableInsertionAdapter = InsertionAdapter(
            database,
            'classes_comptables',
            (ClasseComptable item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'code': item.code,
                  'nom': item.nom,
                  'libelle': item.libelle,
                  'type': item.type,
                  'entreprise_id': item.entrepriseId,
                  'actif': item.actif == null ? null : (item.actif! ? 1 : 0),
                  'document': item.document,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _classeComptableUpdateAdapter = UpdateAdapter(
            database,
            'classes_comptables',
            ['id'],
            (ClasseComptable item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'code': item.code,
                  'nom': item.nom,
                  'libelle': item.libelle,
                  'type': item.type,
                  'entreprise_id': item.entrepriseId,
                  'actif': item.actif == null ? null : (item.actif! ? 1 : 0),
                  'document': item.document,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _classeComptableDeletionAdapter = DeletionAdapter(
            database,
            'classes_comptables',
            ['id'],
            (ClasseComptable item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'code': item.code,
                  'nom': item.nom,
                  'libelle': item.libelle,
                  'type': item.type,
                  'entreprise_id': item.entrepriseId,
                  'actif': item.actif == null ? null : (item.actif! ? 1 : 0),
                  'document': item.document,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ClasseComptable> _classeComptableInsertionAdapter;

  final UpdateAdapter<ClasseComptable> _classeComptableUpdateAdapter;

  final DeletionAdapter<ClasseComptable> _classeComptableDeletionAdapter;

  @override
  Future<List<ClasseComptable>> getAllClassesComptables() async {
    return _queryAdapter.queryList('SELECT * FROM classes_comptables',
        mapper: (Map<String, Object?> row) => ClasseComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            libelle: row['libelle'] as String,
            type: row['type'] as String,
            entrepriseId: row['entreprise_id'] as int,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            document: row['document'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<ClasseComptable?> getClasseComptableById(int id) async {
    return _queryAdapter.query('SELECT * FROM classes_comptables WHERE id = ?1',
        mapper: (Map<String, Object?> row) => ClasseComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            libelle: row['libelle'] as String,
            type: row['type'] as String,
            entrepriseId: row['entreprise_id'] as int,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            document: row['document'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<ClasseComptable?> getClasseComptableByServerId(int serverId) async {
    return _queryAdapter.query(
        'SELECT * FROM classes_comptables WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => ClasseComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            libelle: row['libelle'] as String,
            type: row['type'] as String,
            entrepriseId: row['entreprise_id'] as int,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            document: row['document'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<ClasseComptable?> getClasseComptableByCode(String code) async {
    return _queryAdapter.query(
        'SELECT * FROM classes_comptables WHERE code = ?1',
        mapper: (Map<String, Object?> row) => ClasseComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            libelle: row['libelle'] as String,
            type: row['type'] as String,
            entrepriseId: row['entreprise_id'] as int,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            document: row['document'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [code]);
  }

  @override
  Future<List<ClasseComptable>> getClassesComptablesByEntreprise(
      int entrepriseId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM classes_comptables WHERE entreprise_id = ?1',
        mapper: (Map<String, Object?> row) => ClasseComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            libelle: row['libelle'] as String,
            type: row['type'] as String,
            entrepriseId: row['entreprise_id'] as int,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            document: row['document'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [entrepriseId]);
  }

  @override
  Future<List<ClasseComptable>> getClassesComptablesByType(
    String type,
    int entrepriseId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM classes_comptables WHERE type = ?1 AND entreprise_id = ?2',
        mapper: (Map<String, Object?> row) => ClasseComptable(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, code: row['code'] as String?, nom: row['nom'] as String, libelle: row['libelle'] as String, type: row['type'] as String, entrepriseId: row['entreprise_id'] as int, actif: row['actif'] == null ? null : (row['actif'] as int) != 0, document: row['document'] as String?, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [type, entrepriseId]);
  }

  @override
  Future<List<ClasseComptable>> getClassesComptablesActives(
      int entrepriseId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM classes_comptables WHERE actif = 1 AND entreprise_id = ?1',
        mapper: (Map<String, Object?> row) => ClasseComptable(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, code: row['code'] as String?, nom: row['nom'] as String, libelle: row['libelle'] as String, type: row['type'] as String, entrepriseId: row['entreprise_id'] as int, actif: row['actif'] == null ? null : (row['actif'] as int) != 0, document: row['document'] as String?, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [entrepriseId]);
  }

  @override
  Future<List<ClasseComptable>> getUnsyncedClassesComptables() async {
    return _queryAdapter.queryList(
        'SELECT * FROM classes_comptables WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => ClasseComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            libelle: row['libelle'] as String,
            type: row['type'] as String,
            entrepriseId: row['entreprise_id'] as int,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            document: row['document'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteAllClassesComptables() async {
    await _queryAdapter.queryNoReturn('DELETE FROM classes_comptables');
  }

  @override
  Future<void> deleteClassesComptablesByEntreprise(int entrepriseId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM classes_comptables WHERE entreprise_id = ?1',
        arguments: [entrepriseId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE classes_comptables SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE classes_comptables SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<int> insertClasseComptable(ClasseComptable classeComptable) {
    return _classeComptableInsertionAdapter.insertAndReturnId(
        classeComptable, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertClassesComptables(
      List<ClasseComptable> classesComptables) {
    return _classeComptableInsertionAdapter.insertListAndReturnIds(
        classesComptables, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateClasseComptable(ClasseComptable classeComptable) async {
    await _classeComptableUpdateAdapter.update(
        classeComptable, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateClassesComptables(
      List<ClasseComptable> classesComptables) async {
    await _classeComptableUpdateAdapter.updateList(
        classesComptables, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteClasseComptable(ClasseComptable classeComptable) async {
    await _classeComptableDeletionAdapter.delete(classeComptable);
  }
}

class _$CompteComptableDao extends CompteComptableDao {
  _$CompteComptableDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _compteComptableInsertionAdapter = InsertionAdapter(
            database,
            'comptes_comptables',
            (CompteComptable item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'numero': item.numero,
                  'nom': item.nom,
                  'libelle': item.libelle,
                  'actif': item.actif == null ? null : (item.actif! ? 1 : 0),
                  'classe_comptable_id': item.classeComptableId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _compteComptableUpdateAdapter = UpdateAdapter(
            database,
            'comptes_comptables',
            ['id'],
            (CompteComptable item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'numero': item.numero,
                  'nom': item.nom,
                  'libelle': item.libelle,
                  'actif': item.actif == null ? null : (item.actif! ? 1 : 0),
                  'classe_comptable_id': item.classeComptableId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _compteComptableDeletionAdapter = DeletionAdapter(
            database,
            'comptes_comptables',
            ['id'],
            (CompteComptable item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'numero': item.numero,
                  'nom': item.nom,
                  'libelle': item.libelle,
                  'actif': item.actif == null ? null : (item.actif! ? 1 : 0),
                  'classe_comptable_id': item.classeComptableId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CompteComptable> _compteComptableInsertionAdapter;

  final UpdateAdapter<CompteComptable> _compteComptableUpdateAdapter;

  final DeletionAdapter<CompteComptable> _compteComptableDeletionAdapter;

  @override
  Future<List<CompteComptable>> getAllComptesComptables() async {
    return _queryAdapter.queryList('SELECT * FROM comptes_comptables',
        mapper: (Map<String, Object?> row) => CompteComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            numero: row['numero'] as String,
            nom: row['nom'] as String,
            libelle: row['libelle'] as String,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            classeComptableId: row['classe_comptable_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<CompteComptable?> getCompteComptableById(int id) async {
    return _queryAdapter.query('SELECT * FROM comptes_comptables WHERE id = ?1',
        mapper: (Map<String, Object?> row) => CompteComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            numero: row['numero'] as String,
            nom: row['nom'] as String,
            libelle: row['libelle'] as String,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            classeComptableId: row['classe_comptable_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<CompteComptable?> getCompteComptableByServerId(int serverId) async {
    return _queryAdapter.query(
        'SELECT * FROM comptes_comptables WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => CompteComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            numero: row['numero'] as String,
            nom: row['nom'] as String,
            libelle: row['libelle'] as String,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            classeComptableId: row['classe_comptable_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<CompteComptable?> getCompteComptableByNumero(String numero) async {
    return _queryAdapter.query(
        'SELECT * FROM comptes_comptables WHERE numero = ?1',
        mapper: (Map<String, Object?> row) => CompteComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            numero: row['numero'] as String,
            nom: row['nom'] as String,
            libelle: row['libelle'] as String,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            classeComptableId: row['classe_comptable_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [numero]);
  }

  @override
  Future<List<CompteComptable>> getComptesComptablesByClasse(
      int classeComptableId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM comptes_comptables WHERE classe_comptable_id = ?1',
        mapper: (Map<String, Object?> row) => CompteComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            numero: row['numero'] as String,
            nom: row['nom'] as String,
            libelle: row['libelle'] as String,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            classeComptableId: row['classe_comptable_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [classeComptableId]);
  }

  @override
  Future<List<CompteComptable>> getComptesComptablesActifs(
      int classeComptableId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM comptes_comptables WHERE actif = 1 AND classe_comptable_id = ?1',
        mapper: (Map<String, Object?> row) => CompteComptable(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, numero: row['numero'] as String, nom: row['nom'] as String, libelle: row['libelle'] as String, actif: row['actif'] == null ? null : (row['actif'] as int) != 0, classeComptableId: row['classe_comptable_id'] as int, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [classeComptableId]);
  }

  @override
  Future<List<CompteComptable>> getUnsyncedComptesComptables() async {
    return _queryAdapter.queryList(
        'SELECT * FROM comptes_comptables WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => CompteComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            numero: row['numero'] as String,
            nom: row['nom'] as String,
            libelle: row['libelle'] as String,
            actif: row['actif'] == null ? null : (row['actif'] as int) != 0,
            classeComptableId: row['classe_comptable_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteAllComptesComptables() async {
    await _queryAdapter.queryNoReturn('DELETE FROM comptes_comptables');
  }

  @override
  Future<void> deleteComptesComptablesByClasse(int classeComptableId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM comptes_comptables WHERE classe_comptable_id = ?1',
        arguments: [classeComptableId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE comptes_comptables SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE comptes_comptables SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<int> insertCompteComptable(CompteComptable compteComptable) {
    return _compteComptableInsertionAdapter.insertAndReturnId(
        compteComptable, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertComptesComptables(
      List<CompteComptable> comptesComptables) {
    return _compteComptableInsertionAdapter.insertListAndReturnIds(
        comptesComptables, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateCompteComptable(CompteComptable compteComptable) async {
    await _compteComptableUpdateAdapter.update(
        compteComptable, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateComptesComptables(
      List<CompteComptable> comptesComptables) async {
    await _compteComptableUpdateAdapter.updateList(
        comptesComptables, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCompteComptable(CompteComptable compteComptable) async {
    await _compteComptableDeletionAdapter.delete(compteComptable);
  }
}

class _$LicenceDao extends LicenceDao {
  _$LicenceDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _licenceInsertionAdapter = InsertionAdapter(
            database,
            'licence',
            (Licence item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'cle': item.cle,
                  'type': item.type,
                  'date_activation':
                      _dateTimeConverter.encode(item.dateActivation),
                  'date_expiration':
                      _dateTimeConverter.encode(item.dateExpiration),
                  'signature': item.signature,
                  'active': item.active == null ? null : (item.active! ? 1 : 0),
                  'entreprise_id': item.entrepriseId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _licenceUpdateAdapter = UpdateAdapter(
            database,
            'licence',
            ['id'],
            (Licence item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'cle': item.cle,
                  'type': item.type,
                  'date_activation':
                      _dateTimeConverter.encode(item.dateActivation),
                  'date_expiration':
                      _dateTimeConverter.encode(item.dateExpiration),
                  'signature': item.signature,
                  'active': item.active == null ? null : (item.active! ? 1 : 0),
                  'entreprise_id': item.entrepriseId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _licenceDeletionAdapter = DeletionAdapter(
            database,
            'licence',
            ['id'],
            (Licence item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'cle': item.cle,
                  'type': item.type,
                  'date_activation':
                      _dateTimeConverter.encode(item.dateActivation),
                  'date_expiration':
                      _dateTimeConverter.encode(item.dateExpiration),
                  'signature': item.signature,
                  'active': item.active == null ? null : (item.active! ? 1 : 0),
                  'entreprise_id': item.entrepriseId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Licence> _licenceInsertionAdapter;

  final UpdateAdapter<Licence> _licenceUpdateAdapter;

  final DeletionAdapter<Licence> _licenceDeletionAdapter;

  @override
  Future<List<Licence>> getAllLicences() async {
    return _queryAdapter.queryList('SELECT * FROM licence',
        mapper: (Map<String, Object?> row) => Licence(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            cle: row['cle'] as String,
            type: row['type'] as String,
            dateActivation:
                _dateTimeConverter.decode(row['date_activation'] as int),
            dateExpiration:
                _dateTimeConverter.decode(row['date_expiration'] as int),
            signature: row['signature'] as String,
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<Licence?> getLicenceById(int id) async {
    return _queryAdapter.query('SELECT * FROM licence WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Licence(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            cle: row['cle'] as String,
            type: row['type'] as String,
            dateActivation:
                _dateTimeConverter.decode(row['date_activation'] as int),
            dateExpiration:
                _dateTimeConverter.decode(row['date_expiration'] as int),
            signature: row['signature'] as String,
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<Licence?> getLicenceByServerId(int serverId) async {
    return _queryAdapter.query('SELECT * FROM licence WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => Licence(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            cle: row['cle'] as String,
            type: row['type'] as String,
            dateActivation:
                _dateTimeConverter.decode(row['date_activation'] as int),
            dateExpiration:
                _dateTimeConverter.decode(row['date_expiration'] as int),
            signature: row['signature'] as String,
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<Licence?> getLicenceByCle(String cle) async {
    return _queryAdapter.query('SELECT * FROM licence WHERE cle = ?1',
        mapper: (Map<String, Object?> row) => Licence(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            cle: row['cle'] as String,
            type: row['type'] as String,
            dateActivation:
                _dateTimeConverter.decode(row['date_activation'] as int),
            dateExpiration:
                _dateTimeConverter.decode(row['date_expiration'] as int),
            signature: row['signature'] as String,
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [cle]);
  }

  @override
  Future<List<Licence>> getLicencesByEntreprise(int entrepriseId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM licence WHERE entreprise_id = ?1',
        mapper: (Map<String, Object?> row) => Licence(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            cle: row['cle'] as String,
            type: row['type'] as String,
            dateActivation:
                _dateTimeConverter.decode(row['date_activation'] as int),
            dateExpiration:
                _dateTimeConverter.decode(row['date_expiration'] as int),
            signature: row['signature'] as String,
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [entrepriseId]);
  }

  @override
  Future<List<Licence>> getLicencesByType(
    String type,
    int entrepriseId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM licence WHERE type = ?1 AND entreprise_id = ?2',
        mapper: (Map<String, Object?> row) => Licence(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            cle: row['cle'] as String,
            type: row['type'] as String,
            dateActivation:
                _dateTimeConverter.decode(row['date_activation'] as int),
            dateExpiration:
                _dateTimeConverter.decode(row['date_expiration'] as int),
            signature: row['signature'] as String,
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [type, entrepriseId]);
  }

  @override
  Future<List<Licence>> getLicencesActives(int entrepriseId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM licence WHERE active = 1 AND entreprise_id = ?1',
        mapper: (Map<String, Object?> row) => Licence(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            cle: row['cle'] as String,
            type: row['type'] as String,
            dateActivation:
                _dateTimeConverter.decode(row['date_activation'] as int),
            dateExpiration:
                _dateTimeConverter.decode(row['date_expiration'] as int),
            signature: row['signature'] as String,
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [entrepriseId]);
  }

  @override
  Future<List<Licence>> getLicencesValides(DateTime date) async {
    return _queryAdapter.queryList(
        'SELECT * FROM licence WHERE date_expiration > ?1 AND active = 1',
        mapper: (Map<String, Object?> row) => Licence(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            cle: row['cle'] as String,
            type: row['type'] as String,
            dateActivation:
                _dateTimeConverter.decode(row['date_activation'] as int),
            dateExpiration:
                _dateTimeConverter.decode(row['date_expiration'] as int),
            signature: row['signature'] as String,
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [_dateTimeConverter.encode(date)]);
  }

  @override
  Future<List<Licence>> getLicencesExpirees(DateTime date) async {
    return _queryAdapter.queryList(
        'SELECT * FROM licence WHERE date_expiration <= ?1 AND active = 1',
        mapper: (Map<String, Object?> row) => Licence(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            cle: row['cle'] as String,
            type: row['type'] as String,
            dateActivation:
                _dateTimeConverter.decode(row['date_activation'] as int),
            dateExpiration:
                _dateTimeConverter.decode(row['date_expiration'] as int),
            signature: row['signature'] as String,
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [_dateTimeConverter.encode(date)]);
  }

  @override
  Future<List<Licence>> getUnsyncedLicences() async {
    return _queryAdapter.queryList('SELECT * FROM licence WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => Licence(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            cle: row['cle'] as String,
            type: row['type'] as String,
            dateActivation:
                _dateTimeConverter.decode(row['date_activation'] as int),
            dateExpiration:
                _dateTimeConverter.decode(row['date_expiration'] as int),
            signature: row['signature'] as String,
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteAllLicences() async {
    await _queryAdapter.queryNoReturn('DELETE FROM licence');
  }

  @override
  Future<void> deleteLicencesByEntreprise(int entrepriseId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM licence WHERE entreprise_id = ?1',
        arguments: [entrepriseId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE licence SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE licence SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<void> desactiverLicence(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE licence SET active = 0 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> activerLicence(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE licence SET active = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<int> insertLicence(Licence licence) {
    return _licenceInsertionAdapter.insertAndReturnId(
        licence, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertLicences(List<Licence> licences) {
    return _licenceInsertionAdapter.insertListAndReturnIds(
        licences, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateLicence(Licence licence) async {
    await _licenceUpdateAdapter.update(licence, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateLicences(List<Licence> licences) async {
    await _licenceUpdateAdapter.updateList(licences, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteLicence(Licence licence) async {
    await _licenceDeletionAdapter.delete(licence);
  }
}

class _$PeriodeDao extends PeriodeDao {
  _$PeriodeDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _periodeInsertionAdapter = InsertionAdapter(
            database,
            'periodes',
            (Periode item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'code': item.code,
                  'nom': item.nom,
                  'semestre': item.semestre,
                  'poids': item.poids,
                  'date_debut':
                      _dateTimeNullableConverter.encode(item.dateDebut),
                  'date_fin': _dateTimeNullableConverter.encode(item.dateFin),
                  'annee_scolaire_id': item.anneeScolaireId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _periodeUpdateAdapter = UpdateAdapter(
            database,
            'periodes',
            ['id'],
            (Periode item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'code': item.code,
                  'nom': item.nom,
                  'semestre': item.semestre,
                  'poids': item.poids,
                  'date_debut':
                      _dateTimeNullableConverter.encode(item.dateDebut),
                  'date_fin': _dateTimeNullableConverter.encode(item.dateFin),
                  'annee_scolaire_id': item.anneeScolaireId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _periodeDeletionAdapter = DeletionAdapter(
            database,
            'periodes',
            ['id'],
            (Periode item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'code': item.code,
                  'nom': item.nom,
                  'semestre': item.semestre,
                  'poids': item.poids,
                  'date_debut':
                      _dateTimeNullableConverter.encode(item.dateDebut),
                  'date_fin': _dateTimeNullableConverter.encode(item.dateFin),
                  'annee_scolaire_id': item.anneeScolaireId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Periode> _periodeInsertionAdapter;

  final UpdateAdapter<Periode> _periodeUpdateAdapter;

  final DeletionAdapter<Periode> _periodeDeletionAdapter;

  @override
  Future<List<Periode>> getAllPeriodes() async {
    return _queryAdapter.queryList('SELECT * FROM periodes',
        mapper: (Map<String, Object?> row) => Periode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            semestre: row['semestre'] as int,
            poids: row['poids'] as int?,
            dateDebut:
                _dateTimeNullableConverter.decode(row['date_debut'] as int?),
            dateFin: _dateTimeNullableConverter.decode(row['date_fin'] as int?),
            anneeScolaireId: row['annee_scolaire_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<Periode?> getPeriodeById(int id) async {
    return _queryAdapter.query('SELECT * FROM periodes WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Periode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            semestre: row['semestre'] as int,
            poids: row['poids'] as int?,
            dateDebut:
                _dateTimeNullableConverter.decode(row['date_debut'] as int?),
            dateFin: _dateTimeNullableConverter.decode(row['date_fin'] as int?),
            anneeScolaireId: row['annee_scolaire_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<Periode?> getPeriodeByServerId(int serverId) async {
    return _queryAdapter.query('SELECT * FROM periodes WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => Periode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            semestre: row['semestre'] as int,
            poids: row['poids'] as int?,
            dateDebut:
                _dateTimeNullableConverter.decode(row['date_debut'] as int?),
            dateFin: _dateTimeNullableConverter.decode(row['date_fin'] as int?),
            anneeScolaireId: row['annee_scolaire_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<Periode?> getPeriodeByNomAndAnnee(
    String nom,
    int anneeScolaireId,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM periodes WHERE nom = ?1 AND annee_scolaire_id = ?2',
        mapper: (Map<String, Object?> row) => Periode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            semestre: row['semestre'] as int,
            poids: row['poids'] as int?,
            dateDebut:
                _dateTimeNullableConverter.decode(row['date_debut'] as int?),
            dateFin: _dateTimeNullableConverter.decode(row['date_fin'] as int?),
            anneeScolaireId: row['annee_scolaire_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [nom, anneeScolaireId]);
  }

  @override
  Future<List<Periode>> getPeriodesByAnnee(int anneeScolaireId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM periodes WHERE annee_scolaire_id = ?1',
        mapper: (Map<String, Object?> row) => Periode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            semestre: row['semestre'] as int,
            poids: row['poids'] as int?,
            dateDebut:
                _dateTimeNullableConverter.decode(row['date_debut'] as int?),
            dateFin: _dateTimeNullableConverter.decode(row['date_fin'] as int?),
            anneeScolaireId: row['annee_scolaire_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [anneeScolaireId]);
  }

  @override
  Future<List<Periode>> getPeriodesByAnneeOrdered(int anneeScolaireId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM periodes WHERE annee_scolaire_id = ?1 ORDER BY numero ASC',
        mapper: (Map<String, Object?> row) => Periode(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, code: row['code'] as String?, nom: row['nom'] as String, semestre: row['semestre'] as int, poids: row['poids'] as int?, dateDebut: _dateTimeNullableConverter.decode(row['date_debut'] as int?), dateFin: _dateTimeNullableConverter.decode(row['date_fin'] as int?), anneeScolaireId: row['annee_scolaire_id'] as int?, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [anneeScolaireId]);
  }

  @override
  Future<Periode?> getPeriodeByNumero(
    int numero,
    int anneeScolaireId,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM periodes WHERE numero = ?1 AND annee_scolaire_id = ?2',
        mapper: (Map<String, Object?> row) => Periode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            semestre: row['semestre'] as int,
            poids: row['poids'] as int?,
            dateDebut:
                _dateTimeNullableConverter.decode(row['date_debut'] as int?),
            dateFin: _dateTimeNullableConverter.decode(row['date_fin'] as int?),
            anneeScolaireId: row['annee_scolaire_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [numero, anneeScolaireId]);
  }

  @override
  Future<List<Periode>> getPeriodesByDate(DateTime date) async {
    return _queryAdapter.queryList(
        'SELECT * FROM periodes WHERE date_debut <= ?1 AND date_fin >= ?1',
        mapper: (Map<String, Object?> row) => Periode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            semestre: row['semestre'] as int,
            poids: row['poids'] as int?,
            dateDebut:
                _dateTimeNullableConverter.decode(row['date_debut'] as int?),
            dateFin: _dateTimeNullableConverter.decode(row['date_fin'] as int?),
            anneeScolaireId: row['annee_scolaire_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [_dateTimeConverter.encode(date)]);
  }

  @override
  Future<List<Periode>> getPeriodesInDateRange(
    DateTime dateDebut,
    DateTime dateFin,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM periodes WHERE date_debut >= ?1 AND date_fin <= ?2',
        mapper: (Map<String, Object?> row) => Periode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            semestre: row['semestre'] as int,
            poids: row['poids'] as int?,
            dateDebut:
                _dateTimeNullableConverter.decode(row['date_debut'] as int?),
            dateFin: _dateTimeNullableConverter.decode(row['date_fin'] as int?),
            anneeScolaireId: row['annee_scolaire_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [
          _dateTimeConverter.encode(dateDebut),
          _dateTimeConverter.encode(dateFin)
        ]);
  }

  @override
  Future<List<Periode>> getPeriodesActives() async {
    return _queryAdapter.queryList('SELECT * FROM periodes WHERE is_active = 1',
        mapper: (Map<String, Object?> row) => Periode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            semestre: row['semestre'] as int,
            poids: row['poids'] as int?,
            dateDebut:
                _dateTimeNullableConverter.decode(row['date_debut'] as int?),
            dateFin: _dateTimeNullableConverter.decode(row['date_fin'] as int?),
            anneeScolaireId: row['annee_scolaire_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<List<Periode>> getPeriodesActivesByAnnee(int anneeScolaireId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM periodes WHERE is_active = 1 AND annee_scolaire_id = ?1',
        mapper: (Map<String, Object?> row) => Periode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            semestre: row['semestre'] as int,
            poids: row['poids'] as int?,
            dateDebut:
                _dateTimeNullableConverter.decode(row['date_debut'] as int?),
            dateFin: _dateTimeNullableConverter.decode(row['date_fin'] as int?),
            anneeScolaireId: row['annee_scolaire_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [anneeScolaireId]);
  }

  @override
  Future<Periode?> getPeriodeActuelle(DateTime currentDate) async {
    return _queryAdapter.query(
        'SELECT * FROM periodes WHERE date_debut <= ?1 AND date_fin >= ?1 AND is_active = 1',
        mapper: (Map<String, Object?> row) => Periode(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, code: row['code'] as String?, nom: row['nom'] as String, semestre: row['semestre'] as int, poids: row['poids'] as int?, dateDebut: _dateTimeNullableConverter.decode(row['date_debut'] as int?), dateFin: _dateTimeNullableConverter.decode(row['date_fin'] as int?), anneeScolaireId: row['annee_scolaire_id'] as int?, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [_dateTimeConverter.encode(currentDate)]);
  }

  @override
  Future<List<Periode>> getUnsyncedPeriodes() async {
    return _queryAdapter.queryList('SELECT * FROM periodes WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => Periode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            semestre: row['semestre'] as int,
            poids: row['poids'] as int?,
            dateDebut:
                _dateTimeNullableConverter.decode(row['date_debut'] as int?),
            dateFin: _dateTimeNullableConverter.decode(row['date_fin'] as int?),
            anneeScolaireId: row['annee_scolaire_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteAllPeriodes() async {
    await _queryAdapter.queryNoReturn('DELETE FROM periodes');
  }

  @override
  Future<void> deletePeriodesByAnnee(int anneeScolaireId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM periodes WHERE annee_scolaire_id = ?1',
        arguments: [anneeScolaireId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE periodes SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE periodes SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<void> desactiverPeriode(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE periodes SET is_active = 0 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> activerPeriode(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE periodes SET is_active = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> desactiverToutesPeriodesAnnee(int anneeScolaireId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE periodes SET is_active = 0 WHERE annee_scolaire_id = ?1',
        arguments: [anneeScolaireId]);
  }

  @override
  Future<int> insertPeriode(Periode periode) {
    return _periodeInsertionAdapter.insertAndReturnId(
        periode, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertPeriodes(List<Periode> periodes) {
    return _periodeInsertionAdapter.insertListAndReturnIds(
        periodes, OnConflictStrategy.replace);
  }

  @override
  Future<void> updatePeriode(Periode periode) async {
    await _periodeUpdateAdapter.update(periode, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePeriodes(List<Periode> periodes) async {
    await _periodeUpdateAdapter.updateList(periodes, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePeriode(Periode periode) async {
    await _periodeDeletionAdapter.delete(periode);
  }
}

class _$FraisScolaireDao extends FraisScolaireDao {
  _$FraisScolaireDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _fraisScolaireInsertionAdapter = InsertionAdapter(
            database,
            'frais_scolaires',
            (FraisScolaire item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'montant': item.montant,
                  'date_limite':
                      _dateTimeNullableConverter.encode(item.dateLimite),
                  'entreprise_id': item.entrepriseId,
                  'annee_scolaire_id': item.anneeScolaireId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _fraisScolaireUpdateAdapter = UpdateAdapter(
            database,
            'frais_scolaires',
            ['id'],
            (FraisScolaire item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'montant': item.montant,
                  'date_limite':
                      _dateTimeNullableConverter.encode(item.dateLimite),
                  'entreprise_id': item.entrepriseId,
                  'annee_scolaire_id': item.anneeScolaireId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _fraisScolaireDeletionAdapter = DeletionAdapter(
            database,
            'frais_scolaires',
            ['id'],
            (FraisScolaire item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'nom': item.nom,
                  'montant': item.montant,
                  'date_limite':
                      _dateTimeNullableConverter.encode(item.dateLimite),
                  'entreprise_id': item.entrepriseId,
                  'annee_scolaire_id': item.anneeScolaireId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<FraisScolaire> _fraisScolaireInsertionAdapter;

  final UpdateAdapter<FraisScolaire> _fraisScolaireUpdateAdapter;

  final DeletionAdapter<FraisScolaire> _fraisScolaireDeletionAdapter;

  @override
  Future<List<FraisScolaire>> getAllFraisScolaires() async {
    return _queryAdapter.queryList('SELECT * FROM frais_scolaires',
        mapper: (Map<String, Object?> row) => FraisScolaire(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            montant: row['montant'] as double,
            dateLimite:
                _dateTimeNullableConverter.decode(row['date_limite'] as int?),
            entrepriseId: row['entreprise_id'] as int,
            anneeScolaireId: row['annee_scolaire_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<FraisScolaire?> getFraisScolaireById(int id) async {
    return _queryAdapter.query('SELECT * FROM frais_scolaires WHERE id = ?1',
        mapper: (Map<String, Object?> row) => FraisScolaire(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            montant: row['montant'] as double,
            dateLimite:
                _dateTimeNullableConverter.decode(row['date_limite'] as int?),
            entrepriseId: row['entreprise_id'] as int,
            anneeScolaireId: row['annee_scolaire_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<FraisScolaire?> getFraisScolaireByServerId(int serverId) async {
    return _queryAdapter.query(
        'SELECT * FROM frais_scolaires WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => FraisScolaire(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            montant: row['montant'] as double,
            dateLimite:
                _dateTimeNullableConverter.decode(row['date_limite'] as int?),
            entrepriseId: row['entreprise_id'] as int,
            anneeScolaireId: row['annee_scolaire_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<List<FraisScolaire>> getFraisScolairesByEntreprise(
      int entrepriseId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM frais_scolaires WHERE entreprise_id = ?1',
        mapper: (Map<String, Object?> row) => FraisScolaire(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            montant: row['montant'] as double,
            dateLimite:
                _dateTimeNullableConverter.decode(row['date_limite'] as int?),
            entrepriseId: row['entreprise_id'] as int,
            anneeScolaireId: row['annee_scolaire_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [entrepriseId]);
  }

  @override
  Future<List<FraisScolaire>> getFraisScolairesByAnneeScolaire(
      int anneeScolaireId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM frais_scolaires WHERE annee_scolaire_id = ?1',
        mapper: (Map<String, Object?> row) => FraisScolaire(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            montant: row['montant'] as double,
            dateLimite:
                _dateTimeNullableConverter.decode(row['date_limite'] as int?),
            entrepriseId: row['entreprise_id'] as int,
            anneeScolaireId: row['annee_scolaire_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [anneeScolaireId]);
  }

  @override
  Future<List<FraisScolaire>> getFraisScolairesByEntrepriseAndAnnee(
    int entrepriseId,
    int anneeScolaireId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM frais_scolaires WHERE entreprise_id = ?1 AND annee_scolaire_id = ?2',
        mapper: (Map<String, Object?> row) => FraisScolaire(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, nom: row['nom'] as String, montant: row['montant'] as double, dateLimite: _dateTimeNullableConverter.decode(row['date_limite'] as int?), entrepriseId: row['entreprise_id'] as int, anneeScolaireId: row['annee_scolaire_id'] as int, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [entrepriseId, anneeScolaireId]);
  }

  @override
  Future<List<FraisScolaire>> getFraisScolairesActifs(
    DateTime date,
    int anneeScolaireId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM frais_scolaires WHERE date_limite >= ?1 AND annee_scolaire_id = ?2',
        mapper: (Map<String, Object?> row) => FraisScolaire(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, nom: row['nom'] as String, montant: row['montant'] as double, dateLimite: _dateTimeNullableConverter.decode(row['date_limite'] as int?), entrepriseId: row['entreprise_id'] as int, anneeScolaireId: row['annee_scolaire_id'] as int, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [_dateTimeConverter.encode(date), anneeScolaireId]);
  }

  @override
  Future<List<FraisScolaire>> getFraisScolairesEchus(
    DateTime date,
    int anneeScolaireId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM frais_scolaires WHERE date_limite < ?1 AND annee_scolaire_id = ?2',
        mapper: (Map<String, Object?> row) => FraisScolaire(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, nom: row['nom'] as String, montant: row['montant'] as double, dateLimite: _dateTimeNullableConverter.decode(row['date_limite'] as int?), entrepriseId: row['entreprise_id'] as int, anneeScolaireId: row['annee_scolaire_id'] as int, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [_dateTimeConverter.encode(date), anneeScolaireId]);
  }

  @override
  Future<List<FraisScolaire>> getUnsyncedFraisScolaires() async {
    return _queryAdapter.queryList(
        'SELECT * FROM frais_scolaires WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => FraisScolaire(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            nom: row['nom'] as String,
            montant: row['montant'] as double,
            dateLimite:
                _dateTimeNullableConverter.decode(row['date_limite'] as int?),
            entrepriseId: row['entreprise_id'] as int,
            anneeScolaireId: row['annee_scolaire_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<double?> getTotalFraisByAnneeScolaire(int anneeScolaireId) async {
    return _queryAdapter.query(
        'SELECT SUM(montant) FROM frais_scolaires WHERE annee_scolaire_id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [anneeScolaireId]);
  }

  @override
  Future<void> deleteAllFraisScolaires() async {
    await _queryAdapter.queryNoReturn('DELETE FROM frais_scolaires');
  }

  @override
  Future<void> deleteFraisScolairesByEntreprise(int entrepriseId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM frais_scolaires WHERE entreprise_id = ?1',
        arguments: [entrepriseId]);
  }

  @override
  Future<void> deleteFraisScolairesByAnneeScolaire(int anneeScolaireId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM frais_scolaires WHERE annee_scolaire_id = ?1',
        arguments: [anneeScolaireId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE frais_scolaires SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE frais_scolaires SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<int> insertFraisScolaire(FraisScolaire fraisScolaire) {
    return _fraisScolaireInsertionAdapter.insertAndReturnId(
        fraisScolaire, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertFraisScolaires(List<FraisScolaire> fraisScolaires) {
    return _fraisScolaireInsertionAdapter.insertListAndReturnIds(
        fraisScolaires, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateFraisScolaire(FraisScolaire fraisScolaire) async {
    await _fraisScolaireUpdateAdapter.update(
        fraisScolaire, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateFraisScolaires(List<FraisScolaire> fraisScolaires) async {
    await _fraisScolaireUpdateAdapter.updateList(
        fraisScolaires, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteFraisScolaire(FraisScolaire fraisScolaire) async {
    await _fraisScolaireDeletionAdapter.delete(fraisScolaire);
  }
}

class _$FraisClassesDao extends FraisClassesDao {
  _$FraisClassesDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _fraisClassesInsertionAdapter = InsertionAdapter(
            database,
            'frais_classes',
            (FraisClasses item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'frais_id': item.fraisId,
                  'classe_id': item.classeId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _fraisClassesUpdateAdapter = UpdateAdapter(
            database,
            'frais_classes',
            ['id'],
            (FraisClasses item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'frais_id': item.fraisId,
                  'classe_id': item.classeId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _fraisClassesDeletionAdapter = DeletionAdapter(
            database,
            'frais_classes',
            ['id'],
            (FraisClasses item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'frais_id': item.fraisId,
                  'classe_id': item.classeId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<FraisClasses> _fraisClassesInsertionAdapter;

  final UpdateAdapter<FraisClasses> _fraisClassesUpdateAdapter;

  final DeletionAdapter<FraisClasses> _fraisClassesDeletionAdapter;

  @override
  Future<List<FraisClasses>> getAllFraisClasses() async {
    return _queryAdapter.queryList('SELECT * FROM frais_classes',
        mapper: (Map<String, Object?> row) => FraisClasses(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            fraisId: row['frais_id'] as int,
            classeId: row['classe_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<FraisClasses?> getFraisClasseById(int id) async {
    return _queryAdapter.query('SELECT * FROM frais_classes WHERE id = ?1',
        mapper: (Map<String, Object?> row) => FraisClasses(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            fraisId: row['frais_id'] as int,
            classeId: row['classe_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<FraisClasses?> getFraisClasseByServerId(int serverId) async {
    return _queryAdapter.query(
        'SELECT * FROM frais_classes WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => FraisClasses(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            fraisId: row['frais_id'] as int,
            classeId: row['classe_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<List<FraisClasses>> getFraisClassesByFrais(int fraisId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM frais_classes WHERE frais_id = ?1',
        mapper: (Map<String, Object?> row) => FraisClasses(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            fraisId: row['frais_id'] as int,
            classeId: row['classe_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [fraisId]);
  }

  @override
  Future<List<FraisClasses>> getFraisClassesByClasse(int classeId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM frais_classes WHERE classe_id = ?1',
        mapper: (Map<String, Object?> row) => FraisClasses(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            fraisId: row['frais_id'] as int,
            classeId: row['classe_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [classeId]);
  }

  @override
  Future<FraisClasses?> getFraisClasseByFraisAndClasse(
    int fraisId,
    int classeId,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM frais_classes WHERE frais_id = ?1 AND classe_id = ?2',
        mapper: (Map<String, Object?> row) => FraisClasses(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            fraisId: row['frais_id'] as int,
            classeId: row['classe_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [fraisId, classeId]);
  }

  @override
  Future<List<FraisClasses>> getUnsyncedFraisClasses() async {
    return _queryAdapter.queryList(
        'SELECT * FROM frais_classes WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => FraisClasses(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            fraisId: row['frais_id'] as int,
            classeId: row['classe_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteFraisClasseById(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM frais_classes WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteFraisClasseByServerId(int serverId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM frais_classes WHERE server_id = ?1',
        arguments: [serverId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE frais_classes SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> markAsSyncedByServerId(int serverId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE frais_classes SET is_sync = 1 WHERE server_id = ?1',
        arguments: [serverId]);
  }

  @override
  Future<int?> getUnsyncedCount() async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM frais_classes WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getTotalCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM frais_classes',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE frais_classes SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<void> insertFraisClasse(FraisClasses fraisClasse) async {
    await _fraisClassesInsertionAdapter.insert(
        fraisClasse, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertFraisClasses(List<FraisClasses> fraisClasses) async {
    await _fraisClassesInsertionAdapter.insertList(
        fraisClasses, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateFraisClasse(FraisClasses fraisClasse) async {
    await _fraisClassesUpdateAdapter.update(
        fraisClasse, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateFraisClasses(List<FraisClasses> fraisClasses) async {
    await _fraisClassesUpdateAdapter.updateList(
        fraisClasses, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteFraisClasse(FraisClasses fraisClasse) async {
    await _fraisClassesDeletionAdapter.delete(fraisClasse);
  }

  @override
  Future<void> deleteFraisClasses(List<FraisClasses> fraisClasses) async {
    await _fraisClassesDeletionAdapter.deleteList(fraisClasses);
  }
}

class _$CoursDao extends CoursDao {
  _$CoursDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _coursInsertionAdapter = InsertionAdapter(
            database,
            'cours',
            (Cours item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'code': item.code,
                  'nom': item.nom,
                  'coefficient': item.coefficient,
                  'enseignant_id': item.enseignantId,
                  'classe_id': item.classeId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _coursUpdateAdapter = UpdateAdapter(
            database,
            'cours',
            ['id'],
            (Cours item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'code': item.code,
                  'nom': item.nom,
                  'coefficient': item.coefficient,
                  'enseignant_id': item.enseignantId,
                  'classe_id': item.classeId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _coursDeletionAdapter = DeletionAdapter(
            database,
            'cours',
            ['id'],
            (Cours item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'code': item.code,
                  'nom': item.nom,
                  'coefficient': item.coefficient,
                  'enseignant_id': item.enseignantId,
                  'classe_id': item.classeId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Cours> _coursInsertionAdapter;

  final UpdateAdapter<Cours> _coursUpdateAdapter;

  final DeletionAdapter<Cours> _coursDeletionAdapter;

  @override
  Future<List<Cours>> getAllCours() async {
    return _queryAdapter.queryList('SELECT * FROM cours',
        mapper: (Map<String, Object?> row) => Cours(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            coefficient: row['coefficient'] as int?,
            enseignantId: row['enseignant_id'] as int,
            classeId: row['classe_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<Cours?> getCoursById(int id) async {
    return _queryAdapter.query('SELECT * FROM cours WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Cours(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            coefficient: row['coefficient'] as int?,
            enseignantId: row['enseignant_id'] as int,
            classeId: row['classe_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<Cours?> getCoursByServerId(int serverId) async {
    return _queryAdapter.query('SELECT * FROM cours WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => Cours(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            coefficient: row['coefficient'] as int?,
            enseignantId: row['enseignant_id'] as int,
            classeId: row['classe_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<Cours?> getCoursByCode(String code) async {
    return _queryAdapter.query('SELECT * FROM cours WHERE code = ?1',
        mapper: (Map<String, Object?> row) => Cours(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            coefficient: row['coefficient'] as int?,
            enseignantId: row['enseignant_id'] as int,
            classeId: row['classe_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [code]);
  }

  @override
  Future<List<Cours>> getCoursByClasse(int classeId) async {
    return _queryAdapter.queryList('SELECT * FROM cours WHERE classe_id = ?1',
        mapper: (Map<String, Object?> row) => Cours(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            coefficient: row['coefficient'] as int?,
            enseignantId: row['enseignant_id'] as int,
            classeId: row['classe_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [classeId]);
  }

  @override
  Future<List<Cours>> getCoursByEnseignant(int enseignantId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM cours WHERE enseignant_id = ?1',
        mapper: (Map<String, Object?> row) => Cours(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            coefficient: row['coefficient'] as int?,
            enseignantId: row['enseignant_id'] as int,
            classeId: row['classe_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [enseignantId]);
  }

  @override
  Future<List<Cours>> getCoursByEnseignantAndClasse(
    int enseignantId,
    int classeId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM cours WHERE enseignant_id = ?1 AND classe_id = ?2',
        mapper: (Map<String, Object?> row) => Cours(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            coefficient: row['coefficient'] as int?,
            enseignantId: row['enseignant_id'] as int,
            classeId: row['classe_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [enseignantId, classeId]);
  }

  @override
  Future<List<Cours>> getUnsyncedCours() async {
    return _queryAdapter.queryList('SELECT * FROM cours WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => Cours(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            code: row['code'] as String?,
            nom: row['nom'] as String,
            coefficient: row['coefficient'] as int?,
            enseignantId: row['enseignant_id'] as int,
            classeId: row['classe_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteAllCours() async {
    await _queryAdapter.queryNoReturn('DELETE FROM cours');
  }

  @override
  Future<void> deleteCoursByClasse(int classeId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM cours WHERE classe_id = ?1',
        arguments: [classeId]);
  }

  @override
  Future<void> deleteCoursByEnseignant(int enseignantId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM cours WHERE enseignant_id = ?1',
        arguments: [enseignantId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE cours SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE cours SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<int> insertCours(Cours cours) {
    return _coursInsertionAdapter.insertAndReturnId(
        cours, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertMultipleCours(List<Cours> cours) {
    return _coursInsertionAdapter.insertListAndReturnIds(
        cours, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateCours(Cours cours) async {
    await _coursUpdateAdapter.update(cours, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateMultipleCours(List<Cours> cours) async {
    await _coursUpdateAdapter.updateList(cours, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCours(Cours cours) async {
    await _coursDeletionAdapter.delete(cours);
  }
}

class _$NotePeriodeDao extends NotePeriodeDao {
  _$NotePeriodeDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _notePeriodeInsertionAdapter = InsertionAdapter(
            database,
            'notes_periode',
            (NotePeriode item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'eleve_id': item.eleveId,
                  'cours_id': item.coursId,
                  'periode_id': item.periodeId,
                  'valeur': item.valeur,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _notePeriodeUpdateAdapter = UpdateAdapter(
            database,
            'notes_periode',
            ['id'],
            (NotePeriode item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'eleve_id': item.eleveId,
                  'cours_id': item.coursId,
                  'periode_id': item.periodeId,
                  'valeur': item.valeur,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _notePeriodeDeletionAdapter = DeletionAdapter(
            database,
            'notes_periode',
            ['id'],
            (NotePeriode item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'eleve_id': item.eleveId,
                  'cours_id': item.coursId,
                  'periode_id': item.periodeId,
                  'valeur': item.valeur,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<NotePeriode> _notePeriodeInsertionAdapter;

  final UpdateAdapter<NotePeriode> _notePeriodeUpdateAdapter;

  final DeletionAdapter<NotePeriode> _notePeriodeDeletionAdapter;

  @override
  Future<List<NotePeriode>> getAllNotesPeriode() async {
    return _queryAdapter.queryList('SELECT * FROM notes_periode',
        mapper: (Map<String, Object?> row) => NotePeriode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            coursId: row['cours_id'] as int,
            periodeId: row['periode_id'] as int,
            valeur: row['valeur'] as double?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<NotePeriode?> getNotesPeriodeById(int id) async {
    return _queryAdapter.query('SELECT * FROM notes_periode WHERE id = ?1',
        mapper: (Map<String, Object?> row) => NotePeriode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            coursId: row['cours_id'] as int,
            periodeId: row['periode_id'] as int,
            valeur: row['valeur'] as double?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<NotePeriode?> getNotesPeriodeByServerId(int serverId) async {
    return _queryAdapter.query(
        'SELECT * FROM notes_periode WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => NotePeriode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            coursId: row['cours_id'] as int,
            periodeId: row['periode_id'] as int,
            valeur: row['valeur'] as double?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<List<NotePeriode>> getNotesPeriodeByEleve(int eleveId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM notes_periode WHERE eleve_id = ?1',
        mapper: (Map<String, Object?> row) => NotePeriode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            coursId: row['cours_id'] as int,
            periodeId: row['periode_id'] as int,
            valeur: row['valeur'] as double?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [eleveId]);
  }

  @override
  Future<List<NotePeriode>> getNotesPeriodeByCours(int coursId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM notes_periode WHERE cours_id = ?1',
        mapper: (Map<String, Object?> row) => NotePeriode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            coursId: row['cours_id'] as int,
            periodeId: row['periode_id'] as int,
            valeur: row['valeur'] as double?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [coursId]);
  }

  @override
  Future<List<NotePeriode>> getNotesPeriodeByPeriode(int periodeId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM notes_periode WHERE periode_id = ?1',
        mapper: (Map<String, Object?> row) => NotePeriode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            coursId: row['cours_id'] as int,
            periodeId: row['periode_id'] as int,
            valeur: row['valeur'] as double?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [periodeId]);
  }

  @override
  Future<List<NotePeriode>> getNotesByEleveAndPeriode(
    int eleveId,
    int periodeId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM notes_periode WHERE eleve_id = ?1 AND periode_id = ?2',
        mapper: (Map<String, Object?> row) => NotePeriode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            coursId: row['cours_id'] as int,
            periodeId: row['periode_id'] as int,
            valeur: row['valeur'] as double?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [eleveId, periodeId]);
  }

  @override
  Future<List<NotePeriode>> getNotesByCoursAndPeriode(
    int coursId,
    int periodeId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM notes_periode WHERE cours_id = ?1 AND periode_id = ?2',
        mapper: (Map<String, Object?> row) => NotePeriode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            coursId: row['cours_id'] as int,
            periodeId: row['periode_id'] as int,
            valeur: row['valeur'] as double?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [coursId, periodeId]);
  }

  @override
  Future<NotePeriode?> getNoteByEleveCoursAndPeriode(
    int eleveId,
    int coursId,
    int periodeId,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM notes_periode WHERE eleve_id = ?1 AND cours_id = ?2 AND periode_id = ?3',
        mapper: (Map<String, Object?> row) => NotePeriode(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, eleveId: row['eleve_id'] as int, coursId: row['cours_id'] as int, periodeId: row['periode_id'] as int, valeur: row['valeur'] as double?, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [eleveId, coursId, periodeId]);
  }

  @override
  Future<List<NotePeriode>> getNotesSuperieuresA(double noteMin) async {
    return _queryAdapter.queryList(
        'SELECT * FROM notes_periode WHERE note_sur_20 >= ?1',
        mapper: (Map<String, Object?> row) => NotePeriode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            coursId: row['cours_id'] as int,
            periodeId: row['periode_id'] as int,
            valeur: row['valeur'] as double?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [noteMin]);
  }

  @override
  Future<List<NotePeriode>> getNotesInferieuresA(double noteMax) async {
    return _queryAdapter.queryList(
        'SELECT * FROM notes_periode WHERE note_sur_20 < ?1',
        mapper: (Map<String, Object?> row) => NotePeriode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            coursId: row['cours_id'] as int,
            periodeId: row['periode_id'] as int,
            valeur: row['valeur'] as double?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [noteMax]);
  }

  @override
  Future<List<NotePeriode>> getUnsyncedNotesPeriode() async {
    return _queryAdapter.queryList(
        'SELECT * FROM notes_periode WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => NotePeriode(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            coursId: row['cours_id'] as int,
            periodeId: row['periode_id'] as int,
            valeur: row['valeur'] as double?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteNotePeriodeById(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM notes_periode WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteAllNotesPeriode() async {
    await _queryAdapter.queryNoReturn('DELETE FROM notes_periode');
  }

  @override
  Future<void> deleteNotesByCours(int coursId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM notes_periode WHERE cours_id = ?1',
        arguments: [coursId]);
  }

  @override
  Future<void> deleteNotesByPeriode(int periodeId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM notes_periode WHERE periode_id = ?1',
        arguments: [periodeId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE notes_periode SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE notes_periode SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<int> insertNotePeriode(NotePeriode notePeriode) {
    return _notePeriodeInsertionAdapter.insertAndReturnId(
        notePeriode, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertMultipleNotePeriode(List<NotePeriode> notesPeriode) {
    return _notePeriodeInsertionAdapter.insertListAndReturnIds(
        notesPeriode, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateNotePeriode(NotePeriode notePeriode) async {
    await _notePeriodeUpdateAdapter.update(
        notePeriode, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateMultipleNotePeriode(List<NotePeriode> notesPeriode) async {
    await _notePeriodeUpdateAdapter.updateList(
        notesPeriode, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteNotePeriode(NotePeriode notePeriode) async {
    await _notePeriodeDeletionAdapter.delete(notePeriode);
  }
}

class _$PaiementFraisDao extends PaiementFraisDao {
  _$PaiementFraisDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _paiementFraisInsertionAdapter = InsertionAdapter(
            database,
            'paiement_frais',
            (PaiementFrais item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'eleve_id': item.eleveId,
                  'frais_scolaire_id': item.fraisScolaireId,
                  'montant_paye': item.montantPaye,
                  'date_paiement': _dateTimeConverter.encode(item.datePaiement),
                  'user_id': item.userId,
                  'reste_a_payer': item.resteAPayer,
                  'statut': item.statut,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _paiementFraisUpdateAdapter = UpdateAdapter(
            database,
            'paiement_frais',
            ['id'],
            (PaiementFrais item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'eleve_id': item.eleveId,
                  'frais_scolaire_id': item.fraisScolaireId,
                  'montant_paye': item.montantPaye,
                  'date_paiement': _dateTimeConverter.encode(item.datePaiement),
                  'user_id': item.userId,
                  'reste_a_payer': item.resteAPayer,
                  'statut': item.statut,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _paiementFraisDeletionAdapter = DeletionAdapter(
            database,
            'paiement_frais',
            ['id'],
            (PaiementFrais item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'eleve_id': item.eleveId,
                  'frais_scolaire_id': item.fraisScolaireId,
                  'montant_paye': item.montantPaye,
                  'date_paiement': _dateTimeConverter.encode(item.datePaiement),
                  'user_id': item.userId,
                  'reste_a_payer': item.resteAPayer,
                  'statut': item.statut,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PaiementFrais> _paiementFraisInsertionAdapter;

  final UpdateAdapter<PaiementFrais> _paiementFraisUpdateAdapter;

  final DeletionAdapter<PaiementFrais> _paiementFraisDeletionAdapter;

  @override
  Future<List<PaiementFrais>> getAllPaiementsFrais() async {
    return _queryAdapter.queryList('SELECT * FROM paiement_frais',
        mapper: (Map<String, Object?> row) => PaiementFrais(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montantPaye: row['montant_paye'] as double,
            datePaiement:
                _dateTimeConverter.decode(row['date_paiement'] as int),
            userId: row['user_id'] as int?,
            resteAPayer: row['reste_a_payer'] as double?,
            statut: row['statut'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<PaiementFrais?> getPaiementFraisById(int id) async {
    return _queryAdapter.query('SELECT * FROM paiement_frais WHERE id = ?1',
        mapper: (Map<String, Object?> row) => PaiementFrais(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montantPaye: row['montant_paye'] as double,
            datePaiement:
                _dateTimeConverter.decode(row['date_paiement'] as int),
            userId: row['user_id'] as int?,
            resteAPayer: row['reste_a_payer'] as double?,
            statut: row['statut'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<PaiementFrais?> getPaiementFraisByServerId(int serverId) async {
    return _queryAdapter.query(
        'SELECT * FROM paiement_frais WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => PaiementFrais(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montantPaye: row['montant_paye'] as double,
            datePaiement:
                _dateTimeConverter.decode(row['date_paiement'] as int),
            userId: row['user_id'] as int?,
            resteAPayer: row['reste_a_payer'] as double?,
            statut: row['statut'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<List<PaiementFrais>> getPaiementsFraisByEleve(int eleveId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM paiement_frais WHERE eleve_id = ?1',
        mapper: (Map<String, Object?> row) => PaiementFrais(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montantPaye: row['montant_paye'] as double,
            datePaiement:
                _dateTimeConverter.decode(row['date_paiement'] as int),
            userId: row['user_id'] as int?,
            resteAPayer: row['reste_a_payer'] as double?,
            statut: row['statut'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [eleveId]);
  }

  @override
  Future<List<PaiementFrais>> getPaiementsFraisByFrais(
      int fraisScolaireId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM paiement_frais WHERE frais_scolaire_id = ?1',
        mapper: (Map<String, Object?> row) => PaiementFrais(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montantPaye: row['montant_paye'] as double,
            datePaiement:
                _dateTimeConverter.decode(row['date_paiement'] as int),
            userId: row['user_id'] as int?,
            resteAPayer: row['reste_a_payer'] as double?,
            statut: row['statut'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [fraisScolaireId]);
  }

  @override
  Future<List<PaiementFrais>> getPaiementsByMethode(
      String methodePaiement) async {
    return _queryAdapter.queryList(
        'SELECT * FROM paiement_frais WHERE methode_paiement = ?1',
        mapper: (Map<String, Object?> row) => PaiementFrais(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montantPaye: row['montant_paye'] as double,
            datePaiement:
                _dateTimeConverter.decode(row['date_paiement'] as int),
            userId: row['user_id'] as int?,
            resteAPayer: row['reste_a_payer'] as double?,
            statut: row['statut'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [methodePaiement]);
  }

  @override
  Future<List<PaiementFrais>> getPaiementsByPeriode(
    DateTime dateDebut,
    DateTime dateFin,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM paiement_frais WHERE date_paiement BETWEEN ?1 AND ?2',
        mapper: (Map<String, Object?> row) => PaiementFrais(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montantPaye: row['montant_paye'] as double,
            datePaiement:
                _dateTimeConverter.decode(row['date_paiement'] as int),
            userId: row['user_id'] as int?,
            resteAPayer: row['reste_a_payer'] as double?,
            statut: row['statut'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [
          _dateTimeConverter.encode(dateDebut),
          _dateTimeConverter.encode(dateFin)
        ]);
  }

  @override
  Future<List<PaiementFrais>> getPaiementsByEleveAndPeriode(
    int eleveId,
    DateTime dateDebut,
    DateTime dateFin,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM paiement_frais WHERE eleve_id = ?1 AND date_paiement BETWEEN ?2 AND ?3',
        mapper: (Map<String, Object?> row) => PaiementFrais(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montantPaye: row['montant_paye'] as double,
            datePaiement:
                _dateTimeConverter.decode(row['date_paiement'] as int),
            userId: row['user_id'] as int?,
            resteAPayer: row['reste_a_payer'] as double?,
            statut: row['statut'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [
          eleveId,
          _dateTimeConverter.encode(dateDebut),
          _dateTimeConverter.encode(dateFin)
        ]);
  }

  @override
  Future<List<PaiementFrais>> getPaiementsSuperieursA(double montantMin) async {
    return _queryAdapter.queryList(
        'SELECT * FROM paiement_frais WHERE montant_paye >= ?1',
        mapper: (Map<String, Object?> row) => PaiementFrais(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montantPaye: row['montant_paye'] as double,
            datePaiement:
                _dateTimeConverter.decode(row['date_paiement'] as int),
            userId: row['user_id'] as int?,
            resteAPayer: row['reste_a_payer'] as double?,
            statut: row['statut'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [montantMin]);
  }

  @override
  Future<List<PaiementFrais>> getPaiementsByStatut(String statut) async {
    return _queryAdapter.queryList(
        'SELECT * FROM paiement_frais WHERE statut = ?1',
        mapper: (Map<String, Object?> row) => PaiementFrais(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montantPaye: row['montant_paye'] as double,
            datePaiement:
                _dateTimeConverter.decode(row['date_paiement'] as int),
            userId: row['user_id'] as int?,
            resteAPayer: row['reste_a_payer'] as double?,
            statut: row['statut'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [statut]);
  }

  @override
  Future<double?> getTotalPaiementsByEleve(int eleveId) async {
    return _queryAdapter.query(
        'SELECT SUM(montant_paye) FROM paiement_frais WHERE eleve_id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [eleveId]);
  }

  @override
  Future<double?> getTotalPaiementsByFrais(int fraisScolaireId) async {
    return _queryAdapter.query(
        'SELECT SUM(montant_paye) FROM paiement_frais WHERE frais_scolaire_id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [fraisScolaireId]);
  }

  @override
  Future<List<PaiementFrais>> getUnsyncedPaiementsFrais() async {
    return _queryAdapter.queryList(
        'SELECT * FROM paiement_frais WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => PaiementFrais(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montantPaye: row['montant_paye'] as double,
            datePaiement:
                _dateTimeConverter.decode(row['date_paiement'] as int),
            userId: row['user_id'] as int?,
            resteAPayer: row['reste_a_payer'] as double?,
            statut: row['statut'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteAllPaiementsFrais() async {
    await _queryAdapter.queryNoReturn('DELETE FROM paiement_frais');
  }

  @override
  Future<void> deletePaiementsByEleve(int eleveId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM paiement_frais WHERE eleve_id = ?1',
        arguments: [eleveId]);
  }

  @override
  Future<void> deletePaiementsByFrais(int fraisScolaireId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM paiement_frais WHERE frais_scolaire_id = ?1',
        arguments: [fraisScolaireId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE paiement_frais SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE paiement_frais SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<void> updateStatutPaiement(
    int id,
    String statut,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE paiement_frais SET statut = ?2 WHERE id = ?1',
        arguments: [id, statut]);
  }

  @override
  Future<int> insertPaiementFrais(PaiementFrais paiementFrais) {
    return _paiementFraisInsertionAdapter.insertAndReturnId(
        paiementFrais, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertPaiementsFrais(List<PaiementFrais> paiementsFrais) {
    return _paiementFraisInsertionAdapter.insertListAndReturnIds(
        paiementsFrais, OnConflictStrategy.replace);
  }

  @override
  Future<void> updatePaiementFrais(PaiementFrais paiementFrais) async {
    await _paiementFraisUpdateAdapter.update(
        paiementFrais, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePaiementsFrais(List<PaiementFrais> paiementsFrais) async {
    await _paiementFraisUpdateAdapter.updateList(
        paiementsFrais, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePaiementFrais(PaiementFrais paiementFrais) async {
    await _paiementFraisDeletionAdapter.delete(paiementFrais);
  }
}

class _$ConfigEcoleDao extends ConfigEcoleDao {
  _$ConfigEcoleDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _configEcoleInsertionAdapter = InsertionAdapter(
            database,
            'config_ecole',
            (ConfigEcole item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'entreprise_id': item.entrepriseId,
                  'annee_scolaire_en_cours_id': item.anneeScolaireEnCoursId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _configEcoleUpdateAdapter = UpdateAdapter(
            database,
            'config_ecole',
            ['id'],
            (ConfigEcole item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'entreprise_id': item.entrepriseId,
                  'annee_scolaire_en_cours_id': item.anneeScolaireEnCoursId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _configEcoleDeletionAdapter = DeletionAdapter(
            database,
            'config_ecole',
            ['id'],
            (ConfigEcole item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'entreprise_id': item.entrepriseId,
                  'annee_scolaire_en_cours_id': item.anneeScolaireEnCoursId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ConfigEcole> _configEcoleInsertionAdapter;

  final UpdateAdapter<ConfigEcole> _configEcoleUpdateAdapter;

  final DeletionAdapter<ConfigEcole> _configEcoleDeletionAdapter;

  @override
  Future<List<ConfigEcole>> getAllConfigsEcole() async {
    return _queryAdapter.queryList('SELECT * FROM config_ecole',
        mapper: (Map<String, Object?> row) => ConfigEcole(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int,
            anneeScolaireEnCoursId: row['annee_scolaire_en_cours_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<ConfigEcole?> getConfigEcoleById(int id) async {
    return _queryAdapter.query('SELECT * FROM config_ecole WHERE id = ?1',
        mapper: (Map<String, Object?> row) => ConfigEcole(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int,
            anneeScolaireEnCoursId: row['annee_scolaire_en_cours_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<ConfigEcole?> getConfigEcoleByServerId(int serverId) async {
    return _queryAdapter.query(
        'SELECT * FROM config_ecole WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => ConfigEcole(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int,
            anneeScolaireEnCoursId: row['annee_scolaire_en_cours_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<ConfigEcole?> getConfigEcoleByEntreprise(int entrepriseId) async {
    return _queryAdapter.query(
        'SELECT * FROM config_ecole WHERE entreprise_id = ?1',
        mapper: (Map<String, Object?> row) => ConfigEcole(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int,
            anneeScolaireEnCoursId: row['annee_scolaire_en_cours_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [entrepriseId]);
  }

  @override
  Future<List<ConfigEcole>> getUnsyncedConfigsEcole() async {
    return _queryAdapter.queryList(
        'SELECT * FROM config_ecole WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => ConfigEcole(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int,
            anneeScolaireEnCoursId: row['annee_scolaire_en_cours_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteAllConfigsEcole() async {
    await _queryAdapter.queryNoReturn('DELETE FROM config_ecole');
  }

  @override
  Future<void> deleteConfigsEcoleByEntreprise(int entrepriseId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM config_ecole WHERE entreprise_id = ?1',
        arguments: [entrepriseId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE config_ecole SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE config_ecole SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<void> updateAnneeScolaireEnCours(
    int entrepriseId,
    int anneeScolaireId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE config_ecole SET annee_scolaire_en_cours_id = ?2 WHERE entreprise_id = ?1',
        arguments: [entrepriseId, anneeScolaireId]);
  }

  @override
  Future<int> insertConfigEcole(ConfigEcole configEcole) {
    return _configEcoleInsertionAdapter.insertAndReturnId(
        configEcole, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertConfigsEcole(List<ConfigEcole> configsEcole) {
    return _configEcoleInsertionAdapter.insertListAndReturnIds(
        configsEcole, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateConfigEcole(ConfigEcole configEcole) async {
    await _configEcoleUpdateAdapter.update(
        configEcole, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateConfigsEcole(List<ConfigEcole> configsEcole) async {
    await _configEcoleUpdateAdapter.updateList(
        configsEcole, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteConfigEcole(ConfigEcole configEcole) async {
    await _configEcoleDeletionAdapter.delete(configEcole);
  }
}

class _$ComptesConfigDao extends ComptesConfigDao {
  _$ComptesConfigDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _comptesConfigInsertionAdapter = InsertionAdapter(
            database,
            'comptes_config',
            (ComptesConfig item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'entreprise_id': item.entrepriseId,
                  'compte_caisse_id': item.compteCaisseId,
                  'compte_frais_id': item.compteFraisId,
                  'compte_client_id': item.compteClientId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _comptesConfigUpdateAdapter = UpdateAdapter(
            database,
            'comptes_config',
            ['id'],
            (ComptesConfig item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'entreprise_id': item.entrepriseId,
                  'compte_caisse_id': item.compteCaisseId,
                  'compte_frais_id': item.compteFraisId,
                  'compte_client_id': item.compteClientId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _comptesConfigDeletionAdapter = DeletionAdapter(
            database,
            'comptes_config',
            ['id'],
            (ComptesConfig item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'entreprise_id': item.entrepriseId,
                  'compte_caisse_id': item.compteCaisseId,
                  'compte_frais_id': item.compteFraisId,
                  'compte_client_id': item.compteClientId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ComptesConfig> _comptesConfigInsertionAdapter;

  final UpdateAdapter<ComptesConfig> _comptesConfigUpdateAdapter;

  final DeletionAdapter<ComptesConfig> _comptesConfigDeletionAdapter;

  @override
  Future<List<ComptesConfig>> getAllComptesConfigs() async {
    return _queryAdapter.queryList('SELECT * FROM comptes_config',
        mapper: (Map<String, Object?> row) => ComptesConfig(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int,
            compteCaisseId: row['compte_caisse_id'] as int,
            compteFraisId: row['compte_frais_id'] as int,
            compteClientId: row['compte_client_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<ComptesConfig?> getComptesConfigById(int id) async {
    return _queryAdapter.query('SELECT * FROM comptes_config WHERE id = ?1',
        mapper: (Map<String, Object?> row) => ComptesConfig(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int,
            compteCaisseId: row['compte_caisse_id'] as int,
            compteFraisId: row['compte_frais_id'] as int,
            compteClientId: row['compte_client_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<ComptesConfig?> getComptesConfigByServerId(int serverId) async {
    return _queryAdapter.query(
        'SELECT * FROM comptes_config WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => ComptesConfig(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int,
            compteCaisseId: row['compte_caisse_id'] as int,
            compteFraisId: row['compte_frais_id'] as int,
            compteClientId: row['compte_client_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<ComptesConfig?> getComptesConfigByEntreprise(int entrepriseId) async {
    return _queryAdapter.query(
        'SELECT * FROM comptes_config WHERE entreprise_id = ?1',
        mapper: (Map<String, Object?> row) => ComptesConfig(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int,
            compteCaisseId: row['compte_caisse_id'] as int,
            compteFraisId: row['compte_frais_id'] as int,
            compteClientId: row['compte_client_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [entrepriseId]);
  }

  @override
  Future<List<ComptesConfig>> getUnsyncedComptesConfigs() async {
    return _queryAdapter.queryList(
        'SELECT * FROM comptes_config WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => ComptesConfig(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            entrepriseId: row['entreprise_id'] as int,
            compteCaisseId: row['compte_caisse_id'] as int,
            compteFraisId: row['compte_frais_id'] as int,
            compteClientId: row['compte_client_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteAllComptesConfigs() async {
    await _queryAdapter.queryNoReturn('DELETE FROM comptes_config');
  }

  @override
  Future<void> deleteComptesConfigsByEntreprise(int entrepriseId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM comptes_config WHERE entreprise_id = ?1',
        arguments: [entrepriseId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE comptes_config SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE comptes_config SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<int> insertComptesConfig(ComptesConfig comptesConfig) {
    return _comptesConfigInsertionAdapter.insertAndReturnId(
        comptesConfig, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertComptesConfigs(List<ComptesConfig> comptesConfigs) {
    return _comptesConfigInsertionAdapter.insertListAndReturnIds(
        comptesConfigs, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateComptesConfig(ComptesConfig comptesConfig) async {
    await _comptesConfigUpdateAdapter.update(
        comptesConfig, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateComptesConfigs(List<ComptesConfig> comptesConfigs) async {
    await _comptesConfigUpdateAdapter.updateList(
        comptesConfigs, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteComptesConfig(ComptesConfig comptesConfig) async {
    await _comptesConfigDeletionAdapter.delete(comptesConfig);
  }
}

class _$PeriodesClassesDao extends PeriodesClassesDao {
  _$PeriodesClassesDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _periodesClassesInsertionAdapter = InsertionAdapter(
            database,
            'periodes_classes',
            (PeriodesClasses item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'classe_id': item.classeId,
                  'periode_id': item.periodeId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _periodesClassesUpdateAdapter = UpdateAdapter(
            database,
            'periodes_classes',
            ['id'],
            (PeriodesClasses item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'classe_id': item.classeId,
                  'periode_id': item.periodeId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _periodesClassesDeletionAdapter = DeletionAdapter(
            database,
            'periodes_classes',
            ['id'],
            (PeriodesClasses item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'classe_id': item.classeId,
                  'periode_id': item.periodeId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PeriodesClasses> _periodesClassesInsertionAdapter;

  final UpdateAdapter<PeriodesClasses> _periodesClassesUpdateAdapter;

  final DeletionAdapter<PeriodesClasses> _periodesClassesDeletionAdapter;

  @override
  Future<List<PeriodesClasses>> getAllPeriodesClasses() async {
    return _queryAdapter.queryList('SELECT * FROM periodes_classes',
        mapper: (Map<String, Object?> row) => PeriodesClasses(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            classeId: row['classe_id'] as int,
            periodeId: row['periode_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<PeriodesClasses?> getPeriodeClasseById(int id) async {
    return _queryAdapter.query('SELECT * FROM periodes_classes WHERE id = ?1',
        mapper: (Map<String, Object?> row) => PeriodesClasses(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            classeId: row['classe_id'] as int,
            periodeId: row['periode_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<PeriodesClasses?> getPeriodeClasseByServerId(int serverId) async {
    return _queryAdapter.query(
        'SELECT * FROM periodes_classes WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => PeriodesClasses(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            classeId: row['classe_id'] as int,
            periodeId: row['periode_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<List<PeriodesClasses>> getPeriodeClassesByPeriode(
      int periodeId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM periodes_classes WHERE periode_id = ?1',
        mapper: (Map<String, Object?> row) => PeriodesClasses(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            classeId: row['classe_id'] as int,
            periodeId: row['periode_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [periodeId]);
  }

  @override
  Future<List<PeriodesClasses>> getPeriodeClassesByClasse(int classeId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM periodes_classes WHERE classe_id = ?1',
        mapper: (Map<String, Object?> row) => PeriodesClasses(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            classeId: row['classe_id'] as int,
            periodeId: row['periode_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [classeId]);
  }

  @override
  Future<PeriodesClasses?> getPeriodeClasseByPeriodeAndClasse(
    int periodeId,
    int classeId,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM periodes_classes WHERE periode_id = ?1 AND classe_id = ?2',
        mapper: (Map<String, Object?> row) => PeriodesClasses(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, classeId: row['classe_id'] as int, periodeId: row['periode_id'] as int, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [periodeId, classeId]);
  }

  @override
  Future<List<PeriodesClasses>> getPeriodeClassesByDate(DateTime date) async {
    return _queryAdapter.queryList(
        'SELECT * FROM periodes_classes WHERE date_debut <= ?1 AND date_fin >= ?1',
        mapper: (Map<String, Object?> row) => PeriodesClasses(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, classeId: row['classe_id'] as int, periodeId: row['periode_id'] as int, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [_dateTimeConverter.encode(date)]);
  }

  @override
  Future<List<PeriodesClasses>> getPeriodeClassesInDateRange(
    DateTime dateDebut,
    DateTime dateFin,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM periodes_classes WHERE date_debut >= ?1 AND date_fin <= ?2',
        mapper: (Map<String, Object?> row) => PeriodesClasses(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, classeId: row['classe_id'] as int, periodeId: row['periode_id'] as int, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [
          _dateTimeConverter.encode(dateDebut),
          _dateTimeConverter.encode(dateFin)
        ]);
  }

  @override
  Future<List<PeriodesClasses>> getPeriodeClassesActives() async {
    return _queryAdapter.queryList(
        'SELECT * FROM periodes_classes WHERE is_active = 1',
        mapper: (Map<String, Object?> row) => PeriodesClasses(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            classeId: row['classe_id'] as int,
            periodeId: row['periode_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<List<PeriodesClasses>> getPeriodeClassesActivesByClasse(
      int classeId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM periodes_classes WHERE is_active = 1 AND classe_id = ?1',
        mapper: (Map<String, Object?> row) => PeriodesClasses(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            classeId: row['classe_id'] as int,
            periodeId: row['periode_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [classeId]);
  }

  @override
  Future<List<PeriodesClasses>> getPeriodeClassesActivesByPeriode(
      int periodeId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM periodes_classes WHERE is_active = 1 AND periode_id = ?1',
        mapper: (Map<String, Object?> row) => PeriodesClasses(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, classeId: row['classe_id'] as int, periodeId: row['periode_id'] as int, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [periodeId]);
  }

  @override
  Future<PeriodesClasses?> getPeriodeClasseActuelle(
    DateTime currentDate,
    int classeId,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM periodes_classes WHERE date_debut <= ?1 AND date_fin >= ?1 AND is_active = 1 AND classe_id = ?2',
        mapper: (Map<String, Object?> row) => PeriodesClasses(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, classeId: row['classe_id'] as int, periodeId: row['periode_id'] as int, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [_dateTimeConverter.encode(currentDate), classeId]);
  }

  @override
  Future<List<PeriodesClasses>> getUnsyncedPeriodesClasses() async {
    return _queryAdapter.queryList(
        'SELECT * FROM periodes_classes WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => PeriodesClasses(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            classeId: row['classe_id'] as int,
            periodeId: row['periode_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<void> deleteAllPeriodesClasses() async {
    await _queryAdapter.queryNoReturn('DELETE FROM periodes_classes');
  }

  @override
  Future<void> deletePeriodeClassesByPeriode(int periodeId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM periodes_classes WHERE periode_id = ?1',
        arguments: [periodeId]);
  }

  @override
  Future<void> deletePeriodeClassesByClasse(int classeId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM periodes_classes WHERE classe_id = ?1',
        arguments: [classeId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE periodes_classes SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE periodes_classes SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<void> desactiverPeriodeClasse(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE periodes_classes SET is_active = 0 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> activerPeriodeClasse(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE periodes_classes SET is_active = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> desactiverToutesPeriodesClasse(int classeId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE periodes_classes SET is_active = 0 WHERE classe_id = ?1',
        arguments: [classeId]);
  }

  @override
  Future<void> desactiverToutesClassesPeriode(int periodeId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE periodes_classes SET is_active = 0 WHERE periode_id = ?1',
        arguments: [periodeId]);
  }

  @override
  Future<int> insertPeriodeClasse(PeriodesClasses periodesClasses) {
    return _periodesClassesInsertionAdapter.insertAndReturnId(
        periodesClasses, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertPeriodesClasses(
      List<PeriodesClasses> periodesClasses) {
    return _periodesClassesInsertionAdapter.insertListAndReturnIds(
        periodesClasses, OnConflictStrategy.replace);
  }

  @override
  Future<void> updatePeriodeClasse(PeriodesClasses periodesClasses) async {
    await _periodesClassesUpdateAdapter.update(
        periodesClasses, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePeriodesClasses(
      List<PeriodesClasses> periodesClasses) async {
    await _periodesClassesUpdateAdapter.updateList(
        periodesClasses, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePeriodeClasse(PeriodesClasses periodesClasses) async {
    await _periodesClassesDeletionAdapter.delete(periodesClasses);
  }
}

class _$JournalComptableDao extends JournalComptableDao {
  _$JournalComptableDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _journalComptableInsertionAdapter = InsertionAdapter(
            database,
            'journaux_comptables',
            (JournalComptable item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'date_operation':
                      _dateTimeConverter.encode(item.dateOperation),
                  'libelle': item.libelle,
                  'montant': item.montant,
                  'type_operation': item.typeOperation,
                  'paiement_frais_id': item.paiementFraisId,
                  'entreprise_id': item.entrepriseId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _journalComptableUpdateAdapter = UpdateAdapter(
            database,
            'journaux_comptables',
            ['id'],
            (JournalComptable item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'date_operation':
                      _dateTimeConverter.encode(item.dateOperation),
                  'libelle': item.libelle,
                  'montant': item.montant,
                  'type_operation': item.typeOperation,
                  'paiement_frais_id': item.paiementFraisId,
                  'entreprise_id': item.entrepriseId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _journalComptableDeletionAdapter = DeletionAdapter(
            database,
            'journaux_comptables',
            ['id'],
            (JournalComptable item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'date_operation':
                      _dateTimeConverter.encode(item.dateOperation),
                  'libelle': item.libelle,
                  'montant': item.montant,
                  'type_operation': item.typeOperation,
                  'paiement_frais_id': item.paiementFraisId,
                  'entreprise_id': item.entrepriseId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<JournalComptable> _journalComptableInsertionAdapter;

  final UpdateAdapter<JournalComptable> _journalComptableUpdateAdapter;

  final DeletionAdapter<JournalComptable> _journalComptableDeletionAdapter;

  @override
  Future<List<JournalComptable>> getAllJournauxComptables() async {
    return _queryAdapter.queryList('SELECT * FROM journaux_comptables',
        mapper: (Map<String, Object?> row) => JournalComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            dateOperation:
                _dateTimeConverter.decode(row['date_operation'] as int),
            libelle: row['libelle'] as String,
            montant: row['montant'] as double,
            typeOperation: row['type_operation'] as String,
            paiementFraisId: row['paiement_frais_id'] as int?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<JournalComptable?> getJournalComptableById(int id) async {
    return _queryAdapter.query(
        'SELECT * FROM journaux_comptables WHERE id = ?1',
        mapper: (Map<String, Object?> row) => JournalComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            dateOperation:
                _dateTimeConverter.decode(row['date_operation'] as int),
            libelle: row['libelle'] as String,
            montant: row['montant'] as double,
            typeOperation: row['type_operation'] as String,
            paiementFraisId: row['paiement_frais_id'] as int?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<JournalComptable?> getJournalComptableByServerId(int serverId) async {
    return _queryAdapter.query(
        'SELECT * FROM journaux_comptables WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => JournalComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            dateOperation:
                _dateTimeConverter.decode(row['date_operation'] as int),
            libelle: row['libelle'] as String,
            montant: row['montant'] as double,
            typeOperation: row['type_operation'] as String,
            paiementFraisId: row['paiement_frais_id'] as int?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<List<JournalComptable>> getJournauxComptablesByEntreprise(
      int entrepriseId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM journaux_comptables WHERE entreprise_id = ?1',
        mapper: (Map<String, Object?> row) => JournalComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            dateOperation:
                _dateTimeConverter.decode(row['date_operation'] as int),
            libelle: row['libelle'] as String,
            montant: row['montant'] as double,
            typeOperation: row['type_operation'] as String,
            paiementFraisId: row['paiement_frais_id'] as int?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [entrepriseId]);
  }

  @override
  Future<List<JournalComptable>> getJournauxComptablesByType(
    String typeOperation,
    int entrepriseId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM journaux_comptables WHERE type_operation = ?1 AND entreprise_id = ?2',
        mapper: (Map<String, Object?> row) => JournalComptable(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, dateOperation: _dateTimeConverter.decode(row['date_operation'] as int), libelle: row['libelle'] as String, montant: row['montant'] as double, typeOperation: row['type_operation'] as String, paiementFraisId: row['paiement_frais_id'] as int?, entrepriseId: row['entreprise_id'] as int, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [typeOperation, entrepriseId]);
  }

  @override
  Future<List<JournalComptable>> getJournauxComptablesByPaiementFrais(
      int paiementFraisId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM journaux_comptables WHERE paiement_frais_id = ?1',
        mapper: (Map<String, Object?> row) => JournalComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            dateOperation:
                _dateTimeConverter.decode(row['date_operation'] as int),
            libelle: row['libelle'] as String,
            montant: row['montant'] as double,
            typeOperation: row['type_operation'] as String,
            paiementFraisId: row['paiement_frais_id'] as int?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [paiementFraisId]);
  }

  @override
  Future<List<JournalComptable>> getJournauxComptablesByPeriode(
    DateTime dateDebut,
    DateTime dateFin,
    int entrepriseId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM journaux_comptables WHERE date_operation BETWEEN ?1 AND ?2 AND entreprise_id = ?3',
        mapper: (Map<String, Object?> row) => JournalComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            dateOperation:
                _dateTimeConverter.decode(row['date_operation'] as int),
            libelle: row['libelle'] as String,
            montant: row['montant'] as double,
            typeOperation: row['type_operation'] as String,
            paiementFraisId: row['paiement_frais_id'] as int?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [
          _dateTimeConverter.encode(dateDebut),
          _dateTimeConverter.encode(dateFin),
          entrepriseId
        ]);
  }

  @override
  Future<List<JournalComptable>> getUnsyncedJournauxComptables() async {
    return _queryAdapter.queryList(
        'SELECT * FROM journaux_comptables WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => JournalComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            dateOperation:
                _dateTimeConverter.decode(row['date_operation'] as int),
            libelle: row['libelle'] as String,
            montant: row['montant'] as double,
            typeOperation: row['type_operation'] as String,
            paiementFraisId: row['paiement_frais_id'] as int?,
            entrepriseId: row['entreprise_id'] as int,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<double?> getTotalByTypeOperation(
    String typeOperation,
    int entrepriseId,
  ) async {
    return _queryAdapter.query(
        'SELECT SUM(montant) FROM journaux_comptables WHERE type_operation = ?1 AND entreprise_id = ?2',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [typeOperation, entrepriseId]);
  }

  @override
  Future<double?> getTotalByPeriode(
    int entrepriseId,
    DateTime dateDebut,
    DateTime dateFin,
  ) async {
    return _queryAdapter.query(
        'SELECT SUM(montant) FROM journaux_comptables WHERE entreprise_id = ?1 AND date_operation BETWEEN ?2 AND ?3',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [
          entrepriseId,
          _dateTimeConverter.encode(dateDebut),
          _dateTimeConverter.encode(dateFin)
        ]);
  }

  @override
  Future<void> deleteAllJournauxComptables() async {
    await _queryAdapter.queryNoReturn('DELETE FROM journaux_comptables');
  }

  @override
  Future<void> deleteJournauxComptablesByEntreprise(int entrepriseId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM journaux_comptables WHERE entreprise_id = ?1',
        arguments: [entrepriseId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE journaux_comptables SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE journaux_comptables SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<int> insertJournalComptable(JournalComptable journalComptable) {
    return _journalComptableInsertionAdapter.insertAndReturnId(
        journalComptable, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertJournauxComptables(
      List<JournalComptable> journauxComptables) {
    return _journalComptableInsertionAdapter.insertListAndReturnIds(
        journauxComptables, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateJournalComptable(JournalComptable journalComptable) async {
    await _journalComptableUpdateAdapter.update(
        journalComptable, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateJournauxComptables(
      List<JournalComptable> journauxComptables) async {
    await _journalComptableUpdateAdapter.updateList(
        journauxComptables, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteJournalComptable(JournalComptable journalComptable) async {
    await _journalComptableDeletionAdapter.delete(journalComptable);
  }
}

class _$DepenseDao extends DepenseDao {
  _$DepenseDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _depenseInsertionAdapter = InsertionAdapter(
            database,
            'depenses',
            (Depense item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'libelle': item.libelle,
                  'montant': item.montant,
                  'date_depense': _dateTimeConverter.encode(item.dateDepense),
                  'entreprise_id': item.entrepriseId,
                  'observation': item.observation,
                  'journal_id': item.journalId,
                  'user_id': item.userId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _depenseUpdateAdapter = UpdateAdapter(
            database,
            'depenses',
            ['id'],
            (Depense item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'libelle': item.libelle,
                  'montant': item.montant,
                  'date_depense': _dateTimeConverter.encode(item.dateDepense),
                  'entreprise_id': item.entrepriseId,
                  'observation': item.observation,
                  'journal_id': item.journalId,
                  'user_id': item.userId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _depenseDeletionAdapter = DeletionAdapter(
            database,
            'depenses',
            ['id'],
            (Depense item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'libelle': item.libelle,
                  'montant': item.montant,
                  'date_depense': _dateTimeConverter.encode(item.dateDepense),
                  'entreprise_id': item.entrepriseId,
                  'observation': item.observation,
                  'journal_id': item.journalId,
                  'user_id': item.userId,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Depense> _depenseInsertionAdapter;

  final UpdateAdapter<Depense> _depenseUpdateAdapter;

  final DeletionAdapter<Depense> _depenseDeletionAdapter;

  @override
  Future<List<Depense>> getAllDepenses() async {
    return _queryAdapter.queryList('SELECT * FROM depenses',
        mapper: (Map<String, Object?> row) => Depense(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            libelle: row['libelle'] as String,
            montant: row['montant'] as double,
            dateDepense: _dateTimeConverter.decode(row['date_depense'] as int),
            entrepriseId: row['entreprise_id'] as int,
            observation: row['observation'] as String?,
            journalId: row['journal_id'] as int?,
            userId: row['user_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<Depense?> getDepenseById(int id) async {
    return _queryAdapter.query('SELECT * FROM depenses WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Depense(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            libelle: row['libelle'] as String,
            montant: row['montant'] as double,
            dateDepense: _dateTimeConverter.decode(row['date_depense'] as int),
            entrepriseId: row['entreprise_id'] as int,
            observation: row['observation'] as String?,
            journalId: row['journal_id'] as int?,
            userId: row['user_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<Depense?> getDepenseByServerId(int serverId) async {
    return _queryAdapter.query('SELECT * FROM depenses WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => Depense(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            libelle: row['libelle'] as String,
            montant: row['montant'] as double,
            dateDepense: _dateTimeConverter.decode(row['date_depense'] as int),
            entrepriseId: row['entreprise_id'] as int,
            observation: row['observation'] as String?,
            journalId: row['journal_id'] as int?,
            userId: row['user_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<List<Depense>> getDepensesByEntreprise(int entrepriseId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM depenses WHERE entreprise_id = ?1',
        mapper: (Map<String, Object?> row) => Depense(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            libelle: row['libelle'] as String,
            montant: row['montant'] as double,
            dateDepense: _dateTimeConverter.decode(row['date_depense'] as int),
            entrepriseId: row['entreprise_id'] as int,
            observation: row['observation'] as String?,
            journalId: row['journal_id'] as int?,
            userId: row['user_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [entrepriseId]);
  }

  @override
  Future<List<Depense>> getDepensesByUser(int userId) async {
    return _queryAdapter.queryList('SELECT * FROM depenses WHERE user_id = ?1',
        mapper: (Map<String, Object?> row) => Depense(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            libelle: row['libelle'] as String,
            montant: row['montant'] as double,
            dateDepense: _dateTimeConverter.decode(row['date_depense'] as int),
            entrepriseId: row['entreprise_id'] as int,
            observation: row['observation'] as String?,
            journalId: row['journal_id'] as int?,
            userId: row['user_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [userId]);
  }

  @override
  Future<List<Depense>> getDepensesByJournal(int journalId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM depenses WHERE journal_id = ?1',
        mapper: (Map<String, Object?> row) => Depense(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            libelle: row['libelle'] as String,
            montant: row['montant'] as double,
            dateDepense: _dateTimeConverter.decode(row['date_depense'] as int),
            entrepriseId: row['entreprise_id'] as int,
            observation: row['observation'] as String?,
            journalId: row['journal_id'] as int?,
            userId: row['user_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [journalId]);
  }

  @override
  Future<List<Depense>> getDepensesByPeriode(
    DateTime dateDebut,
    DateTime dateFin,
    int entrepriseId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM depenses WHERE date_depense BETWEEN ?1 AND ?2 AND entreprise_id = ?3',
        mapper: (Map<String, Object?> row) => Depense(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            libelle: row['libelle'] as String,
            montant: row['montant'] as double,
            dateDepense: _dateTimeConverter.decode(row['date_depense'] as int),
            entrepriseId: row['entreprise_id'] as int,
            observation: row['observation'] as String?,
            journalId: row['journal_id'] as int?,
            userId: row['user_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [
          _dateTimeConverter.encode(dateDebut),
          _dateTimeConverter.encode(dateFin),
          entrepriseId
        ]);
  }

  @override
  Future<List<Depense>> getUnsyncedDepenses() async {
    return _queryAdapter.queryList('SELECT * FROM depenses WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => Depense(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            libelle: row['libelle'] as String,
            montant: row['montant'] as double,
            dateDepense: _dateTimeConverter.decode(row['date_depense'] as int),
            entrepriseId: row['entreprise_id'] as int,
            observation: row['observation'] as String?,
            journalId: row['journal_id'] as int?,
            userId: row['user_id'] as int?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<double?> getTotalDepensesByPeriode(
    int entrepriseId,
    DateTime dateDebut,
    DateTime dateFin,
  ) async {
    return _queryAdapter.query(
        'SELECT SUM(montant) FROM depenses WHERE entreprise_id = ?1 AND date_depense BETWEEN ?2 AND ?3',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [
          entrepriseId,
          _dateTimeConverter.encode(dateDebut),
          _dateTimeConverter.encode(dateFin)
        ]);
  }

  @override
  Future<double?> getTotalDepensesByEntreprise(int entrepriseId) async {
    return _queryAdapter.query(
        'SELECT SUM(montant) FROM depenses WHERE entreprise_id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [entrepriseId]);
  }

  @override
  Future<void> deleteAllDepenses() async {
    await _queryAdapter.queryNoReturn('DELETE FROM depenses');
  }

  @override
  Future<void> deleteDepensesByEntreprise(int entrepriseId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM depenses WHERE entreprise_id = ?1',
        arguments: [entrepriseId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE depenses SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE depenses SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<int> insertDepense(Depense depense) {
    return _depenseInsertionAdapter.insertAndReturnId(
        depense, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertDepenses(List<Depense> depenses) {
    return _depenseInsertionAdapter.insertListAndReturnIds(
        depenses, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateDepense(Depense depense) async {
    await _depenseUpdateAdapter.update(depense, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateDepenses(List<Depense> depenses) async {
    await _depenseUpdateAdapter.updateList(depenses, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteDepense(Depense depense) async {
    await _depenseDeletionAdapter.delete(depense);
  }
}

class _$EcritureComptableDao extends EcritureComptableDao {
  _$EcritureComptableDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _ecritureComptableInsertionAdapter = InsertionAdapter(
            database,
            'ecritures_comptables',
            (EcritureComptable item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'journal_id': item.journalId,
                  'compte_comptable_id': item.compteComptableId,
                  'debit': item.debit,
                  'credit': item.credit,
                  'ordre': item.ordre,
                  'date_ecriture': _dateTimeConverter.encode(item.dateEcriture),
                  'libelle': item.libelle,
                  'reference': item.reference,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _ecritureComptableUpdateAdapter = UpdateAdapter(
            database,
            'ecritures_comptables',
            ['id'],
            (EcritureComptable item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'journal_id': item.journalId,
                  'compte_comptable_id': item.compteComptableId,
                  'debit': item.debit,
                  'credit': item.credit,
                  'ordre': item.ordre,
                  'date_ecriture': _dateTimeConverter.encode(item.dateEcriture),
                  'libelle': item.libelle,
                  'reference': item.reference,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _ecritureComptableDeletionAdapter = DeletionAdapter(
            database,
            'ecritures_comptables',
            ['id'],
            (EcritureComptable item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'journal_id': item.journalId,
                  'compte_comptable_id': item.compteComptableId,
                  'debit': item.debit,
                  'credit': item.credit,
                  'ordre': item.ordre,
                  'date_ecriture': _dateTimeConverter.encode(item.dateEcriture),
                  'libelle': item.libelle,
                  'reference': item.reference,
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<EcritureComptable> _ecritureComptableInsertionAdapter;

  final UpdateAdapter<EcritureComptable> _ecritureComptableUpdateAdapter;

  final DeletionAdapter<EcritureComptable> _ecritureComptableDeletionAdapter;

  @override
  Future<List<EcritureComptable>> getAllEcrituresComptables() async {
    return _queryAdapter.queryList('SELECT * FROM ecritures_comptables',
        mapper: (Map<String, Object?> row) => EcritureComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            journalId: row['journal_id'] as int,
            compteComptableId: row['compte_comptable_id'] as int,
            debit: row['debit'] as double?,
            credit: row['credit'] as double?,
            ordre: row['ordre'] as int,
            dateEcriture:
                _dateTimeConverter.decode(row['date_ecriture'] as int),
            libelle: row['libelle'] as String?,
            reference: row['reference'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<EcritureComptable?> getEcritureComptableById(int id) async {
    return _queryAdapter.query(
        'SELECT * FROM ecritures_comptables WHERE id = ?1',
        mapper: (Map<String, Object?> row) => EcritureComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            journalId: row['journal_id'] as int,
            compteComptableId: row['compte_comptable_id'] as int,
            debit: row['debit'] as double?,
            credit: row['credit'] as double?,
            ordre: row['ordre'] as int,
            dateEcriture:
                _dateTimeConverter.decode(row['date_ecriture'] as int),
            libelle: row['libelle'] as String?,
            reference: row['reference'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<EcritureComptable?> getEcritureComptableByServerId(
      int serverId) async {
    return _queryAdapter.query(
        'SELECT * FROM ecritures_comptables WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => EcritureComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            journalId: row['journal_id'] as int,
            compteComptableId: row['compte_comptable_id'] as int,
            debit: row['debit'] as double?,
            credit: row['credit'] as double?,
            ordre: row['ordre'] as int,
            dateEcriture:
                _dateTimeConverter.decode(row['date_ecriture'] as int),
            libelle: row['libelle'] as String?,
            reference: row['reference'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<List<EcritureComptable>> getEcrituresComptablesByJournal(
      int journalId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ecritures_comptables WHERE journal_id = ?1 ORDER BY ordre',
        mapper: (Map<String, Object?> row) => EcritureComptable(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, journalId: row['journal_id'] as int, compteComptableId: row['compte_comptable_id'] as int, debit: row['debit'] as double?, credit: row['credit'] as double?, ordre: row['ordre'] as int, dateEcriture: _dateTimeConverter.decode(row['date_ecriture'] as int), libelle: row['libelle'] as String?, reference: row['reference'] as String?, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [journalId]);
  }

  @override
  Future<List<EcritureComptable>> getEcrituresComptablesByCompte(
      int compteComptableId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ecritures_comptables WHERE compte_comptable_id = ?1',
        mapper: (Map<String, Object?> row) => EcritureComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            journalId: row['journal_id'] as int,
            compteComptableId: row['compte_comptable_id'] as int,
            debit: row['debit'] as double?,
            credit: row['credit'] as double?,
            ordre: row['ordre'] as int,
            dateEcriture:
                _dateTimeConverter.decode(row['date_ecriture'] as int),
            libelle: row['libelle'] as String?,
            reference: row['reference'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [compteComptableId]);
  }

  @override
  Future<List<EcritureComptable>> getEcrituresComptablesByReference(
      String reference) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ecritures_comptables WHERE reference = ?1',
        mapper: (Map<String, Object?> row) => EcritureComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            journalId: row['journal_id'] as int,
            compteComptableId: row['compte_comptable_id'] as int,
            debit: row['debit'] as double?,
            credit: row['credit'] as double?,
            ordre: row['ordre'] as int,
            dateEcriture:
                _dateTimeConverter.decode(row['date_ecriture'] as int),
            libelle: row['libelle'] as String?,
            reference: row['reference'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [reference]);
  }

  @override
  Future<List<EcritureComptable>> getEcrituresComptablesByPeriode(
    DateTime dateDebut,
    DateTime dateFin,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ecritures_comptables WHERE date_ecriture BETWEEN ?1 AND ?2',
        mapper: (Map<String, Object?> row) => EcritureComptable(id: row['id'] as int?, serverId: row['server_id'] as int?, isSync: (row['is_sync'] as int) != 0, journalId: row['journal_id'] as int, compteComptableId: row['compte_comptable_id'] as int, debit: row['debit'] as double?, credit: row['credit'] as double?, ordre: row['ordre'] as int, dateEcriture: _dateTimeConverter.decode(row['date_ecriture'] as int), libelle: row['libelle'] as String?, reference: row['reference'] as String?, dateCreation: _dateTimeConverter.decode(row['date_creation'] as int), dateModification: _dateTimeConverter.decode(row['date_modification'] as int), updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [
          _dateTimeConverter.encode(dateDebut),
          _dateTimeConverter.encode(dateFin)
        ]);
  }

  @override
  Future<List<EcritureComptable>> getUnsyncedEcrituresComptables() async {
    return _queryAdapter.queryList(
        'SELECT * FROM ecritures_comptables WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => EcritureComptable(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            journalId: row['journal_id'] as int,
            compteComptableId: row['compte_comptable_id'] as int,
            debit: row['debit'] as double?,
            credit: row['credit'] as double?,
            ordre: row['ordre'] as int,
            dateEcriture:
                _dateTimeConverter.decode(row['date_ecriture'] as int),
            libelle: row['libelle'] as String?,
            reference: row['reference'] as String?,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<double?> getTotalDebitByCompte(int compteId) async {
    return _queryAdapter.query(
        'SELECT SUM(debit) FROM ecritures_comptables WHERE compte_comptable_id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [compteId]);
  }

  @override
  Future<double?> getTotalCreditByCompte(int compteId) async {
    return _queryAdapter.query(
        'SELECT SUM(credit) FROM ecritures_comptables WHERE compte_comptable_id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [compteId]);
  }

  @override
  Future<double?> getSoldeByCompte(int compteId) async {
    return _queryAdapter.query(
        'SELECT SUM(debit) - SUM(credit) FROM ecritures_comptables WHERE compte_comptable_id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [compteId]);
  }

  @override
  Future<void> deleteAllEcrituresComptables() async {
    await _queryAdapter.queryNoReturn('DELETE FROM ecritures_comptables');
  }

  @override
  Future<void> deleteEcrituresComptablesByJournal(int journalId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM ecritures_comptables WHERE journal_id = ?1',
        arguments: [journalId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ecritures_comptables SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ecritures_comptables SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<int> insertEcritureComptable(EcritureComptable ecritureComptable) {
    return _ecritureComptableInsertionAdapter.insertAndReturnId(
        ecritureComptable, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertEcrituresComptables(
      List<EcritureComptable> ecrituresComptables) {
    return _ecritureComptableInsertionAdapter.insertListAndReturnIds(
        ecrituresComptables, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateEcritureComptable(
      EcritureComptable ecritureComptable) async {
    await _ecritureComptableUpdateAdapter.update(
        ecritureComptable, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateEcrituresComptables(
      List<EcritureComptable> ecrituresComptables) async {
    await _ecritureComptableUpdateAdapter.updateList(
        ecrituresComptables, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteEcritureComptable(
      EcritureComptable ecritureComptable) async {
    await _ecritureComptableDeletionAdapter.delete(ecritureComptable);
  }
}

class _$CreanceDao extends CreanceDao {
  _$CreanceDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _creanceInsertionAdapter = InsertionAdapter(
            database,
            'creances',
            (Creance item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'eleve_id': item.eleveId,
                  'frais_scolaire_id': item.fraisScolaireId,
                  'montant': item.montant,
                  'date_echeance': _dateTimeConverter.encode(item.dateEcheance),
                  'active': item.active == null ? null : (item.active! ? 1 : 0),
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _creanceUpdateAdapter = UpdateAdapter(
            database,
            'creances',
            ['id'],
            (Creance item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'eleve_id': item.eleveId,
                  'frais_scolaire_id': item.fraisScolaireId,
                  'montant': item.montant,
                  'date_echeance': _dateTimeConverter.encode(item.dateEcheance),
                  'active': item.active == null ? null : (item.active! ? 1 : 0),
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                }),
        _creanceDeletionAdapter = DeletionAdapter(
            database,
            'creances',
            ['id'],
            (Creance item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'is_sync': item.isSync ? 1 : 0,
                  'eleve_id': item.eleveId,
                  'frais_scolaire_id': item.fraisScolaireId,
                  'montant': item.montant,
                  'date_echeance': _dateTimeConverter.encode(item.dateEcheance),
                  'active': item.active == null ? null : (item.active! ? 1 : 0),
                  'date_creation': _dateTimeConverter.encode(item.dateCreation),
                  'date_modification':
                      _dateTimeConverter.encode(item.dateModification),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Creance> _creanceInsertionAdapter;

  final UpdateAdapter<Creance> _creanceUpdateAdapter;

  final DeletionAdapter<Creance> _creanceDeletionAdapter;

  @override
  Future<List<Creance>> getAllCreances() async {
    return _queryAdapter.queryList('SELECT * FROM creances',
        mapper: (Map<String, Object?> row) => Creance(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montant: row['montant'] as double,
            dateEcheance:
                _dateTimeConverter.decode(row['date_echeance'] as int),
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<Creance?> getCreanceById(int id) async {
    return _queryAdapter.query('SELECT * FROM creances WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Creance(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montant: row['montant'] as double,
            dateEcheance:
                _dateTimeConverter.decode(row['date_echeance'] as int),
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<Creance?> getCreanceByServerId(int serverId) async {
    return _queryAdapter.query('SELECT * FROM creances WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => Creance(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montant: row['montant'] as double,
            dateEcheance:
                _dateTimeConverter.decode(row['date_echeance'] as int),
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [serverId]);
  }

  @override
  Future<List<Creance>> getCreancesByEleve(int eleveId) async {
    return _queryAdapter.queryList('SELECT * FROM creances WHERE eleve_id = ?1',
        mapper: (Map<String, Object?> row) => Creance(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montant: row['montant'] as double,
            dateEcheance:
                _dateTimeConverter.decode(row['date_echeance'] as int),
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [eleveId]);
  }

  @override
  Future<List<Creance>> getCreancesByFraisScolaire(int fraisScolaireId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM creances WHERE frais_scolaire_id = ?1',
        mapper: (Map<String, Object?> row) => Creance(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montant: row['montant'] as double,
            dateEcheance:
                _dateTimeConverter.decode(row['date_echeance'] as int),
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [fraisScolaireId]);
  }

  @override
  Future<List<Creance>> getCreancesActivesByEleve(int eleveId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM creances WHERE eleve_id = ?1 AND active = 1',
        mapper: (Map<String, Object?> row) => Creance(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montant: row['montant'] as double,
            dateEcheance:
                _dateTimeConverter.decode(row['date_echeance'] as int),
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [eleveId]);
  }

  @override
  Future<List<Creance>> getCreancesEchues(DateTime date) async {
    return _queryAdapter.queryList(
        'SELECT * FROM creances WHERE date_echeance < ?1 AND active = 1',
        mapper: (Map<String, Object?> row) => Creance(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montant: row['montant'] as double,
            dateEcheance:
                _dateTimeConverter.decode(row['date_echeance'] as int),
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)),
        arguments: [_dateTimeConverter.encode(date)]);
  }

  @override
  Future<List<Creance>> getUnsyncedCreances() async {
    return _queryAdapter.queryList('SELECT * FROM creances WHERE is_sync = 0',
        mapper: (Map<String, Object?> row) => Creance(
            id: row['id'] as int?,
            serverId: row['server_id'] as int?,
            isSync: (row['is_sync'] as int) != 0,
            eleveId: row['eleve_id'] as int,
            fraisScolaireId: row['frais_scolaire_id'] as int,
            montant: row['montant'] as double,
            dateEcheance:
                _dateTimeConverter.decode(row['date_echeance'] as int),
            active: row['active'] == null ? null : (row['active'] as int) != 0,
            dateCreation:
                _dateTimeConverter.decode(row['date_creation'] as int),
            dateModification:
                _dateTimeConverter.decode(row['date_modification'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int)));
  }

  @override
  Future<double?> getTotalCreancesByEleve(int eleveId) async {
    return _queryAdapter.query(
        'SELECT SUM(montant) FROM creances WHERE eleve_id = ?1 AND active = 1',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [eleveId]);
  }

  @override
  Future<void> deleteAllCreances() async {
    await _queryAdapter.queryNoReturn('DELETE FROM creances');
  }

  @override
  Future<void> deleteCreancesByEleve(int eleveId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM creances WHERE eleve_id = ?1',
        arguments: [eleveId]);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE creances SET is_sync = 1 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> updateServerIdAndSync(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE creances SET server_id = ?2, is_sync = 1 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<void> desactiverCreance(int id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE creances SET active = 0 WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<int> insertCreance(Creance creance) {
    return _creanceInsertionAdapter.insertAndReturnId(
        creance, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertCreances(List<Creance> creances) {
    return _creanceInsertionAdapter.insertListAndReturnIds(
        creances, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateCreance(Creance creance) async {
    await _creanceUpdateAdapter.update(creance, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCreances(List<Creance> creances) async {
    await _creanceUpdateAdapter.updateList(creances, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCreance(Creance creance) async {
    await _creanceDeletionAdapter.delete(creance);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
final _dateTimeNullableConverter = DateTimeNullableConverter();
