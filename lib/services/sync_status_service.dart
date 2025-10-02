import 'database_service.dart';
import '../models/models.dart';

class SyncStatusService {
  /// Récupère la date de la dernière synchronisation depuis sync_metadata
  static Future<SyncMetadata?> getLastSyncDate() async {
    try {
      final db = await DatabaseService.database;

      // D'abord chercher l'enregistrement spécifique 'last_sync_date'
      var result = await db.query(
        'sync_metadata',
        where: 'key = ?',
        whereArgs: ['last_sync_date'],
        limit: 1,
      );

      // Si pas trouvé, prendre n'importe quel enregistrement avec updated_at le plus récent
      // (cela correspond aux données insérées lors de la synchronisation serveur)
      if (result.isEmpty) {
        result = await db.query(
          'sync_metadata',
          where: 'updated_at IS NOT NULL',
          orderBy: 'updated_at DESC',
          limit: 1,
        );
      }

      if (result.isNotEmpty) {
        return SyncMetadata.fromMap(result.first);
      }

      return null;
    } catch (e) {
      print('Erreur lors de la récupération de la dernière sync: $e');
      return null;
    }
  }

  /// 🔍 DEBUG: Affiche les dates sync_metadata avec des icônes remarquables
  /// Cette fonction doit être appelée après les insertions de données du serveur
  static Future<void> debugSyncMetadataDates() async {
    try {
      final db = await DatabaseService.database;

      print('🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦');
      print('🔍 DEBUG SYNC_METADATA DATES 🔍');
      print('🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦');

      // Récupérer TOUS les enregistrements sync_metadata
      final allRecords = await db.query(
        'sync_metadata',
        orderBy: 'updated_at DESC',
      );

      if (allRecords.isEmpty) {
        print('⚠️  AUCUN ENREGISTREMENT dans sync_metadata !');
      } else {
        print('📊 TOTAL: ${allRecords.length} enregistrements sync_metadata');

        for (int i = 0; i < allRecords.length; i++) {
          final record = allRecords[i];
          final key = record['key'];
          final value = record['value'];
          final updatedAt = record['updated_at'];

          print('');
          print('🔸 Enregistrement ${i + 1}:');
          print('   🔑 Key: $key');
          print('   📝 Value: $value');
          print('   ⏰ Updated_at: $updatedAt');

          if (updatedAt != null) {
            try {
              final dateTime = DateTime.parse(updatedAt.toString());
              final now = DateTime.now();
              final diff = now.difference(dateTime);

              print('   🕐 Date parsée: ${dateTime.toIso8601String()}');
              print(
                '   ⏳ Il y a: ${diff.inMinutes} minutes et ${diff.inSeconds % 60} secondes',
              );
            } catch (e) {
              print('   ❌ Erreur parsing date: $e');
            }
          } else {
            print('   ⚠️  Updated_at est NULL');
          }
        }

        // Afficher l'enregistrement last_sync_date spécifiquement
        final lastSyncRecord = allRecords
            .where((r) => r['key'] == 'last_sync_date')
            .toList();
        if (lastSyncRecord.isNotEmpty) {
          final record = lastSyncRecord.first;
          print('');
          print('🎯 ENREGISTREMENT LAST_SYNC_DATE:');
          print('   ⏰ Updated_at: ${record['updated_at']}');
        } else {
          print('');
          print('⚠️  PAS D\'ENREGISTREMENT last_sync_date trouvé !');
        }
      }

      print('🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦');
      print('🔚 FIN DEBUG SYNC_METADATA DATES 🔚');
      print('🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦');
    } catch (e) {
      print('❌🔥 ERREUR DEBUG sync_metadata: $e 🔥❌');
    }
  }

  /// Récupère toutes les actions locales non synchronisées
  /// Utilise la logique des champs date_creation, date_modification, updated_at
  /// par rapport à la date de dernière synchronisation dans sync_metadata
  static Future<List<LocalAction>> getUnsyncedActions() async {
    try {
      final db = await DatabaseService.database;
      final List<LocalAction> actions = [];

      // Récupérer la date de la dernière synchronisation
      final lastSync = await getLastSyncDate();
      final lastSyncDate =
          lastSync?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      print('Date de dernière sync: ${lastSyncDate.toIso8601String()}');

      // 🔍 DEBUG: Afficher les dates sync_metadata après insertion serveur
      await debugSyncMetadataDates();

      // Liste des tables à vérifier pour les modifications
      final tables = [
        'entreprises',
        'utilisateurs',
        'annees_scolaires',
        'classes',
        'eleves',
        'enseignants',
        'frais_scolaires',
        'paiement_frais',
        'depenses',
        'journaux_comptables',
        'ecritures_comptables', // Ajout des écritures comptables
        'responsables',
        'comptes_comptables',
        'creances',
        'cours',
        'notes_periode',
      ];

      int actionId = 1;

      for (final tableName in tables) {
        try {
          // Traitement spécial pour les écritures comptables
          // Regrouper par journal_id pour éviter l'affichage en double
          if (tableName == 'ecritures_comptables') {
            final results = await db.rawQuery(
              '''
              SELECT journal_id, COUNT(*) as count_ecritures, MIN(id) as first_id,
                     MAX(updated_at) as latest_updated_at, 
                     MAX(date_creation) as latest_date_creation,
                     MAX(date_modification) as latest_date_modification,
                CASE 
                  WHEN datetime(MAX(date_creation)) > datetime(?) AND datetime(MAX(date_modification)) > datetime(?) THEN 'LOCAL_UPDATE'
                  WHEN datetime(MAX(date_creation)) > datetime(?) THEN 'LOCAL_CREATE'
                  WHEN datetime(MAX(date_creation)) < datetime(?) AND datetime(MAX(date_modification)) > datetime(?) THEN 'SERVER_UPDATE'
                  ELSE 'SERVER_DATA'
                END as action_type_calculated
              FROM $tableName
              WHERE datetime(date_creation) > datetime(?) OR 
                    (datetime(date_creation) < datetime(?) AND datetime(date_modification) > datetime(?))
              GROUP BY journal_id
              ORDER BY latest_date_modification DESC, latest_date_creation DESC
            ''',
              [
                lastSyncDate
                    .toIso8601String(), // CASE 1: LOCAL_UPDATE - date_creation > last_sync
                lastSyncDate
                    .toIso8601String(), // CASE 1: LOCAL_UPDATE - date_modification > last_sync
                lastSyncDate
                    .toIso8601String(), // CASE 2: LOCAL_CREATE - date_creation > last_sync
                lastSyncDate
                    .toIso8601String(), // CASE 3: SERVER_UPDATE - date_creation < last_sync
                lastSyncDate
                    .toIso8601String(), // CASE 3: SERVER_UPDATE - date_modification > last_sync
                lastSyncDate
                    .toIso8601String(), // WHERE: date_creation > last_sync (LOCAL_CREATE/LOCAL_UPDATE)
                lastSyncDate
                    .toIso8601String(), // WHERE: date_creation < last_sync (SERVER_UPDATE)
                lastSyncDate
                    .toIso8601String(), // WHERE: date_modification > last_sync (SERVER_UPDATE)
              ],
            );
            print(
              'Table $tableName: ${results.length} journaux avec écritures non synchronisées trouvés',
            );

            for (final record in results) {
              final actionType = record['action_type_calculated'] as String;

              if (actionType == 'SERVER_DATA') {
                continue;
              }

              final updatedAt = DateTime.parse(
                record['latest_updated_at'] as String,
              );
              final journalId = record['journal_id'] as int;
              final countEcritures = record['count_ecritures'] as int;

              // Debug: Afficher les infos du journal
              print(
                '  Journal ID $journalId: $countEcritures écritures, type=$actionType',
              );

              actions.add(
                LocalAction(
                  id: actionId++,
                  tableName:
                      'ecritures_comptables', // Garder le nom de table original
                  recordId:
                      journalId, // Utiliser l'ID du journal comme identifiant
                  actionType: actionType,
                  updatedAt: updatedAt,
                  data: {
                    'journal_id': journalId,
                    'count_ecritures': countEcritures,
                    'display_text': '$countEcritures écriture(s) comptable(s)',
                  },
                ),
              );
            }
          } else {
            // Logique normale pour les autres tables
            final results = await db.rawQuery(
              '''
              SELECT *,
                CASE 
                  WHEN datetime(date_creation) > datetime(?) AND datetime(date_modification) > datetime(?) THEN 'LOCAL_UPDATE'
                  WHEN datetime(date_creation) > datetime(?) THEN 'LOCAL_CREATE'
                  WHEN datetime(date_creation) < datetime(?) AND datetime(date_modification) > datetime(?) THEN 'SERVER_UPDATE'
                  ELSE 'SERVER_DATA'
                END as action_type_calculated
              FROM $tableName
              WHERE datetime(date_creation) > datetime(?) OR 
                    (datetime(date_creation) < datetime(?) AND datetime(date_modification) > datetime(?))
              ORDER BY date_modification DESC, date_creation DESC
            ''',
              [
                lastSyncDate
                    .toIso8601String(), // CASE 1: LOCAL_UPDATE - date_creation > last_sync
                lastSyncDate
                    .toIso8601String(), // CASE 1: LOCAL_UPDATE - date_modification > last_sync
                lastSyncDate
                    .toIso8601String(), // CASE 2: LOCAL_CREATE - date_creation > last_sync
                lastSyncDate
                    .toIso8601String(), // CASE 3: SERVER_UPDATE - date_creation < last_sync
                lastSyncDate
                    .toIso8601String(), // CASE 3: SERVER_UPDATE - date_modification > last_sync
                lastSyncDate
                    .toIso8601String(), // WHERE: date_creation > last_sync (LOCAL_CREATE/LOCAL_UPDATE)
                lastSyncDate
                    .toIso8601String(), // WHERE: date_creation < last_sync (SERVER_UPDATE)
                lastSyncDate
                    .toIso8601String(), // WHERE: date_modification > last_sync (SERVER_UPDATE)
              ],
            );
            print(
              'Table $tableName: ${results.length} actions locales trouvées',
            );

            // Convertir en LocalAction (inclure LOCAL_CREATE, LOCAL_UPDATE et SERVER_UPDATE)
            for (final record in results) {
              final actionType = record['action_type_calculated'] as String;

              // Ignorer seulement les SERVER_DATA (pas les SERVER_UPDATE qui nécessitent une action)
              if (actionType == 'SERVER_DATA') {
                continue;
              }

              final updatedAt = DateTime.parse(record['updated_at'] as String);
              final dateCreation = DateTime.parse(
                record['date_creation'] as String,
              );
              final dateModification = DateTime.parse(
                record['date_modification'] as String,
              );
              final recordId = record['id'] as int;

              // Debug: Afficher les dates pour comprendre la logique
              print(
                '  ID $recordId: created=${dateCreation.toIso8601String()}, modified=${dateModification.toIso8601String()}, type=$actionType',
              );

              actions.add(
                LocalAction(
                  id: actionId++,
                  tableName: tableName,
                  recordId: recordId,
                  actionType: actionType,
                  updatedAt: updatedAt,
                  data: Map<String, dynamic>.from(record)
                    ..remove(
                      'action_type_calculated',
                    ), // Retirer le champ calculé
                ),
              );
            }
          }
        } catch (e) {
          print('Erreur lors de la vérification de la table $tableName: $e');
        }
      }

      // Trier par date de modification (plus récent en premier)
      actions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      print('Total actions locales non synchronisées: ${actions.length}');
      return actions;
    } catch (e) {
      print('Erreur lors de la récupération des actions locales: $e');
      return [];
    }
  }

  /// Met à jour la date de dernière synchronisation dans sync_metadata
  /// Cette fonction doit être appelée à chaque synchronisation avec le serveur
  static Future<void> updateLastSyncDate(DateTime syncDate) async {
    try {
      final db = await DatabaseService.database;

      // Insérer ou remplacer la date de dernière synchronisation
      // Le champ updated_at sera mis à jour avec syncDate
      await db.rawInsert(
        '''INSERT OR REPLACE INTO sync_metadata (id, key, value, updated_at) 
           VALUES ((SELECT id FROM sync_metadata WHERE key = 'last_sync_date'), 'last_sync_date', 'Synchronisé avec le serveur', ?)''',
        [syncDate.toIso8601String()],
      );

      print(
        'Date de synchronisation mise à jour: ${syncDate.toIso8601String()}',
      );
    } catch (e) {
      print('Erreur lors de la mise à jour de la date de sync: $e');
    }
  }

  /// Marque le début d'une synchronisation - met à jour immédiatement sync_metadata
  /// Cette fonction doit être appelée au DÉBUT de chaque processus de synchronisation
  static Future<void> markSyncStart() async {
    final now = DateTime.now();
    await updateLastSyncDate(now);
    print(
      'Synchronisation marquée comme commencée à: ${now.toIso8601String()}',
    );
  }

  /// Confirme la fin d'une synchronisation réussie
  static Future<void> markSyncCompleted() async {
    final now = DateTime.now();
    await updateLastSyncDate(now);
    print('Synchronisation marquée comme terminée à: ${now.toIso8601String()}');
  }

  /// Récupère des statistiques de synchronisation
  static Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final unsyncedActions = await getUnsyncedActions();
      final lastSync = await getLastSyncDate();

      // Grouper les actions par table
      final actionsByTable = <String, int>{};
      final actionsByType = <String, int>{};

      for (final action in unsyncedActions) {
        actionsByTable[action.tableName] =
            (actionsByTable[action.tableName] ?? 0) + 1;
        actionsByType[action.actionType] =
            (actionsByType[action.actionType] ?? 0) + 1;
      }

      return {
        'total_unsynced': unsyncedActions.length,
        'last_sync': lastSync?.updatedAt,
        'actions_by_table': actionsByTable,
        'actions_by_type': actionsByType,
        'needs_sync': unsyncedActions.isNotEmpty,
      };
    } catch (e) {
      print('Erreur lors du calcul des stats de sync: $e');
      return {
        'total_unsynced': 0,
        'last_sync': null,
        'actions_by_table': <String, int>{},
        'actions_by_type': <String, int>{},
        'needs_sync': false,
      };
    }
  }
}
