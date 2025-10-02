import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'database_service.dart';
import 'school_queries.dart';
import '../config/api_config.dart';

class SyncManager {
  String? _authToken;
  String? _userEmail;

  /// Configure l'authentification pour les requêtes API
  void setAuth(String token, String email) {
    _authToken = token;
    _userEmail = email;
    log('✅ SyncManager: Authentification configurée pour $email');
  }

  /// Nettoie l'authentification
  void clearAuth() {
    _authToken = null;
    _userEmail = null;
    log('✅ SyncManager: Authentification nettoyée');
  }

  /// Vérifie si la base de données locale est vide
  Future<bool> isDatabaseEmpty() async {
    log('=== VÉRIFICATION BASE DE DONNÉES VIDE ===');

    try {
      // Vérifier plusieurs tables importantes
      final entreprises = await SchoolQueries.getAllEntreprises();
      final utilisateurs = await SchoolQueries.getAllUtilisateurs();
      final anneesScol = await SchoolQueries.getAllAnneesScolaires();

      bool isEmpty =
          entreprises.isEmpty && utilisateurs.isEmpty && anneesScol.isEmpty;

      log('Entreprises: ${entreprises.length}');
      log('Utilisateurs: ${utilisateurs.length}');
      log('Années scolaires: ${anneesScol.length}');
      log(isEmpty ? '📊 Base de données VIDE' : '📊 Base de données NON VIDE');

      return isEmpty;
    } catch (e) {
      log('❌ Erreur lors de la vérification BD: $e');
      return true; // Considérer comme vide en cas d'erreur
    }
  }

  /// Télécharge et importe toutes les données depuis le serveur
  Future<bool> importAllDataFromServer({bool clearExisting = false}) async {
    print('=== DÉBUT IMPORTATION COMPLÈTE DEPUIS API ===');
    print('Clear existing: $clearExisting');

    // MODE DÉVELOPPEMENT: Tester d'abord sans authentification
    // car l'utilisateur admin@testschool.com n'a pas accès aux données de test
    print('🔧 MODE DÉVELOPPEMENT: Test sans authentification d\'abord...');

    try {
      bool success = await _downloadDataWithoutAuth(clearExisting);
      if (success) {
        return true;
      }

      // Si échec sans auth, essayer avec auth
      print('⚠️ Échec sans auth, essai avec authentification...');
      return await _downloadDataWithAuth(clearExisting);
    } catch (e, stackTrace) {
      print('❌ Erreur lors de l\'importation complète: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Télécharge les données sans authentification (mode développement)
  Future<bool> _downloadDataWithoutAuth(bool clearExisting) async {
    try {
      // Étape 1: Vider les données existantes si demandé
      if (clearExisting) {
        print('🧹 Nettoyage des données existantes...');
        await _clearAllLocalData();
      }

      // Étape 2: Télécharger les données depuis l'API SANS TOKEN
      print('📥 Téléchargement des données depuis l\'API (SANS TOKEN)...');

      final syncUrl =
          Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.syncDownloadEndpoint}',
          ).replace(
            queryParameters: {
              'since': '1970-01-01T00:00:00.000Z',
              'client_id': 'flutter-client', // Utiliser flutter-client standard
              if (_userEmail != null) 'user_email': _userEmail!,
            },
          );

      print('URL de synchronisation (SANS AUTH): $syncUrl');

      final downloadResponse = await http
          .get(
            syncUrl,
            headers: {
              'Accept': 'application/json',
              // PAS de header Authorization
            },
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      print('Status Code: ${downloadResponse.statusCode}');
      print('Response Body COMPLET: ${downloadResponse.body}');

      if (downloadResponse.statusCode == 200) {
        final responseData = jsonDecode(downloadResponse.body);
        print('✅ Données téléchargées avec succès (SANS AUTH)');
        return await _processDownloadedData(responseData);
      } else {
        print(
          '❌ Erreur lors du téléchargement (SANS AUTH): ${downloadResponse.statusCode}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Erreur dans _downloadDataWithoutAuth: $e');
      return false;
    }
  }

  /// Télécharge les données avec authentification
  Future<bool> _downloadDataWithAuth(bool clearExisting) async {
    if (_authToken == null) {
      print('❌ Aucun token d\'authentification');
      return false;
    }

    try {
      // Étape 1: Vider les données existantes si demandé
      if (clearExisting) {
        print('🧹 Nettoyage des données existantes...');
        await _clearAllLocalData();
      }

      // Étape 2: Télécharger les données depuis l'API AVEC TOKEN
      print('📥 Téléchargement des données depuis l\'API (AVEC TOKEN)...');

      final syncUrl =
          Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.syncDownloadEndpoint}',
          ).replace(
            queryParameters: {
              'since': '1970-01-01T00:00:00.000Z',
              'client_id': 'flutter-client',
              if (_userEmail != null) 'user_email': _userEmail!,
            },
          );

      print('URL de synchronisation (AVEC AUTH): $syncUrl');

      final downloadResponse = await http
          .get(
            syncUrl,
            headers: {
              'Authorization': 'Bearer $_authToken',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      print('Status Code: ${downloadResponse.statusCode}');
      print('Response Body COMPLET: ${downloadResponse.body}');

      if (downloadResponse.statusCode == 200) {
        final responseData = jsonDecode(downloadResponse.body);
        print('✅ Données téléchargées avec succès (AVEC AUTH)');
        return await _processDownloadedData(responseData);
      } else {
        print(
          '❌ Erreur lors du téléchargement (AVEC AUTH): ${downloadResponse.statusCode}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Erreur dans _downloadDataWithAuth: $e');
      return false;
    }
  }

  /// Traite les données téléchargées
  Future<bool> _processDownloadedData(Map<String, dynamic> responseData) async {
    print('Type de réponse: ${responseData.runtimeType}');
    print('Contenu de la réponse: $responseData');

    // Vérifier si l'API retourne explicitement qu'il n'y a pas de données
    if (responseData.containsKey('total') && responseData['total'] == 0) {
      print(
        'ℹ️ L\'API indique explicitement qu\'il n\'y a pas de données (total: 0)',
      );
      print('⚠️ Cela peut indiquer que:');
      print('   - La base de données du serveur est vide');
      print('   - L\'utilisateur n\'a pas accès aux données');
      print('   - Il faut configurer des données de test sur le serveur');
      return true; // Considérer comme succès même sans données
    }

    // Traiter le format de réponse de l'API (structure changes avec table/data)
    List<Map<String, dynamic>> changes = [];
    if (responseData.containsKey('changes')) {
      changes = List<Map<String, dynamic>>.from(responseData['changes']);
      print('📦 Changes extraites: ${changes.length} éléments');
    }

    print('Nombre total de changements reçus: ${changes.length}');

    // Convertir les changes au format attendu par _insertAllDataInOrder
    final allData = _convertChangesToTableData(changes);

    // Étape 3: Insérer les données dans l'ordre des dépendances
    await _insertAllDataInOrder(allData);

    if (changes.isEmpty) {
      print('⚠️ IMPORTATION TERMINÉE MAIS AUCUNE DONNÉE REÇUE');
      return true; // Considérer comme succès car l'API a répondu correctement
    } else {
      print('✅ IMPORTATION COMPLÈTE RÉUSSIE');
    }

    return true;
  }

  /// Nettoie toutes les données locales selon l'ordre des dépendances
  Future<void> _clearAllLocalData() async {
    log('=== NETTOYAGE DONNÉES LOCALES ===');

    try {
      final db = await DatabaseService.database;

      // Supprimer dans l'ordre inverse des dépendances basé sur votre schéma
      final tables = [
        'ecritures_comptables',
        'notes_periode',
        'frais_classes',
        'cours',
        'periodes_classes',
        'depenses',
        'journaux_comptables',
        'creances',
        'paiement_frais',
        'eleves',
        'classes',
        'periodes',
        'frais_scolaires',
        'config_ecole',
        'comptes_config',
        'comptes_comptables',
        'classes_comptables',
        'enseignants',
        'licence',
        'annees_scolaires',
        'responsables',
        'utilisateurs',
        'entreprises',
        'sync_metadata',
      ];

      for (final table in tables) {
        try {
          await db.delete(table);
          log('🗑️ Table $table vidée');
        } catch (e) {
          log('⚠️ Erreur lors du vidage de la table $table: $e');
        }
      }

      log('✅ Données locales nettoyées');
    } catch (e) {
      log('❌ Erreur lors du nettoyage: $e');
      rethrow;
    }
  }

  /// Convertit les changes de l'API au format attendu par les insertions
  Map<String, List<Map<String, dynamic>>> _convertChangesToTableData(
    List<Map<String, dynamic>> changes,
  ) {
    print('=== CONVERSION DES CHANGES ===');

    final tableData = <String, List<Map<String, dynamic>>>{};

    // Grouper les changes par table
    for (final change in changes) {
      final tableName = change['table'] as String?;
      final data = change['data'] as Map<String, dynamic>?;

      if (tableName != null && data != null) {
        if (!tableData.containsKey(tableName)) {
          tableData[tableName] = <Map<String, dynamic>>[];
        }
        tableData[tableName]!.add(data);
      }
    }

    // Log du résultat
    for (final entry in tableData.entries) {
      print('📋 ${entry.key}: ${entry.value.length} enregistrements');
    }

    print('✅ Conversion terminée: ${tableData.keys.length} tables');
    return tableData;
  }

  /// Insère toutes les données dans l'ordre des dépendances
  Future<void> _insertAllDataInOrder(
    Map<String, List<Map<String, dynamic>>> allData,
  ) async {
    print('=== INSERTION DES DONNÉES DANS L\'ORDRE ===');

    try {
      final db = await DatabaseService.database;

      // Ordre d'insertion basé sur les dépendances de votre schéma

      // 1. Tables sans dépendances
      await _insertTableData(db, 'entreprises', allData['entreprises']);
      await _insertTableData(db, 'responsables', allData['responsables']);

      // 🔧 MARQUER LE DÉBUT DE SYNCHRONISATION dans sync_metadata (table locale seulement)
      await _markSyncInProgress(db);

      // 2. Tables dépendantes d'entreprise
      await _insertTableData(db, 'utilisateurs', allData['utilisateurs']);
      await _insertTableData(
        db,
        'annees_scolaires',
        allData['annees_scolaires'],
      );
      await _insertTableData(db, 'enseignants', allData['enseignants']);
      await _insertTableData(
        db,
        'classes_comptables',
        allData['classes_comptables'],
      );
      await _insertTableData(db, 'licence', allData['licence']);

      // 3. Tables dépendantes d'années scolaires et autres
      await _insertTableData(db, 'classes', allData['classes']);
      await _insertTableData(db, 'periodes', allData['periodes']);
      await _insertTableData(db, 'frais_scolaires', allData['frais_scolaires']);
      await _insertTableData(db, 'config_ecole', allData['config_ecole']);

      // 4. Tables dépendantes de classes comptables
      await _insertTableData(
        db,
        'comptes_comptables',
        allData['comptes_comptables'],
      );

      // 5. Tables de configuration comptable
      await _insertTableData(db, 'comptes_config', allData['comptes_config']);

      // 6. Tables dépendantes de classes
      await _insertTableData(db, 'eleves', allData['eleves']);
      await _insertTableData(db, 'cours', allData['cours']);
      await _insertTableData(
        db,
        'periodes_classes',
        allData['periodes_classes'],
      );
      await _insertTableData(db, 'frais_classes', allData['frais_classes']);

      // 7. Tables transactionnelles
      await _insertTableData(db, 'paiement_frais', allData['paiement_frais']);
      await _insertTableData(db, 'creances', allData['creances']);
      await _insertTableData(
        db,
        'journaux_comptables',
        allData['journaux_comptables'],
      );
      await _insertTableData(db, 'depenses', allData['depenses']);

      // 8. Tables pédagogiques
      await _insertTableData(db, 'notes_periode', allData['notes_periode']);

      // 9. Tables comptables finales
      await _insertTableData(
        db,
        'ecritures_comptables',
        allData['ecritures_comptables'],
      );

      print('✅ Toutes les données insérées avec succès');

      // Afficher le chemin de la base de données
      await _logDatabaseInfo(db);

      // Vérifier les données insérées
      await _verifyInsertedData(db);
    } catch (e, stackTrace) {
      print('❌ Erreur lors de l\'insertion des données: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 🔧 Marque le début d'une synchronisation dans sync_metadata (table locale uniquement)
  Future<void> _markSyncInProgress(db) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Insérer ou remplacer l'enregistrement avec key = 'last_sync_date'
      await db.rawInsert(
        '''INSERT OR REPLACE INTO sync_metadata (id, key, value, updated_at) 
           VALUES ((SELECT id FROM sync_metadata WHERE key = 'last_sync_date'), 'last_sync_date', 'Synchronisation en cours...', ?)''',
        [now],
      );

      print('🔄 sync_metadata: Synchronisation marquée à $now');
    } catch (e) {
      print('⚠️ Erreur lors du marquage de synchronisation: $e');
    }
  }

  /// Insère les données d'une table spécifique
  Future<void> _insertTableData(
    db,
    String tableName,
    List<dynamic>? data,
  ) async {
    if (data == null || data.isEmpty) {
      print('⏭️ Aucune donnée pour la table $tableName');
      return;
    }

    print('📋 Insertion de ${data.length} éléments dans $tableName...');

    int successCount = 0;
    int errorCount = 0;

    // Afficher un échantillon des données à insérer
    if (data.isNotEmpty) {
      print('🔍 Exemple de donnée à insérer dans $tableName:');
      final sample = data.first as Map<String, dynamic>;
      sample.forEach((key, value) {
        final displayValue = value.toString().length > 50
            ? '${value.toString().substring(0, 50)}...'
            : value.toString();
        print('   • $key: $displayValue');
      });
    }

    for (final item in data) {
      try {
        final itemToInsert = Map<String, dynamic>.from(
          item as Map<String, dynamic>,
        );

        // Traitement spécial pour sync_metadata : mettre à jour updated_at avec la date actuelle
        if (tableName == 'sync_metadata') {
          final now = DateTime.now().toIso8601String();
          itemToInsert['updated_at'] = now;
          print(
            '🔄 sync_metadata: updated_at mis à jour avec la date actuelle: $now',
          );
        }

        await db.insert(tableName, itemToInsert);
        successCount++;
      } catch (e) {
        errorCount++;
        print(
          '⚠️ Erreur lors de l\'insertion d\'un élément dans $tableName: $e',
        );
        print(
          'Données problématiques: ${item.toString().length > 300 ? item.toString().substring(0, 300) + "..." : item.toString()}',
        );
      }
    }

    if (errorCount == 0) {
      print('✅ $tableName: $successCount éléments insérés avec succès');
    } else {
      print('⚠️ $tableName: $successCount réussies, $errorCount erreurs');
    }
  }

  /// Met à jour la date de synchronisation dans sync_metadata
  Future<void> updateSyncTimestamp() async {
    log('=== MISE À JOUR DATE DE SYNCHRONISATION FINALE ===');

    try {
      final db = await DatabaseService.database;
      final now = DateTime.now().toIso8601String();

      // Insérer ou remplacer l'enregistrement avec key = 'last_sync_date'
      await db.rawInsert(
        '''INSERT OR REPLACE INTO sync_metadata (id, key, value, updated_at) 
           VALUES ((SELECT id FROM sync_metadata WHERE key = 'last_sync_date'), 'last_sync_date', 'Synchronisation complète effectuée', ?)''',
        [now],
      );

      log('✅ Date de synchronisation FINALE mise à jour: $now');

      // 🔍 DEBUG: Vérifier l'enregistrement final
      final checkRecord = await db.query(
        'sync_metadata',
        where: 'key = ?',
        whereArgs: ['last_sync_date'],
      );
      log(
        '🔍 Enregistrement final sync_metadata: ${checkRecord.isNotEmpty ? checkRecord.first : 'AUCUN'}',
      );
    } catch (e) {
      log('❌ Erreur lors de la mise à jour de sync_metadata: $e');
      rethrow;
    }
  }

  /// Vérifie les suppressions sur le serveur
  Future<bool> checkServerDeletions() async {
    log('=== VÉRIFICATION DES SUPPRESSIONS SERVEUR ===');

    if (_authToken == null) {
      log('❌ Aucun token d\'authentification');
      return false;
    }

    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}${ApiConfig.syncCheckDeletionsEndpoint}',
            ),
            headers: {
              'Authorization': 'Bearer $_authToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      log('Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final deletions = jsonDecode(response.body);

        if (deletions['deletions'] != null &&
            deletions['deletions'].isNotEmpty) {
          await _applyServerDeletions(deletions['deletions']);
        } else {
          log('ℹ️ Aucune suppression à appliquer');
        }

        return true;
      } else {
        log(
          '❌ Erreur lors de la vérification des suppressions: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      log('❌ Exception lors de la vérification des suppressions: $e');
      return false;
    }
  }

  /// Applique les suppressions reçues du serveur
  Future<void> _applyServerDeletions(List<dynamic> deletions) async {
    log('=== APPLICATION DES SUPPRESSIONS SERVEUR ===');

    try {
      final db = await DatabaseService.database;

      for (final deletion in deletions) {
        final tableName = deletion['table'];
        final recordId = deletion['id'];

        if (tableName != null && recordId != null) {
          await db.delete(tableName, where: 'id = ?', whereArgs: [recordId]);
          log('🗑️ Supprimé: $tableName ID $recordId');
        }
      }

      log('✅ ${deletions.length} suppressions appliquées');
    } catch (e) {
      log('❌ Erreur lors de l\'application des suppressions: $e');
      rethrow;
    }
  }

  /// Synchronisation complète (download seulement)
  Future<bool> performFullSync() async {
    log('=== DÉBUT SYNCHRONISATION DEPUIS SERVEUR ===');

    try {
      // 1. Télécharger les données depuis le serveur
      bool downloadSuccess = await importAllDataFromServer(
        clearExisting: false,
      );
      if (!downloadSuccess) {
        log('❌ Échec du téléchargement des données');
        return false;
      }

      // 2. Vérifier et appliquer les suppressions
      bool deletionsSuccess = await checkServerDeletions();
      if (!deletionsSuccess) {
        log(
          '⚠️ Échec de la vérification des suppressions, mais téléchargement réussi',
        );
      }

      // 3. Mettre à jour le timestamp de synchronisation
      await updateSyncTimestamp();

      log('✅ SYNCHRONISATION DEPUIS SERVEUR RÉUSSIE');
      return true;
    } catch (e) {
      log('❌ Erreur lors de la synchronisation: $e');
      return false;
    }
  }

  /// Envoie les écritures comptables locales vers le serveur
  /// Groupe les écritures par journal_id pour maintenir l'intégrité comptable
  Future<bool> syncEcrituresComptablesToServer() async {
    log('=== SYNCHRONISATION ÉCRITURES COMPTABLES VERS SERVEUR ===');

    if (_authToken == null) {
      log('❌ Aucun token d\'authentification');
      return false;
    }

    try {
      final db = await DatabaseService.database;

      // 1. Récupérer toutes les écritures comptables non synchronisées
      final unsyncedEcritures = await db.rawQuery('''
        SELECT * FROM ecritures_comptables 
        WHERE synced = 0 OR synced IS NULL
        ORDER BY journal_id, date_creation
      ''');

      if (unsyncedEcritures.isEmpty) {
        log('ℹ️ Aucune écriture comptable à synchroniser');
        return true;
      }

      log('📊 ${unsyncedEcritures.length} écritures comptables à synchroniser');

      // 2. Grouper les écritures par journal_id
      Map<int, List<Map<String, dynamic>>> ecrituresParJournal = {};
      for (final ecriture in unsyncedEcritures) {
        final journalId = ecriture['journal_id'] as int;
        if (!ecrituresParJournal.containsKey(journalId)) {
          ecrituresParJournal[journalId] = [];
        }
        ecrituresParJournal[journalId]!.add(ecriture);
      }

      log(
        '📋 ${ecrituresParJournal.length} journaux différents à synchroniser',
      );

      // 3. Envoyer chaque groupe de journal séparément
      int successCount = 0;
      int errorCount = 0;

      for (final journalId in ecrituresParJournal.keys) {
        final ecrituresJournal = ecrituresParJournal[journalId]!;

        // Vérifier l'équilibre débit/crédit pour ce journal
        double totalDebit = 0;
        double totalCredit = 0;

        for (final ecriture in ecrituresJournal) {
          totalDebit += (ecriture['debit'] as num?)?.toDouble() ?? 0;
          totalCredit += (ecriture['credit'] as num?)?.toDouble() ?? 0;
        }

        // Log de l'équilibre
        log(
          '💰 Journal $journalId: ${ecrituresJournal.length} écritures, Débit: $totalDebit, Crédit: $totalCredit',
        );

        if ((totalDebit - totalCredit).abs() > 0.01) {
          log(
            '⚠️ ATTENTION: Journal $journalId déséquilibré (Débit: $totalDebit, Crédit: $totalCredit)',
          );
        }

        // Préparer les données pour l'envoi
        final journalData = {
          'journal_id': journalId,
          'ecritures': ecrituresJournal
              .map(
                (ecriture) => {
                  'id': ecriture['id'],
                  'compte_comptable_id':
                      ecriture['compte_comptable_id'], // Utiliser le nom correct du schéma
                  'libelle': ecriture['libelle'],
                  'debit': ecriture['debit'],
                  'credit': ecriture['credit'],
                  'ordre': ecriture['ordre'],
                  'date_ecriture': ecriture['date_ecriture'],
                  'reference': ecriture['reference'],
                  'date_creation': ecriture['date_creation'],
                  'date_modification': ecriture['date_modification'],
                },
              )
              .toList(),
          'metadata': {
            'total_debit': totalDebit,
            'total_credit': totalCredit,
            'equilibre': (totalDebit - totalCredit).abs() <= 0.01,
            'nb_ecritures': ecrituresJournal.length,
          },
        };

        // Envoyer vers le serveur
        bool success = await _sendJournalToServer(journalData);

        if (success) {
          successCount++;
          // Marquer les écritures de ce journal comme synchronisées
          await _markJournalAsSynced(db, journalId, ecrituresJournal);
        } else {
          errorCount++;
          log('❌ Échec de synchronisation du journal $journalId');
        }
      }

      log(
        '✅ Synchronisation terminée: $successCount journaux réussis, $errorCount échecs',
      );
      return errorCount == 0;
    } catch (e, stackTrace) {
      log('❌ Erreur lors de la synchronisation des écritures comptables: $e');
      log('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Envoie un journal comptable vers le serveur
  Future<bool> _sendJournalToServer(Map<String, dynamic> journalData) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.syncUploadEndpoint}'),
            headers: {
              'Authorization': 'Bearer $_authToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'table': 'ecritures_comptables',
              'data_type': 'journal_transaction',
              'journal_data': journalData,
            }),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      log(
        '📡 Envoi journal ${journalData['journal_id']}: Status ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('✅ Journal ${journalData['journal_id']} synchronisé avec succès');
        return true;
      } else {
        log(
          '❌ Erreur serveur pour journal ${journalData['journal_id']}: ${response.statusCode}',
        );
        log('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      log(
        '❌ Exception lors de l\'envoi du journal ${journalData['journal_id']}: $e',
      );
      return false;
    }
  }

  /// Marque les écritures d'un journal comme synchronisées
  Future<void> _markJournalAsSynced(
    db,
    int journalId,
    List<Map<String, dynamic>> ecritures,
  ) async {
    try {
      final ecritureIds = ecritures.map((e) => e['id']).toList();
      final placeholders = List.filled(ecritureIds.length, '?').join(',');

      await db.rawUpdate(
        'UPDATE ecritures_comptables SET synced = 1 WHERE id IN ($placeholders)',
        ecritureIds,
      );

      log(
        '✅ ${ecritures.length} écritures du journal $journalId marquées comme synchronisées',
      );
    } catch (e) {
      log('❌ Erreur lors du marquage de synchronisation: $e');
      rethrow;
    }
  }

  /// Synchronise toutes les données locales vers le serveur
  Future<bool> syncAllLocalDataToServer() async {
    log('=== SYNCHRONISATION COMPLÈTE VERS SERVEUR ===');

    if (_authToken == null) {
      log('❌ Aucun token d\'authentification');
      return false;
    }

    try {
      // 1. Synchroniser les écritures comptables (traitement spécialisé)
      log('📊 Étape 1: Synchronisation des écritures comptables...');
      bool ecrituresSuccess = await syncEcrituresComptablesToServer();

      if (!ecrituresSuccess) {
        log('⚠️ Échec partiel de la synchronisation des écritures comptables');
      }

      // 2. Synchroniser les autres données modifiées
      log('📋 Étape 2: Synchronisation des autres données...');
      bool otherDataSuccess = await _syncOtherDataToServer();

      if (ecrituresSuccess && otherDataSuccess) {
        log('✅ SYNCHRONISATION COMPLÈTE RÉUSSIE');
        return true;
      } else {
        log('⚠️ SYNCHRONISATION PARTIELLEMENT RÉUSSIE');
        log('Écritures comptables: ${ecrituresSuccess ? "✅" : "❌"}');
        log('Autres données: ${otherDataSuccess ? "✅" : "❌"}');
        return false;
      }
    } catch (e, stackTrace) {
      log('❌ Erreur lors de la synchronisation complète: $e');
      log('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Force la synchronisation de TOUTES les données locales (même déjà synchronisées)
  /// Utile pour la synchronisation initiale ou après réinstallation
  Future<bool> forceFullDataUpload() async {
    log('=== SYNCHRONISATION FORCÉE DE TOUTES LES DONNÉES ===');

    if (_authToken == null) {
      log('❌ Aucun token d\'authentification requis');
      return false;
    }

    try {
      final db = await DatabaseService.database;

      // Marquer temporairement toutes les données comme non synchronisées
      log('🔄 Marquage de toutes les données comme non synchronisées...');
      await _markAllDataAsUnsynced(db);

      // Procéder à la synchronisation normale
      bool success = await syncAllLocalDataToServer();

      if (success) {
        log(
          '✅ SYNCHRONISATION FORCÉE RÉUSSIE - Toutes les données ont été envoyées',
        );
      } else {
        log('⚠️ SYNCHRONISATION FORCÉE PARTIELLE - Voir les logs pour détails');
      }

      return success;
    } catch (e, stackTrace) {
      log('❌ Erreur lors de la synchronisation forcée: $e');
      log('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Marque toutes les données comme non synchronisées pour forcer l'upload
  Future<void> _markAllDataAsUnsynced(db) async {
    try {
      // Liste de toutes les tables avec données utilisateur (exclut sync_metadata)
      final allTables = [
        'entreprises',
        'utilisateurs',
        'annees_scolaires',
        'enseignants',
        'classes_comptables',
        'comptes_comptables',
        'frais_scolaires',
        'config_ecole',
        'comptes_config',
        'licence',
        'responsables',
        'classes',
        'periodes',
        'eleves',
        'cours',
        'frais_classes',
        'periodes_classes',
        'paiement_frais',
        'creances',
        'journaux_comptables',
        'depenses',
        'notes_periode',
        'ecritures_comptables',
      ];

      for (final tableName in allTables) {
        try {
          final tableExists = await _doesTableExist(db, tableName);
          if (tableExists) {
            final result = await db.rawUpdate(
              'UPDATE $tableName SET synced = 0',
            );
            log(
              '🔄 $tableName: $result enregistrements marqués pour synchronisation',
            );
          }
        } catch (e) {
          log('⚠️ Erreur marquage table $tableName: $e');
        }
      }

      log('✅ Marquage terminé - Toutes les données seront synchronisées');
    } catch (e) {
      log('❌ Erreur lors du marquage global: $e');
      rethrow;
    }
  }

  /// Obtient des statistiques sur les données à synchroniser
  Future<Map<String, int>> getSyncStatistics() async {
    try {
      final db = await DatabaseService.database;
      Map<String, int> stats = {};

      final allTables = [
        'entreprises',
        'utilisateurs',
        'annees_scolaires',
        'enseignants',
        'classes_comptables',
        'comptes_comptables',
        'frais_scolaires',
        'config_ecole',
        'comptes_config',
        'licence',
        'responsables',
        'classes',
        'periodes',
        'eleves',
        'cours',
        'frais_classes',
        'periodes_classes',
        'paiement_frais',
        'creances',
        'journaux_comptables',
        'depenses',
        'notes_periode',
        'ecritures_comptables',
      ];

      int totalUnsynced = 0;
      int totalRecords = 0;

      for (final tableName in allTables) {
        try {
          final tableExists = await _doesTableExist(db, tableName);
          if (tableExists) {
            // Compter les enregistrements non synchronisés
            final unsyncedResult = await db.rawQuery(
              'SELECT COUNT(*) as count FROM $tableName WHERE synced = 0 OR synced IS NULL',
            );
            final unsyncedCount = unsyncedResult.first['count'] as int;

            // Compter le total des enregistrements
            final totalResult = await db.rawQuery(
              'SELECT COUNT(*) as count FROM $tableName',
            );
            final tableTotal = totalResult.first['count'] as int;

            if (unsyncedCount > 0) {
              stats[tableName] = unsyncedCount;
              totalUnsynced += unsyncedCount;
            }
            totalRecords += tableTotal;
          }
        } catch (e) {
          log('⚠️ Erreur stats table $tableName: $e');
        }
      }

      stats['_total_unsynced'] = totalUnsynced;
      stats['_total_records'] = totalRecords;
      stats['_tables_with_unsynced_data'] =
          stats.length - 2; // Exclure les 2 totaux

      return stats;
    } catch (e) {
      log('❌ Erreur lors du calcul des statistiques: $e');
      return {};
    }
  }

  /// Synchronise les autres données (non comptables) vers le serveur
  Future<bool> _syncOtherDataToServer() async {
    try {
      final db = await DatabaseService.database;

      // Tables à synchroniser dans l'ordre de dépendance (parents avant enfants)
      // Exclut ecritures_comptables (logique spécialisée) et sync_metadata (métadonnées)
      final tablesToSync = [
        // 1. Tables de base sans dépendances
        'entreprises',

        // 2. Tables dépendantes des entreprises
        'utilisateurs',
        'annees_scolaires',
        'enseignants',
        'classes_comptables',
        'comptes_comptables',
        'frais_scolaires',
        'config_ecole',
        'comptes_config',
        'licence',
        'responsables',

        // 3. Tables dépendantes des années scolaires
        'classes',
        'periodes',

        // 4. Tables dépendantes des classes/périodes
        'eleves',
        'cours',
        'frais_classes',
        'periodes_classes',

        // 5. Tables de transactions (dernières car dépendent de tout)
        'paiement_frais',
        'creances',
        'journaux_comptables',
        'depenses',
        'notes_periode',
      ];

      bool allSuccess = true;
      int totalSyncedRecords = 0;
      int tablesWithData = 0;
      int emptyTables = 0;

      log('📊 Démarrage synchronisation de ${tablesToSync.length} tables...');

      for (final tableName in tablesToSync) {
        try {
          // Vérifier d'abord si la table existe dans la base
          final tableExists = await _doesTableExist(db, tableName);
          if (!tableExists) {
            log('⚠️ Table $tableName n\'existe pas dans la base de données');
            continue;
          }

          // Récupérer les enregistrements non synchronisés
          final unsyncedRecords = await db.rawQuery('''
            SELECT * FROM $tableName 
            WHERE synced = 0 OR synced IS NULL
          ''');

          if (unsyncedRecords.isNotEmpty) {
            tablesWithData++;
            log(
              '📤 Synchronisation de ${unsyncedRecords.length} enregistrements de $tableName',
            );

            // Découper en petits lots pour éviter les timeouts
            const batchSize = 100; // Envoyer par lots de 100 enregistrements
            int processedRecords = 0;

            for (int i = 0; i < unsyncedRecords.length; i += batchSize) {
              final endIndex = (i + batchSize < unsyncedRecords.length)
                  ? i + batchSize
                  : unsyncedRecords.length;
              final batch = unsyncedRecords.sublist(i, endIndex);

              log(
                '📦 Envoi du lot ${(i ~/ batchSize) + 1} pour $tableName (${batch.length} enregistrements)',
              );

              bool batchSuccess = await _sendTableDataToServer(
                tableName,
                batch,
                batchNumber: (i ~/ batchSize) + 1,
              );

              if (batchSuccess) {
                // Marquer ce lot comme synchronisé
                await _markTableRecordsAsSynced(db, tableName, batch);
                processedRecords += batch.length;
                totalSyncedRecords += batch.length;
              } else {
                allSuccess = false;
                log(
                  '❌ Échec de synchronisation du lot ${(i ~/ batchSize) + 1} pour la table $tableName',
                );
                break; // Arrêter les autres lots de cette table en cas d'échec
              }

              // Petit délai entre les lots pour éviter de surcharger le serveur
              await Future.delayed(const Duration(milliseconds: 500));
            }

            log(
              '✅ $tableName: $processedRecords/${unsyncedRecords.length} enregistrements synchronisés',
            );
          } else {
            emptyTables++;
            log('✅ Table $tableName: aucune donnée à synchroniser');
          }
        } catch (e) {
          log('❌ Erreur pour la table $tableName: $e');
          allSuccess = false;
        }
      }

      log('📊 BILAN SYNCHRONISATION:');
      log('  • Total tables traitées: ${tablesToSync.length}');
      log('  • Tables avec données: $tablesWithData');
      log('  • Tables vides: $emptyTables');
      log('  • Total enregistrements synchronisés: $totalSyncedRecords');
      log('  • Succès global: ${allSuccess ? "OUI" : "PARTIEL"}');

      return allSuccess;
    } catch (e) {
      log('❌ Erreur lors de la synchronisation des autres données: $e');
      return false;
    }
  }

  /// Vérifier si une table existe dans la base de données
  Future<bool> _doesTableExist(db, String tableName) async {
    try {
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName],
      );
      return result.isNotEmpty;
    } catch (e) {
      log('⚠️ Erreur lors de la vérification de la table $tableName: $e');
      return false;
    }
  }

  /// Envoie les données d'une table vers le serveur
  Future<bool> _sendTableDataToServer(
    String tableName,
    List<Map<String, dynamic>> records, {
    int? batchNumber,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.syncUploadEndpoint}'),
            headers: {
              'Authorization': 'Bearer $_authToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'table': tableName,
              'data_type': 'table_records',
              'records': records,
              'metadata': {
                'count': records.length,
                'timestamp': DateTime.now().toIso8601String(),
                'batch_number': batchNumber,
                'has_more_batches': batchNumber != null,
              },
            }),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      log('📡 Envoi $tableName: Status ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('✅ Table $tableName synchronisée avec succès');
        return true;
      } else {
        log('❌ Erreur serveur pour $tableName: ${response.statusCode}');
        log('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      log('❌ Exception lors de l\'envoi de $tableName: $e');
      return false;
    }
  }

  /// Marque les enregistrements d'une table comme synchronisés
  Future<void> _markTableRecordsAsSynced(
    db,
    String tableName,
    List<Map<String, dynamic>> records,
  ) async {
    try {
      final recordIds = records.map((r) => r['id']).toList();
      final placeholders = List.filled(recordIds.length, '?').join(',');

      await db.rawUpdate(
        'UPDATE $tableName SET synced = 1 WHERE id IN ($placeholders)',
        recordIds,
      );

      log(
        '✅ ${records.length} enregistrements de $tableName marqués comme synchronisés',
      );
    } catch (e) {
      log('❌ Erreur lors du marquage de synchronisation pour $tableName: $e');
      rethrow;
    }
  }

  /// Affiche les informations sur la base de données
  Future<void> _logDatabaseInfo(db) async {
    try {
      print('=== INFORMATIONS BASE DE DONNÉES ===');

      // Obtenir la référence de la base de données
      await DatabaseService.database;
      print(
        '📍 Base de données: ayanna_school.db (dans le répertoire documents de l\'app)',
      );

      // Obtenir la version de la base de données (méthode alternative)
      try {
        final versionResult = await db.rawQuery('PRAGMA user_version');
        final version = versionResult.isNotEmpty
            ? versionResult.first['user_version']
            : 0;
        print('🔢 Version de la base de données: $version');
      } catch (e) {
        print('⚠️ Impossible d\'obtenir la version: $e');
      }

      // Obtenir des statistiques générales
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      print('🗂️ Nombre de tables: ${tables.length}');
      print(
        '📋 Tables disponibles: ${tables.map((t) => t['name']).join(', ')}',
      );
    } catch (e) {
      print('❌ Erreur lors de la récupération des infos BD: $e');
    }
  }

  /// Vérifie et affiche les données insérées dans la base locale
  Future<void> _verifyInsertedData(db) async {
    print('=== VÉRIFICATION DES DONNÉES INSÉRÉES ===');

    try {
      // Liste des tables principales à vérifier
      final tablesToCheck = [
        'entreprises',
        'utilisateurs',
        'annees_scolaires',
        'classes',
        'eleves',
        'enseignants',
      ];

      int totalRecords = 0;

      for (final tableName in tablesToCheck) {
        try {
          // Compter d'abord tous les enregistrements
          final countResult = await db.rawQuery(
            'SELECT COUNT(*) as count FROM $tableName',
          );
          final totalCount = countResult.first['count'] as int;
          totalRecords += totalCount;

          print('📋 Table $tableName: $totalCount enregistrements au total');

          if (totalCount > 0) {
            // Récupérer quelques exemples de données pour les afficher
            final result = await db.query(tableName, limit: 2);

            for (int i = 0; i < result.length; i++) {
              final record = result[i];
              print('   🔍 Enregistrement ${i + 1}:');

              // Afficher chaque champ de manière lisible
              record.forEach((key, value) {
                final displayValue = value.toString().length > 100
                    ? '${value.toString().substring(0, 100)}...'
                    : value.toString();
                print('      • $key: $displayValue');
              });
              print(''); // Ligne vide pour séparer les enregistrements
            }
          } else {
            print('   ⚠️ Aucune donnée dans cette table');
          }
        } catch (e) {
          print('⚠️ Erreur lors de la vérification de $tableName: $e');
        }
      }

      print(
        '📊 RÉSUMÉ: $totalRecords enregistrements au total dans les tables principales',
      );
      print('✅ Vérification terminée');
    } catch (e) {
      print('❌ Erreur lors de la vérification: $e');
    }
  }
}
