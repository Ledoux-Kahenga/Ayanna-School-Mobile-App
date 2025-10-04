import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_response.dart';
import '../services/helpers/id_mapping_helper.dart';
import '../services/providers/sync_provider_new.dart';

/// Exemple d'utilisation du mapping des IDs après upload
class IdMappingExample extends ConsumerStatefulWidget {
  @override
  ConsumerState<IdMappingExample> createState() => _IdMappingExampleState();
}

class _IdMappingExampleState extends ConsumerState<IdMappingExample> {
  final String userEmail = 'admin@testschool.com';
  SyncUploadResponse? lastUploadResponse;

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('ID Mapping Upload Example')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Information sur la réponse d'upload
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Réponse d\'upload avec mapping IDs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Le serveur retourne maintenant:'),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('''
{
  "success": true,
  "id_mapping": [
    {
      "table": "eleves",
      "id_local": 71,
      "id_serveur": 88
    },
    {
      "table": "eleves", 
      "id_local": 75,
      "id_serveur": 89
    }
  ]
}''', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // État de synchronisation
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'État de synchronisation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Statut: ${_getStatusText(syncState.status)}'),
                    if (syncState.message != null)
                      Text('Message: ${syncState.message}'),
                    if (syncState.error != null)
                      Text(
                        'Erreur: ${syncState.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Bouton d'upload
            ElevatedButton(
              onPressed:
                  syncState.status == SyncStatus.idle
                      ? () => _performUploadWithMapping()
                      : null,
              child: Text('Upload avec Mapping IDs'),
            ),

            SizedBox(height: 16),

            // Affichage des résultats de mapping
            if (lastUploadResponse != null) ...[
              IdMappingResultWidget(uploadResponse: lastUploadResponse!),
              SizedBox(height: 16),
              _buildMappingDetails(),
            ],
          ],
        ),
      ),
    );
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Inactif';
      case SyncStatus.downloading:
        return 'Téléchargement...';
      case SyncStatus.uploading:
        return 'Upload...';
      case SyncStatus.processing:
        return 'Traitement...';
      case SyncStatus.error:
        return 'Erreur';
    }
  }

  Future<void> _performUploadWithMapping() async {
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    try {
      // Pour cet exemple, on simule une réponse avec mapping
      // Dans la vraie application, cette réponse viendrait du serveur
      await syncNotifier.uploadLocalChanges(userEmail);

      // Simuler une réponse avec mapping pour la démo
      setState(() {
        lastUploadResponse = SyncUploadResponse(
          success: true,
          message: 'Upload réussi',
          idMapping: [
            IdMapping(table: 'eleves', idLocal: 71, idServeur: 88),
            IdMapping(table: 'eleves', idLocal: 75, idServeur: 89),
            IdMapping(table: 'enseignants', idLocal: 12, idServeur: 45),
          ],
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload avec mapping terminé !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMappingDetails() {
    if (lastUploadResponse == null || !lastUploadResponse!.hasIdMapping) {
      return SizedBox.shrink();
    }

    // Pour cet exemple, on affiche juste les stats sans utiliser IdMappingHelper
    final mappingsByTable = <String, int>{};
    for (final mapping in lastUploadResponse!.idMapping!) {
      mappingsByTable[mapping.table] =
          (mappingsByTable[mapping.table] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails du mapping',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Statistiques par table:'),
            SizedBox(height: 8),
            ...mappingsByTable.entries.map(
              (entry) => Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${entry.key}:'),
                    Text('${entry.value} éléments mappés'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Mappings individuels:'),
            SizedBox(height: 8),
            ...lastUploadResponse!.idMapping!.map(
              (mapping) => Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${mapping.table}: ID local ${mapping.idLocal} → ID serveur ${mapping.idServeur}',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour démontrer l'utilisation des extensions
class IdMappingExtensionsDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Exemple de réponse avec mapping
    final uploadResponse = SyncUploadResponse(
      success: true,
      idMapping: [
        IdMapping(table: 'eleves', idLocal: 71, idServeur: 88),
        IdMapping(table: 'eleves', idLocal: 75, idServeur: 89),
        IdMapping(table: 'enseignants', idLocal: 12, idServeur: 45),
      ],
    );

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Extensions SyncUploadResponse',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            Text('Méthodes utilitaires disponibles:'),
            SizedBox(height: 8),

            _buildExtensionExample(
              'hasIdMapping',
              'Vérifie si la réponse contient des mappings',
              uploadResponse.hasIdMapping.toString(),
            ),

            _buildExtensionExample(
              'totalMappedIds',
              'Nombre total d\'IDs mappés',
              uploadResponse.totalMappedIds.toString(),
            ),

            _buildExtensionExample(
              'affectedTables',
              'Tables affectées par le mapping',
              uploadResponse.affectedTables.join(', '),
            ),

            _buildExtensionExample(
              'getMappingsForTable("eleves")',
              'Mappings pour une table spécifique',
              '${uploadResponse.getMappingsForTable("eleves").length} mappings',
            ),

            _buildExtensionExample(
              'getServerIdForLocal("eleves", 71)',
              'Obtenir l\'ID serveur pour un ID local',
              uploadResponse.getServerIdForLocal("eleves", 71)?.toString() ??
                  'null',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtensionExample(
    String method,
    String description,
    String result,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            method,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(description, style: TextStyle(fontSize: 12)),
          Text(
            'Résultat: $result',
            style: TextStyle(fontSize: 12, color: Colors.blue),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Documentation du processus de mapping
class IdMappingDocumentation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Documentation ID Mapping')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Processus de Mapping des IDs',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),

            _buildDocSection('Processus automatique', [
              '1. Client upload les changements locaux',
              '2. Serveur traite et assigne des IDs serveur',
              '3. Serveur retourne le mapping ID local → ID serveur',
              '4. Client met à jour automatiquement les server_id',
              '5. Éléments marqués comme synchronisés',
            ]),

            _buildDocSection('Structure de la réponse', [
              'success: boolean - Statut de l\'upload',
              'id_mapping: array - Liste des mappings',
              'Chaque mapping contient:',
              '  - table: nom de la table',
              '  - id_local: ID dans la base locale',
              '  - id_serveur: ID assigné par le serveur',
            ]),

            _buildDocSection('Avantages', [
              '• Synchronisation automatique des IDs',
              '• Pas de conflit d\'IDs entre clients',
              '• Traçabilité complète des changements',
              '• Support pour tous les types d\'entités',
              '• Gestion d\'erreurs robuste',
            ]),

            IdMappingExtensionsDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocSection(String title, List<String> items) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
