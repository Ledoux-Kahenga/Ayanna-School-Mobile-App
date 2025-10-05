import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/ayanna_theme.dart';
import '../../services/providers/sync_provider_new.dart';
import '../../services/providers/shared_preferences_provider.dart';
import '../../services/providers/auth_provider.dart';
import '../../services/providers/database_provider.dart';

/// Widget réutilisable pour afficher le BottomSheet de synchronisation
class SyncBottomSheet extends ConsumerStatefulWidget {
  const SyncBottomSheet({super.key});

  @override
  ConsumerState<SyncBottomSheet> createState() => _SyncBottomSheetState();
}

class _SyncBottomSheetState extends ConsumerState<SyncBottomSheet> {
  Future<void> _performDownloadSync() async {
    final authStateAsync = ref.read(authNotifierProvider);
    final userEmail = authStateAsync.maybeWhen(
      data: (authState) => authState.userEmail ?? '',
      orElse: () => '',
    );

    if (userEmail.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur non connecté'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      await ref
          .read(syncStateNotifierProvider.notifier)
          .performFullSync(userEmail);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synchronisation descendante terminée'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _performUploadSync() async {
    final authStateAsync = ref.read(authNotifierProvider);
    final userEmail = authStateAsync.maybeWhen(
      data: (authState) => authState.userEmail ?? '',
      orElse: () => '',
    );

    if (userEmail.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur non connecté'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      await ref
          .read(syncStateNotifierProvider.notifier)
          .uploadLocalChanges(userEmail);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synchronisation ascendante terminée'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Jamais';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui à ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Hier à ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return DateFormat('dd/MM/yyyy à HH:mm').format(date);
    }
  }

  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Colors.grey;
      case SyncStatus.downloading:
        return Colors.blue;
      case SyncStatus.uploading:
        return Colors.orange;
      case SyncStatus.processing:
        return Colors.purple;
      case SyncStatus.error:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Icons.check_circle;
      case SyncStatus.downloading:
        return Icons.download;
      case SyncStatus.uploading:
        return Icons.upload;
      case SyncStatus.processing:
        return Icons.settings;
      case SyncStatus.error:
        return Icons.error;
    }
  }

  String _getStatusLabel(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Inactif';
      case SyncStatus.downloading:
        return 'Téléchargement...';
      case SyncStatus.uploading:
        return 'Envoi...';
      case SyncStatus.processing:
        return 'Traitement...';
      case SyncStatus.error:
        return 'Erreur';
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncStateNotifierProvider);
    final syncPrefsAsync = ref.watch(syncPreferencesNotifierProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barre de titre
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AyannaColors.orange,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.sync, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Synchronisation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Contenu scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // État actuel
                  _buildCurrentStatusCard(syncState),
                  const SizedBox(height: 16),

                  // Dernière synchronisation
                  syncPrefsAsync.when(
                    data: (syncPrefs) => _buildLastSyncCard(
                      syncPrefs['lastSyncDate'] as DateTime?,
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),

                  // Statistiques
                  _buildSyncStatsCard(),
                  const SizedBox(height: 16),

                  // Boutons d'action
                  _buildActionButtons(syncState.status != SyncStatus.idle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard(SyncState syncState) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(syncState.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(syncState.status),
                    size: 24,
                    color: _getStatusColor(syncState.status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'État actuel',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _getStatusLabel(syncState.status),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(syncState.status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (syncState.totalChanges != null &&
                syncState.processedChanges != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: syncState.progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(syncState.status),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${syncState.processedChanges} / ${syncState.totalChanges} éléments',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            if (syncState.message != null) ...[
              const SizedBox(height: 8),
              Text(
                syncState.message!,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLastSyncCard(DateTime? lastSync) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.history, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dernière synchronisation',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(lastSync),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatsCard() {
    final database = ref.watch(databaseProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pending_actions, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                const Text(
                  'En attente',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, int>>(
              future: _getUnsyncedCounts(database),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final counts = snapshot.data ?? {};
                final total = counts.values.fold<int>(
                  0,
                  (sum, count) => sum + count,
                );

                if (total == 0) {
                  return Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Tout est synchronisé',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    if (counts['eleves']! > 0)
                      _buildCompactStatRow('Élèves', counts['eleves']!),
                    if (counts['classes']! > 0)
                      _buildCompactStatRow('Classes', counts['classes']!),
                    if (counts['enseignants']! > 0)
                      _buildCompactStatRow(
                        'Enseignants',
                        counts['enseignants']!,
                      ),
                    if (counts['responsables']! > 0)
                      _buildCompactStatRow(
                        'Responsables',
                        counts['responsables']!,
                      ),
                    if (counts['paiements']! > 0)
                      _buildCompactStatRow('Paiements', counts['paiements']!),
                    if (counts['ecritures']! > 0)
                      _buildCompactStatRow('Écritures', counts['ecritures']!),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, int>> _getUnsyncedCounts(database) async {
    try {
      final eleves = await database.eleveDao.getUnsyncedEleves();
      final classes = await database.classeDao.getUnsyncedClasses();
      final enseignants = await database.enseignantDao.getUnsyncedEnseignants();
      final responsables = await database.responsableDao
          .getUnsyncedResponsables();
      final paiements = await database.paiementFraisDao
          .getUnsyncedPaiementFrais();
      final ecritures = await database.ecritureComptableDao
          .getUnsyncedEcrituresComptables();

      return {
        'eleves': eleves.length,
        'classes': classes.length,
        'enseignants': enseignants.length,
        'responsables': responsables.length,
        'paiements': paiements.length,
        'ecritures': ecritures.length,
      };
    } catch (e) {
      return {
        'eleves': 0,
        'classes': 0,
        'enseignants': 0,
        'responsables': 0,
        'paiements': 0,
        'ecritures': 0,
      };
    }
  }

  Widget _buildActionButtons(bool isSyncing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: isSyncing ? null : _performDownloadSync,
          icon: const Icon(Icons.download, size: 20),
          label: const Text('Télécharger'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: isSyncing ? null : _performUploadSync,
          icon: const Icon(Icons.upload, size: 20),
          label: const Text('Envoyer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}

/// Fonction helper pour afficher le BottomSheet de synchronisation
void showSyncBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => const SyncBottomSheet(),
    ),
  );
}
