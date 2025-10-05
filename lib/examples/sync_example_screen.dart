import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/providers/sync_provider_new.dart';
import '../services/providers/shared_preferences_provider.dart';

/// Exemple d'utilisation du système de synchronisation avec SharedPreferences
class SyncExampleScreen extends ConsumerStatefulWidget {
  const SyncExampleScreen({super.key});

  @override
  ConsumerState<SyncExampleScreen> createState() => _SyncExampleScreenState();
}

class _SyncExampleScreenState extends ConsumerState<SyncExampleScreen> {
  String userEmail = 'admin@testschool.com';

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncStateNotifierProvider);
    final syncPreferences = ref.watch(syncPreferencesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Synchronisation Ayanna School')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informations sur la dernière synchronisation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations de synchronisation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    syncPreferences.when(
                      data: (prefs) {
                        final lastSyncDate = prefs['lastSyncDate'] as DateTime?;
                        final lastSyncEmail =
                            prefs['lastSyncUserEmail'] as String?;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dernière sync: ${lastSyncDate?.toString() ?? 'Jamais'}',
                            ),
                            Text(
                              'Dernier utilisateur: ${lastSyncEmail ?? 'Aucun'}',
                            ),
                          ],
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text('Erreur: $err'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // État actuel de la synchronisation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'État: ${_getStatusText(syncState.status)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (syncState.message != null) ...[
                      const SizedBox(height: 8),
                      Text(syncState.message!),
                    ],
                    if (syncState.totalChanges != null &&
                        syncState.processedChanges != null) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: syncState.progress),
                      const SizedBox(height: 4),
                      Text(
                        '${syncState.processedChanges}/${syncState.totalChanges} changements traités',
                      ),
                    ],
                    if (syncState.error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Erreur: ${syncState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Boutons d'action
            ElevatedButton(
              onPressed:
                  syncState.status == SyncStatus.idle
                      ? () => _performSync(false)
                      : null,
              child: const Text('Synchronisation normale'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed:
                  syncState.status == SyncStatus.idle
                      ? () => _performSync(true)
                      : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Synchronisation forcée'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed:
                  syncState.status == SyncStatus.idle
                      ? _checkIfSyncNeeded
                      : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Vérifier si sync nécessaire'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed:
                  syncState.status == SyncStatus.idle ? _clearSyncData : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Effacer données de sync'),
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

  Future<void> _performSync(bool forced) async {
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    try {
      if (forced) {
        await syncNotifier.performForcedSync(userEmail);
      } else {
        await syncNotifier.performFullSync(userEmail);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synchronisation terminée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de synchronisation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkIfSyncNeeded() async {
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);
/*     final isNeeded = await syncNotifier.isSyncNeeded();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNeeded
                ? 'Synchronisation nécessaire'
                : 'Synchronisation récente, pas nécessaire',
          ),
          backgroundColor: isNeeded ? Colors.orange : Colors.green,
        ),
      );
    } */
  }

  Future<void> _clearSyncData() async {
    final syncPrefs = ref.read(syncPreferencesNotifierProvider.notifier);
    await syncPrefs.clearSyncData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Données de synchronisation effacées'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}
