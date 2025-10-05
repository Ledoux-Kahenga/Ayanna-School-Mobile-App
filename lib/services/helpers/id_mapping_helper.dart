import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/sync_response.dart';
import '../../models/app_database.dart';
import '../providers/database_provider.dart';

/// Helper pour gérer le mapping des IDs après upload sync
class IdMappingHelper {
  final Ref ref;

  IdMappingHelper(this.ref);

  /// Traite le mapping des IDs après un upload réussi
  Future<void> processIdMapping(SyncUploadResponse uploadResponse) async {
    if (uploadResponse.idMapping == null || uploadResponse.idMapping!.isEmpty) {
      return;
    }

    final database = ref.read(databaseProvider);

    for (final mapping in uploadResponse.idMapping!) {
      try {
        await _updateServerIdForTable(database, mapping);
      } catch (e) {
        print('Erreur mise à jour ID mapping pour ${mapping.table}: $e');
      }
    }
  }

  /// Met à jour le server_id pour une table spécifique
  Future<void> _updateServerIdForTable(
    AppDatabase database,
    IdMapping mapping,
  ) async {
    if (mapping.idLocal == null || mapping.idServeur == null) {
      print(
          'Mapping ID invalide pour ${mapping.table}: idLocal ou idServeur est null');
      return;
    }
    switch (mapping.table) {
      case 'eleves':
        await database.eleveDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'enseignants':
        await database.enseignantDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'classes':
        await database.classeDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'annees_scolaires':
        await database.anneeScolaireDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'responsables':
        await database.responsableDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'utilisateurs':
        await database.utilisateurDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'entreprises':
        await database.entrepriseDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'frais_scolaires':
        await database.fraisScolaireDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'frais_classes':
        await database.fraisClassesDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'paiement_frais':
        await database.paiementFraisDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'notes_periodes':
        await database.notePeriodeDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'cours':
        await database.coursDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'periodes':
        await database.periodeDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'creances':
        await database.creanceDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'classes_comptables':
        await database.classeComptableDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'comptes_comptables':
        await database.compteComptableDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'licences':
        await database.licenceDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'configs_ecole':
        await database.configEcoleDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'comptes_configs':
        await database.comptesConfigDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'periodes_classes':
        await database.periodesClassesDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'journaux_comptables':
        await database.journalComptableDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'depenses':
        await database.depenseDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      case 'ecritures_comptables':
        await database.ecritureComptableDao.updateServerIdAndSync(
          mapping.idLocal!,
          mapping.idServeur!,
        );
        break;
      default:
        print('Table non supportée pour ID mapping: ${mapping.table}');
    }
  }

  /// Statistiques du mapping
  Map<String, int> getIdMappingStats(SyncUploadResponse uploadResponse) {
    if (uploadResponse.idMapping == null) {
      return {};
    }

    final stats = <String, int>{};
    for (final mapping in uploadResponse.idMapping!) {
      stats[mapping.table] = (stats[mapping.table] ?? 0) + 1;
    }
    return stats;
  }

  /// Résumé du mapping pour l'interface utilisateur
  String getIdMappingSummary(SyncUploadResponse uploadResponse) {
    if (uploadResponse.idMapping == null || uploadResponse.idMapping!.isEmpty) {
      return 'Aucun nouveau ID mappé';
    }

    final stats = getIdMappingStats(uploadResponse);
    final summary = stats.entries
        .map((entry) => '${entry.value} ${entry.key}')
        .join(', ');

    return 'IDs mappés: $summary';
  }
}

/// Widget pour afficher les résultats du mapping
class IdMappingResultWidget extends StatelessWidget {
  final SyncUploadResponse uploadResponse;

  const IdMappingResultWidget({super.key, required this.uploadResponse});

  @override
  Widget build(BuildContext context) {
    if (!uploadResponse.hasIdMapping) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nouveaux IDs mappés',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Total: ${uploadResponse.totalMappedIds} éléments'),
            const SizedBox(height: 8),
            ...uploadResponse.affectedTables.map((table) {
              final mappings = uploadResponse.getMappingsForTable(table);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $table: ${mappings.length} éléments'),
              );
            }),
            const SizedBox(height: 8),
            const Text(
              'Les IDs locaux ont été mis à jour avec les IDs serveur.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
