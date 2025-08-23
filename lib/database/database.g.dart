// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $MainDatabaseAppFloorBuilderContract {
  /// Adds migrations to the builder.
  $MainDatabaseAppFloorBuilderContract addMigrations(
      List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $MainDatabaseAppFloorBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<MainDatabaseAppFloor> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorMainDatabaseAppFloor {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $MainDatabaseAppFloorBuilderContract databaseBuilder(String name) =>
      _$MainDatabaseAppFloorBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $MainDatabaseAppFloorBuilderContract inMemoryDatabaseBuilder() =>
      _$MainDatabaseAppFloorBuilder(null);
}

class _$MainDatabaseAppFloorBuilder
    implements $MainDatabaseAppFloorBuilderContract {
  _$MainDatabaseAppFloorBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $MainDatabaseAppFloorBuilderContract addMigrations(
      List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $MainDatabaseAppFloorBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<MainDatabaseAppFloor> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$MainDatabaseAppFloor();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$MainDatabaseAppFloor extends MainDatabaseAppFloor {
  _$MainDatabaseAppFloor([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  EntreprisesDao? _entreprisesDaoInstance;

  AnneeScolaireDao? _anneeScolaireDaoInstance;

  FraisScolaireDao? _fraisScolaireDaoInstance;

  EnseignantDao? _enseignantDaoInstance;

  ClassesDao? _classDaosInstance;

  ResponsableDao? _responsableDaoInstance;

  ElevesDao? _elevesDaoInstance;

  FraisDao? _fraisDaoInstance;

  FraisclasseDao? _fraisclasseDaoInstance;

  UtilisateursDao? _utilisateursDaoInstance;

  Paiementfraisdao? _paiementFraisDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
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
            'CREATE TABLE IF NOT EXISTS `entreprises` (`id` INTEGER NOT NULL, `nom` TEXT NOT NULL, `date_creation` TEXT, `date_modification` TEXT, `adresse` TEXT, `numero_id` TEXT, `devise` TEXT, `telephone` TEXT, `email` TEXT, `logo` BLOB, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `responsables` (`id` INTEGER NOT NULL, `nom` TEXT, `code` TEXT, `telephone` TEXT, `adresse` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `frais` (`id` INTEGER NOT NULL, `nom` TEXT NOT NULL, `montant` INTEGER, `code` TEXT, `entreprise_id` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `utilisateurs` (`id` INTEGER NOT NULL, `nom` TEXT NOT NULL, `prenom` TEXT NOT NULL, `email` TEXT NOT NULL, `mot_de_passe_hash` TEXT NOT NULL, `role` TEXT NOT NULL, `entreprise_id` INTEGER NOT NULL, `date_creation` TEXT NOT NULL, `date_modification` TEXT NOT NULL, `actif` INTEGER, FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `annees_scolaires` (`id` INTEGER NOT NULL, `nom` TEXT NOT NULL, `date_debut` TEXT NOT NULL, `date_fin` TEXT NOT NULL, `entreprise_id` INTEGER NOT NULL, `en_cours` INTEGER, FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `enseignants` (`id` INTEGER NOT NULL, `nom` TEXT NOT NULL, `prenom` TEXT NOT NULL, `entreprise_id` INTEGER NOT NULL, `matricule` TEXT, `sexe` TEXT, `niveau` TEXT, `discipline` TEXT, `email` TEXT, `telephone` TEXT, FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `frais_scolaires` (`id` INTEGER NOT NULL, `nom` TEXT NOT NULL, `montant` REAL NOT NULL, `annee_scolaire_id` INTEGER NOT NULL, `entreprise_id` INTEGER NOT NULL, `date_limite` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `classes` (`id` INTEGER NOT NULL, `nom` TEXT NOT NULL, `annee_scolaire_id` INTEGER NOT NULL, `code` TEXT, `niveau` TEXT, `effectif` INTEGER, `enseignant_id` INTEGER, FOREIGN KEY (`annee_scolaire_id`) REFERENCES `annees_scolaires` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`enseignant_id`) REFERENCES `enseignants` (`id`) ON UPDATE NO ACTION ON DELETE SET NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `eleves` (`id` INTEGER NOT NULL, `nom` TEXT NOT NULL, `prenom` TEXT NOT NULL, `postnom` TEXT, `sexe` TEXT, `statut` TEXT, `date_naissance` TEXT, `lieu_naissance` TEXT, `matricule` TEXT, `numero_permanent` TEXT, `classe_id` INTEGER, `responsable_id` INTEGER, FOREIGN KEY (`classe_id`) REFERENCES `classes` (`id`) ON UPDATE NO ACTION ON DELETE SET NULL, FOREIGN KEY (`responsable_id`) REFERENCES `responsables` (`id`) ON UPDATE NO ACTION ON DELETE SET NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `frais_classes` (`id` INTEGER NOT NULL, `frais_id` INTEGER NOT NULL, `classe_id` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `paiement_frais` (`id` INTEGER NOT NULL, `eleve_id` INTEGER NOT NULL, `frais_scolaire_id` INTEGER NOT NULL, `montant_paye` REAL NOT NULL, `date_paiement` TEXT NOT NULL, `user_id` INTEGER, `reste_a_payer` REAL, `statut` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE UNIQUE INDEX `index_responsables_code` ON `responsables` (`code`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_frais_code` ON `frais` (`code`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_utilisateurs_email` ON `utilisateurs` (`email`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  EntreprisesDao get entreprisesDao {
    return _entreprisesDaoInstance ??=
        _$EntreprisesDao(database, changeListener);
  }

  @override
  AnneeScolaireDao get anneeScolaireDao {
    return _anneeScolaireDaoInstance ??=
        _$AnneeScolaireDao(database, changeListener);
  }

  @override
  FraisScolaireDao get fraisScolaireDao {
    return _fraisScolaireDaoInstance ??=
        _$FraisScolaireDao(database, changeListener);
  }

  @override
  EnseignantDao get enseignantDao {
    return _enseignantDaoInstance ??= _$EnseignantDao(database, changeListener);
  }

  @override
  ClassesDao get classDaos {
    return _classDaosInstance ??= _$ClassesDao(database, changeListener);
  }

  @override
  ResponsableDao get responsableDao {
    return _responsableDaoInstance ??=
        _$ResponsableDao(database, changeListener);
  }

  @override
  ElevesDao get elevesDao {
    return _elevesDaoInstance ??= _$ElevesDao(database, changeListener);
  }

  @override
  FraisDao get fraisDao {
    return _fraisDaoInstance ??= _$FraisDao(database, changeListener);
  }

  @override
  FraisclasseDao get fraisclasseDao {
    return _fraisclasseDaoInstance ??=
        _$FraisclasseDao(database, changeListener);
  }

  @override
  UtilisateursDao get utilisateursDao {
    return _utilisateursDaoInstance ??=
        _$UtilisateursDao(database, changeListener);
  }

  @override
  Paiementfraisdao get paiementFraisDao {
    return _paiementFraisDaoInstance ??=
        _$Paiementfraisdao(database, changeListener);
  }
}

class _$EntreprisesDao extends EntreprisesDao {
  _$EntreprisesDao(
    this.database,
    this.changeListener,
  ) : _entrepriseModelInsertionAdapter = InsertionAdapter(
            database,
            'entreprises',
            (EntrepriseModel item) => <String, Object?>{
                  'id': item.id,
                  'nom': item.nom,
                  'date_creation': item.date_creation,
                  'date_modification': item.date_modification,
                  'adresse': item.adresse,
                  'numero_id': item.numero_id,
                  'devise': item.devise,
                  'telephone': item.telephone,
                  'email': item.email,
                  'logo': item.logo
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final InsertionAdapter<EntrepriseModel> _entrepriseModelInsertionAdapter;

  @override
  Future<void> insertAll(List<EntrepriseModel> entreprises) async {
    await _entrepriseModelInsertionAdapter.insertList(
        entreprises, OnConflictStrategy.replace);
  }
}

class _$AnneeScolaireDao extends AnneeScolaireDao {
  _$AnneeScolaireDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _anneeScolaireModelInsertionAdapter = InsertionAdapter(
            database,
            'annees_scolaires',
            (AnneeScolaireModel item) => <String, Object?>{
                  'id': item.id,
                  'nom': item.nom,
                  'date_debut': item.date_debut,
                  'date_fin': item.date_fin,
                  'entreprise_id': item.entreprise_id,
                  'en_cours': item.en_cours
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AnneeScolaireModel>
      _anneeScolaireModelInsertionAdapter;

  @override
  Future<AnneeScolaireModel?> getAnneescolaireEnCours() async {
    return _queryAdapter.query(
        'SELECT * FROM annees_scolaires WHERE en_cours = 1',
        mapper: (Map<String, Object?> row) => AnneeScolaireModel(
            id: row['id'] as int,
            nom: row['nom'] as String,
            date_debut: row['date_debut'] as String,
            date_fin: row['date_fin'] as String,
            entreprise_id: row['entreprise_id'] as int,
            en_cours: row['en_cours'] as int?));
  }

  @override
  Future<void> insertAll(List<AnneeScolaireModel> anneeScolaire) async {
    await _anneeScolaireModelInsertionAdapter.insertList(
        anneeScolaire, OnConflictStrategy.replace);
  }
}

class _$FraisScolaireDao extends FraisScolaireDao {
  _$FraisScolaireDao(
    this.database,
    this.changeListener,
  ) : _fraisScolaireModelInsertionAdapter = InsertionAdapter(
            database,
            'frais_scolaires',
            (FraisScolaireModel item) => <String, Object?>{
                  'id': item.id,
                  'nom': item.nom,
                  'montant': item.montant,
                  'annee_scolaire_id': item.annee_scolaire_id,
                  'entreprise_id': item.entreprise_id,
                  'date_limite': item.date_limite
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final InsertionAdapter<FraisScolaireModel>
      _fraisScolaireModelInsertionAdapter;

  @override
  Future<void> insertAll(List<FraisScolaireModel> fraisScolaires) async {
    await _fraisScolaireModelInsertionAdapter.insertList(
        fraisScolaires, OnConflictStrategy.replace);
  }
}

class _$EnseignantDao extends EnseignantDao {
  _$EnseignantDao(
    this.database,
    this.changeListener,
  ) : _enseignantModelInsertionAdapter = InsertionAdapter(
            database,
            'enseignants',
            (EnseignantModel item) => <String, Object?>{
                  'id': item.id,
                  'nom': item.nom,
                  'prenom': item.prenom,
                  'entreprise_id': item.entreprise_id,
                  'matricule': item.matricule,
                  'sexe': item.sexe,
                  'niveau': item.niveau,
                  'discipline': item.discipline,
                  'email': item.email,
                  'telephone': item.telephone
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final InsertionAdapter<EnseignantModel> _enseignantModelInsertionAdapter;

  @override
  Future<void> insertAll(List<EnseignantModel> enseignants) async {
    await _enseignantModelInsertionAdapter.insertList(
        enseignants, OnConflictStrategy.replace);
  }
}

class _$ClassesDao extends ClassesDao {
  _$ClassesDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _classModelInsertionAdapter = InsertionAdapter(
            database,
            'classes',
            (ClassModel item) => <String, Object?>{
                  'id': item.id,
                  'nom': item.nom,
                  'annee_scolaire_id': item.annee_scolaire_id,
                  'code': item.code,
                  'niveau': item.niveau,
                  'effectif': item.effectif,
                  'enseignant_id': item.enseignant_id
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ClassModel> _classModelInsertionAdapter;

  @override
  Future<List<ClassModel>> getAllClasses() async {
    return _queryAdapter.queryList('SELECT * FROM classes',
        mapper: (Map<String, Object?> row) => ClassModel(
            id: row['id'] as int,
            nom: row['nom'] as String,
            annee_scolaire_id: row['annee_scolaire_id'] as int,
            code: row['code'] as String?,
            niveau: row['niveau'] as String?,
            effectif: row['effectif'] as int?,
            enseignant_id: row['enseignant_id'] as int?));
  }

  @override
  Future<int?> getClassesByAnnee(int anneeScolaireId) async {
    return _queryAdapter.query(
        'SELECT * FROM classes WHERE annee_scolaire_id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [anneeScolaireId]);
  }

  @override
  Future<void> insertAll(List<ClassModel> classes) async {
    await _classModelInsertionAdapter.insertList(
        classes, OnConflictStrategy.replace);
  }
}

class _$ResponsableDao extends ResponsableDao {
  _$ResponsableDao(
    this.database,
    this.changeListener,
  ) : _responsableModelInsertionAdapter = InsertionAdapter(
            database,
            'responsables',
            (ResponsableModel item) => <String, Object?>{
                  'id': item.id,
                  'nom': item.nom,
                  'code': item.code,
                  'telephone': item.telephone,
                  'adresse': item.adresse
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final InsertionAdapter<ResponsableModel> _responsableModelInsertionAdapter;

  @override
  Future<void> insertAll(List<ResponsableModel> responsables) async {
    await _responsableModelInsertionAdapter.insertList(
        responsables, OnConflictStrategy.replace);
  }
}

class _$ElevesDao extends ElevesDao {
  _$ElevesDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _eleveModelInsertionAdapter = InsertionAdapter(
            database,
            'eleves',
            (EleveModel item) => <String, Object?>{
                  'id': item.id,
                  'nom': item.nom,
                  'prenom': item.prenom,
                  'postnom': item.postnom,
                  'sexe': item.sexe,
                  'statut': item.statut,
                  'date_naissance': item.date_naissance,
                  'lieu_naissance': item.lieu_naissance,
                  'matricule': item.matricule,
                  'numero_permanent': item.numero_permanent,
                  'classe_id': item.classe_id,
                  'responsable_id': item.responsable_id
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<EleveModel> _eleveModelInsertionAdapter;

  @override
  Future<List<EleveModel>> getAllEleves() async {
    return _queryAdapter.queryList('SELECT * FROM eleves',
        mapper: (Map<String, Object?> row) => EleveModel(
            id: row['id'] as int,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            postnom: row['postnom'] as String?,
            sexe: row['sexe'] as String?,
            statut: row['statut'] as String?,
            date_naissance: row['date_naissance'] as String?,
            lieu_naissance: row['lieu_naissance'] as String?,
            matricule: row['matricule'] as String?,
            numero_permanent: row['numero_permanent'] as String?,
            classe_id: row['classe_id'] as int?,
            responsable_id: row['responsable_id'] as int?));
  }

  @override
  Future<List<EleveModel>> getElevesByClasseId(int classeId) async {
    return _queryAdapter.queryList('SELECT * FROM eleves WHERE classe_id = ?1',
        mapper: (Map<String, Object?> row) => EleveModel(
            id: row['id'] as int,
            nom: row['nom'] as String,
            prenom: row['prenom'] as String,
            postnom: row['postnom'] as String?,
            sexe: row['sexe'] as String?,
            statut: row['statut'] as String?,
            date_naissance: row['date_naissance'] as String?,
            lieu_naissance: row['lieu_naissance'] as String?,
            matricule: row['matricule'] as String?,
            numero_permanent: row['numero_permanent'] as String?,
            classe_id: row['classe_id'] as int?,
            responsable_id: row['responsable_id'] as int?),
        arguments: [classeId]);
  }

  @override
  Future<void> insertAll(List<EleveModel> eleves) async {
    await _eleveModelInsertionAdapter.insertList(
        eleves, OnConflictStrategy.replace);
  }
}

class _$FraisDao extends FraisDao {
  _$FraisDao(
    this.database,
    this.changeListener,
  ) : _fraisModelInsertionAdapter = InsertionAdapter(
            database,
            'frais',
            (FraisModel item) => <String, Object?>{
                  'id': item.id,
                  'nom': item.nom,
                  'montant': item.montant,
                  'code': item.code,
                  'entreprise_id': item.entreprise_id
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final InsertionAdapter<FraisModel> _fraisModelInsertionAdapter;

  @override
  Future<void> insertAll(List<FraisModel> frais) async {
    await _fraisModelInsertionAdapter.insertList(
        frais, OnConflictStrategy.replace);
  }
}

class _$FraisclasseDao extends FraisclasseDao {
  _$FraisclasseDao(
    this.database,
    this.changeListener,
  ) : _fraisClassesModelInsertionAdapter = InsertionAdapter(
            database,
            'frais_classes',
            (FraisClassesModel item) => <String, Object?>{
                  'id': item.id,
                  'frais_id': item.frais_id,
                  'classe_id': item.classe_id
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final InsertionAdapter<FraisClassesModel> _fraisClassesModelInsertionAdapter;

  @override
  Future<void> insertAll(List<FraisClassesModel> fraisClasses) async {
    await _fraisClassesModelInsertionAdapter.insertList(
        fraisClasses, OnConflictStrategy.replace);
  }
}

class _$UtilisateursDao extends UtilisateursDao {
  _$UtilisateursDao(
    this.database,
    this.changeListener,
  ) : _utilisateurModelInsertionAdapter = InsertionAdapter(
            database,
            'utilisateurs',
            (UtilisateurModel item) => <String, Object?>{
                  'id': item.id,
                  'nom': item.nom,
                  'prenom': item.prenom,
                  'email': item.email,
                  'mot_de_passe_hash': item.mot_de_passe_hash,
                  'role': item.role,
                  'entreprise_id': item.entreprise_id,
                  'date_creation': item.date_creation,
                  'date_modification': item.date_modification,
                  'actif': item.actif == null ? null : (item.actif! ? 1 : 0)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final InsertionAdapter<UtilisateurModel> _utilisateurModelInsertionAdapter;

  @override
  Future<void> insertAll(List<UtilisateurModel> utilisateurs) async {
    await _utilisateurModelInsertionAdapter.insertList(
        utilisateurs, OnConflictStrategy.replace);
  }
}

class _$Paiementfraisdao extends Paiementfraisdao {
  _$Paiementfraisdao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _paiementFraisModelInsertionAdapter = InsertionAdapter(
            database,
            'paiement_frais',
            (PaiementFraisModel item) => <String, Object?>{
                  'id': item.id,
                  'eleve_id': item.eleve_id,
                  'frais_scolaire_id': item.frais_scolaire_id,
                  'montant_paye': item.montant_paye,
                  'date_paiement': item.date_paiement,
                  'user_id': item.user_id,
                  'reste_a_payer': item.reste_a_payer,
                  'statut': item.statut
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PaiementFraisModel>
      _paiementFraisModelInsertionAdapter;

  @override
  Future<List<PaiementFraisModel>> getAllPaiementsFrais() async {
    return _queryAdapter.queryList('SELECT * FROM paiement_frais',
        mapper: (Map<String, Object?> row) => PaiementFraisModel(
            id: row['id'] as int,
            eleve_id: row['eleve_id'] as int,
            frais_scolaire_id: row['frais_scolaire_id'] as int,
            montant_paye: row['montant_paye'] as double,
            date_paiement: row['date_paiement'] as String,
            user_id: row['user_id'] as int?,
            reste_a_payer: row['reste_a_payer'] as double?,
            statut: row['statut'] as String?));
  }

  @override
  Future<void> insertAll(List<PaiementFraisModel> paiements) async {
    await _paiementFraisModelInsertionAdapter.insertList(
        paiements, OnConflictStrategy.replace);
  }
}
