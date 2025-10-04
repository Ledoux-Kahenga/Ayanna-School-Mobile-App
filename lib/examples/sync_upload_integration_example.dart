import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/providers/sync_provider_new.dart';

/// Exemple d'utilisation des nouvelles méthodes d'upload sync
class SyncUploadIntegrationExample extends ConsumerStatefulWidget {
  @override
  ConsumerState<SyncUploadIntegrationExample> createState() =>
      _SyncUploadIntegrationExampleState();
}

class _SyncUploadIntegrationExampleState
    extends ConsumerState<SyncUploadIntegrationExample> {
  final String userEmail = 'admin@testschool.com';

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Upload Sync Integration')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                        fontSize: 18,
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
                    if (syncState.totalChanges != null &&
                        syncState.processedChanges != null)
                      Column(
                        children: [
                          SizedBox(height: 8),
                          LinearProgressIndicator(value: syncState.progress),
                          SizedBox(height: 4),
                          Text(
                            '${syncState.processedChanges}/${syncState.totalChanges} changements traités',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Boutons d'action
            ElevatedButton(
              onPressed:
                  syncState.status == SyncStatus.idle
                      ? () => _uploadLocalChanges()
                      : null,
              child: Text('Upload Changements Locaux'),
            ),

            SizedBox(height: 8),

            ElevatedButton(
              onPressed:
                  syncState.status == SyncStatus.idle
                      ? () => _performBidirectionalSync()
                      : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text('Synchronisation Bidirectionnelle'),
            ),

            SizedBox(height: 8),

            ElevatedButton(
              onPressed:
                  syncState.status == SyncStatus.idle
                      ? () => _performDownloadSync()
                      : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Download du Serveur'),
            ),

            SizedBox(height: 8),

            ElevatedButton(
              onPressed:
                  syncState.status == SyncStatus.idle
                      ? () => _performForcedSync()
                      : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Synchronisation Forcée'),
            ),

            SizedBox(height: 24),

            // Informations
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Types de synchronisation disponibles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Upload Local: Envoie seulement les changements locaux vers le serveur',
                    ),
                    Text(
                      '• Download: Récupère seulement les changements du serveur',
                    ),
                    Text(
                      '• Bidirectionnelle: Upload local puis download (recommandé)',
                    ),
                    Text(
                      '• Forcée: Efface l\'historique et fait une sync complète',
                    ),
                  ],
                ),
              ),
            ),
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

  /// Upload seulement les changements locaux
  Future<void> _uploadLocalChanges() async {
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    try {
      await syncNotifier.uploadLocalChanges(userEmail);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload des changements locaux terminé !'),
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

  /// Synchronisation bidirectionnelle (upload puis download)
  Future<void> _performBidirectionalSync() async {
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    try {
      await syncNotifier.performBidirectionalSync(userEmail);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Synchronisation bidirectionnelle terminée !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur sync bidirectionnelle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Download seulement du serveur
  Future<void> _performDownloadSync() async {
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    try {
      await syncNotifier.performFullSync(userEmail);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download du serveur terminé !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur download: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Synchronisation forcée
  Future<void> _performForcedSync() async {
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    try {
      await syncNotifier.performForcedSync(userEmail);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Synchronisation forcée terminée !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur sync forcée: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Widget de démonstration des méthodes
class SyncMethodsDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nouvelles méthodes ajoutées',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            _buildMethodInfo(
              'uploadLocalChanges(userEmail)',
              'Upload les changements locaux non synchronisés vers le serveur',
              [
                '• Collecte automatiquement tous les changements non sync',
                '• Utilise la structure JSON attendue par le serveur',
                '• Marque les éléments comme synchronisés après upload',
              ],
            ),

            SizedBox(height: 16),

            _buildMethodInfo(
              'performBidirectionalSync(userEmail)',
              'Synchronisation complète dans les deux sens',
              [
                '• Upload les changements locaux d\'abord',
                '• Puis download les changements du serveur',
                '• Garantit une synchronisation complète',
              ],
            ),

            SizedBox(height: 16),

            _buildMethodInfo(
              'uploadChanges(SyncUploadRequest)',
              'Upload avec structure typée',
              [
                '• Utilise le nouveau modèle SyncUploadRequest',
                '• Compatible avec la structure JSON du serveur',
                '• Typé et sûr',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodInfo(
    String method,
    String description,
    List<String> features,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          method,
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(description),
        SizedBox(height: 8),
        ...features.map(
          (feature) => Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(feature, style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

/// Documentation des nouvelles fonctionnalités
class SyncUploadDocumentation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Documentation Upload Sync')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nouvelles fonctionnalités d\'upload sync',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),

            SyncMethodsDemo(),

            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Structure des données',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Les données sont automatiquement formatées selon la structure attendue:',
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('''
{
  "client_id": "flutter-client",
  "changes": [
    {
      "table": "eleves",
      "operation": "update",
      "action": "modifié",
      "data": { ... }
    }
  ],
  "timestamp": "2025-10-04T..."
}''', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
