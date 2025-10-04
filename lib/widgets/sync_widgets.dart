import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/providers/sync_provider_new.dart';
import '../services/providers/shared_preferences_provider.dart';

/// Widget réutilisable pour afficher l'état de synchronisation
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateNotifierProvider);
    final syncPreferences = ref.watch(syncPreferencesNotifierProvider);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _getStatusIcon(syncState.status),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(syncState.status),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            if (syncState.message != null) ...[
              const SizedBox(height: 4),
              Text(syncState.message!, style: const TextStyle(fontSize: 12)),
            ],

            if (syncState.totalChanges != null &&
                syncState.processedChanges != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: syncState.progress),
              const SizedBox(height: 4),
              Text(
                '${syncState.processedChanges}/${syncState.totalChanges} changements',
                style: const TextStyle(fontSize: 12),
              ),
            ],

            syncPreferences.when(
              data: (prefs) {
                final lastSyncDate = prefs['lastSyncDate'] as DateTime?;
                if (lastSyncDate != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Dernière sync: ${_formatDate(lastSyncDate)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return const Icon(Icons.sync, color: Colors.grey);
      case SyncStatus.downloading:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.uploading:
        return const Icon(Icons.cloud_upload, color: Colors.blue);
      case SyncStatus.processing:
        return const Icon(Icons.settings, color: Colors.orange);
      case SyncStatus.error:
        return const Icon(Icons.error, color: Colors.red);
    }
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Prêt';
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Widget bouton pour déclencher la synchronisation
class SyncButton extends ConsumerWidget {
  final String userEmail;
  final bool forced;
  final Widget? child;

  const SyncButton({
    super.key,
    required this.userEmail,
    this.forced = false,
    this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateNotifierProvider);
    final isIdle = syncState.status == SyncStatus.idle;

    return ElevatedButton(
      onPressed: isIdle ? () => _performSync(ref, context) : null,
      child: child ?? Text(forced ? 'Sync forcée' : 'Synchroniser'),
    );
  }

  Future<void> _performSync(WidgetRef ref, BuildContext context) async {
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    try {
      if (forced) {
        await syncNotifier.performForcedSync(userEmail);
      } else {
        await syncNotifier.performFullSync(userEmail);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synchronisation terminée !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

/// Widget pour afficher les détails de la dernière synchronisation
class LastSyncDetailsWidget extends ConsumerWidget {
  const LastSyncDetailsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncPreferences = ref.watch(syncPreferencesNotifierProvider);

    return syncPreferences.when(
      data: (prefs) {
        final lastSyncDate = prefs['lastSyncDate'] as DateTime?;
        final lastSyncEmail = prefs['lastSyncUserEmail'] as String?;

        if (lastSyncDate == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Aucune synchronisation effectuée'),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dernière synchronisation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Date: ${lastSyncDate.toString()}'),
                if (lastSyncEmail != null) Text('Utilisateur: $lastSyncEmail'),
                const SizedBox(height: 8),
                Text(
                  'Il y a ${DateTime.now().difference(lastSyncDate).inMinutes} minutes',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
      loading:
          () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
      error:
          (err, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Erreur: $err'),
            ),
          ),
    );
  }
}
