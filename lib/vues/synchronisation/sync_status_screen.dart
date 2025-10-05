import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/ayanna_theme.dart';
import '../../services/providers/sync_provider_new.dart';
import '../../services/providers/shared_preferences_provider.dart';
import '../../services/providers/auth_provider.dart';
import '../../services/providers/database_provider.dart';
import '../widgets/ayanna_drawer.dart';

class SyncStatusScreen extends ConsumerStatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  ConsumerState<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends ConsumerState<SyncStatusScreen> {
  int _drawerIndex = 5; // Index pour la synchronisation

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Téléchargement des données du serveur...'),
          ],
        ),
      ),
    );

    try {
      await ref
          .read(syncStateNotifierProvider.notifier)
          .performFullSync(userEmail);

      if (mounted) Navigator.of(context).pop();

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
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la synchronisation: $e'),
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Envoi des modifications locales vers le serveur...'),
          ],
        ),
      ),
    );

    try {
      await ref
          .read(syncStateNotifierProvider.notifier)
          .uploadLocalChanges(userEmail);

      if (mounted) Navigator.of(context).pop();

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
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la synchronisation: $e'),
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AyannaColors.orange,
        title: const Text(
          'État de synchronisation',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.invalidate(syncPreferencesNotifierProvider);
            },
          ),
        ],
      ),
      drawer: AyannaDrawer(
        selectedIndex: _drawerIndex,
        onItemSelected: (index) {},
      ),
      body: syncPrefsAsync.when(
        data: (syncPrefs) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte d'état actuel
              _buildCurrentStatusCard(syncState),
              const SizedBox(height: 16),

              // Carte de dernière synchronisation
              _buildLastSyncCard(syncPrefs['lastSyncDate'] as DateTime?),
              const SizedBox(height: 16),

              // Carte des statistiques de synchronisation
              _buildSyncStatsCard(),
              const SizedBox(height: 16),

              // Boutons d'action
              _buildActionButtons(syncState.status != SyncStatus.idle),
              const SizedBox(height: 16),

              // Informations supplémentaires
              if (syncState.message != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            syncState.message!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Widget _buildCurrentStatusCard(SyncState syncState) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(syncState.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(syncState.status),
                    size: 30,
                    color: _getStatusColor(syncState.status),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'État actuel',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusLabel(syncState.status),
                        style: TextStyle(
                          fontSize: 20,
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
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: syncState.progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(syncState.status),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${syncState.processedChanges} / ${syncState.totalChanges} éléments traités',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            if (syncState.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        syncState.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, size: 24, color: Colors.grey.shade700),
                const SizedBox(width: 12),
                const Text(
                  'Dernière synchronisation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  _formatDate(lastSync),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                ),
              ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 24,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Éléments en attente de synchronisation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, int>>(
              future: _getUnsyncedCounts(database),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                }

                final counts = snapshot.data ?? {};
                final total = counts.values.fold<int>(
                  0,
                  (sum, count) => sum + count,
                );

                if (total == 0) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Toutes les données sont synchronisées',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    _buildStatRow(
                      'Élèves',
                      counts['eleves'] ?? 0,
                      Icons.school,
                    ),
                    _buildStatRow(
                      'Classes',
                      counts['classes'] ?? 0,
                      Icons.class_,
                    ),
                    _buildStatRow(
                      'Enseignants',
                      counts['enseignants'] ?? 0,
                      Icons.person,
                    ),
                    _buildStatRow(
                      'Responsables',
                      counts['responsables'] ?? 0,
                      Icons.people,
                    ),
                    _buildStatRow(
                      'Paiements',
                      counts['paiements'] ?? 0,
                      Icons.payment,
                    ),
                    _buildStatRow(
                      'Écritures comptables',
                      counts['ecritures'] ?? 0,
                      Icons.receipt,
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$total',
                            style: TextStyle(
                              fontSize: 16,
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

  Widget _buildStatRow(String label, int count, IconData icon) {
    if (count == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
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
      print('Erreur lors du comptage des éléments non synchronisés: $e');
      return {};
    }
  }

  Widget _buildActionButtons(bool isSyncing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Actions de synchronisation',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: isSyncing ? null : _performDownloadSync,
          icon: const Icon(Icons.download),
          label: const Text('Télécharger depuis le serveur'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: isSyncing ? null : _performUploadSync,
          icon: const Icon(Icons.upload),
          label: const Text('Envoyer vers le serveur'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
