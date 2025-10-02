import 'package:sqflite/sqflite.dart';
import 'dart:developer';

class SyncMigration {
  /// Ajoute les colonnes de synchronisation aux tables existantes
  static Future<void> addSyncColumns(Database db) async {
    log('=== MIGRATION: Ajout des colonnes de synchronisation ===');

    final tablesToUpdate = [
      'entreprises',
      'utilisateurs',
      'classes',
      'eleves',
      'enseignants',
      'annees_scolaires',
      'comptes_comptables',
      'ecritures_comptables',
      'journaux_comptables',
      // Ajouter d'autres tables selon les besoins
    ];

    for (final tableName in tablesToUpdate) {
      try {
        // Vérifier si la colonne 'synced' existe déjà
        final tableInfo = await db.rawQuery('PRAGMA table_info($tableName)');
        final hasSyncedColumn = tableInfo.any(
          (column) => column['name'] == 'synced',
        );

        if (!hasSyncedColumn) {
          // Ajouter la colonne 'synced' avec valeur par défaut 0 (non synchronisé)
          await db.execute(
            'ALTER TABLE $tableName ADD COLUMN synced INTEGER DEFAULT 0',
          );
          log('✅ Colonne "synced" ajoutée à la table $tableName');
        } else {
          log('ℹ️ Colonne "synced" existe déjà dans la table $tableName');
        }
      } catch (e) {
        log('⚠️ Erreur lors de la migration de la table $tableName: $e');
        // Continuer avec les autres tables même si une échoue
      }
    }

    log('✅ Migration des colonnes de synchronisation terminée');
  }

  /// Marque toutes les données existantes comme non synchronisées
  static Future<void> markExistingDataAsUnsynced(Database db) async {
    log(
      '=== MIGRATION: Marquage des données existantes comme non synchronisées ===',
    );

    final tablesToUpdate = [
      'entreprises',
      'utilisateurs',
      'classes',
      'eleves',
      'enseignants',
      'annees_scolaires',
      'comptes_comptables',
      'ecritures_comptables',
      'journaux_comptables',
    ];

    for (final tableName in tablesToUpdate) {
      try {
        // Marquer toutes les données existantes comme non synchronisées
        final result = await db.rawUpdate(
          'UPDATE $tableName SET synced = 0 WHERE synced IS NULL',
        );
        log(
          '✅ $tableName: $result enregistrements marqués comme non synchronisés',
        );
      } catch (e) {
        log('⚠️ Erreur lors du marquage de la table $tableName: $e');
      }
    }

    log('✅ Marquage des données existantes terminé');
  }

  /// Exécute la migration complète
  static Future<void> runSyncMigration(Database db) async {
    log('=== DÉBUT MIGRATION SYNCHRONISATION ===');

    try {
      await addSyncColumns(db);
      await markExistingDataAsUnsynced(db);

      log('✅ MIGRATION SYNCHRONISATION TERMINÉE AVEC SUCCÈS');
    } catch (e, stackTrace) {
      log('❌ ERREUR LORS DE LA MIGRATION SYNCHRONISATION: $e');
      log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Vérifie l'état de la migration
  static Future<bool> isSyncMigrationComplete(Database db) async {
    try {
      // Vérifier si la colonne 'synced' existe dans une table test
      final tableInfo = await db.rawQuery(
        'PRAGMA table_info(ecritures_comptables)',
      );
      final hasSyncedColumn = tableInfo.any(
        (column) => column['name'] == 'synced',
      );

      log(
        'Migration synchronisation: ${hasSyncedColumn ? "COMPLÈTE" : "REQUISE"}',
      );
      return hasSyncedColumn;
    } catch (e) {
      log('⚠️ Erreur lors de la vérification de migration: $e');
      return false;
    }
  }
}
