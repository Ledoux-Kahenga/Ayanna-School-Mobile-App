import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sync_widgets.dart';
import '../services/providers/sync_provider_new.dart';

/// Exemple d'intégration du système de sync dans une page principale
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final String currentUserEmail = 'admin@testschool.com';

  @override
  void initState() {
    super.initState();
    // Vérifier si une synchronisation est nécessaire au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialSync();
    });
  }

  Future<void> _checkInitialSync() async {
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);
    final isNeeded = await syncNotifier.isSyncNeeded();

    if (isNeeded && mounted) {
      // Proposer une synchronisation automatique
      _showSyncDialog();
    }
  }

  void _showSyncDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Synchronisation recommandée'),
            content: const Text(
              'Vos données ne sont pas récentes. '
              'Voulez-vous synchroniser maintenant ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Plus tard'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _performAutoSync();
                },
                child: const Text('Synchroniser'),
              ),
            ],
          ),
    );
  }

  Future<void> _performAutoSync() async {
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);
    try {
      await syncNotifier.performFullSync(currentUserEmail);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayanna School'),
        actions: [
          // Icône de statut de sync dans l'AppBar
          Consumer(
            builder: (context, ref, child) {
              final syncState = ref.watch(syncStateNotifierProvider);
              return IconButton(
                icon: _getSyncIcon(syncState.status),
                onPressed: () => _showSyncBottomSheet(),
                tooltip: 'État de synchronisation',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Widget de statut de sync en haut
          const SyncStatusWidget(),

          // Contenu principal de l'application
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Détails de la dernière sync
                const LastSyncDetailsWidget(),

                const SizedBox(height: 16),

                // Menu principal
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.people),
                        title: const Text('Gestion des élèves'),
                        onTap: () {
                          // Navigation vers la gestion des élèves
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.school),
                        title: const Text('Gestion des classes'),
                        onTap: () {
                          // Navigation vers la gestion des classes
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Gestion du personnel'),
                        onTap: () {
                          // Navigation vers la gestion du personnel
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.account_balance_wallet),
                        title: const Text('Comptabilité'),
                        onTap: () {
                          // Navigation vers la comptabilité
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSyncBottomSheet(),
        icon: const Icon(Icons.sync),
        label: const Text('Sync'),
      ),
    );
  }

  Widget _getSyncIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return const Icon(Icons.sync);
      case SyncStatus.downloading:
      case SyncStatus.uploading:
      case SyncStatus.processing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.error:
        return const Icon(Icons.sync_problem, color: Colors.red);
    }
  }

  void _showSyncBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Options de synchronisation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Widget de statut
                const SyncStatusWidget(),

                const SizedBox(height: 16),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: SyncButton(
                        userEmail: currentUserEmail,
                        child: const Text('Sync normale'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SyncButton(
                        userEmail: currentUserEmail,
                        forced: true,
                        child: const Text('Sync forcée'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ),
    );
  }
}
