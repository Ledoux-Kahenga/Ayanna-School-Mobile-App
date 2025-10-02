import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import '../../theme/ayanna_theme.dart';
import '../../services/sync_status_service.dart';
import '../../services/sync_manager.dart';
import '../../models/models.dart';
import '../widgets/ayanna_drawer.dart';

class SyncStatusScreen extends StatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  State<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends State<SyncStatusScreen> {
  bool _loading = true;
  SyncMetadata? _lastSync;
  List<LocalAction> _localActions = [];
  int _drawerIndex = 5; // Nouvel index pour la synchronisation

  @override
  void initState() {
    super.initState();
    _loadSyncData();
  }

  Future<void> _loadSyncData() async {
    setState(() {
      _loading = true;
    });

    try {
      final lastSync = await SyncStatusService.getLastSyncDate();
      final localActions = await SyncStatusService.getUnsyncedActions();

      setState(() {
        _lastSync = lastSync;
        _localActions = localActions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadSyncData();
  }

  Future<void> _performSync() async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Synchronisation en cours...'),
          ],
        ),
      ),
    );

    try {
      // TODO: Intégrer la logique de synchronisation réelle
      // Pour l'instant, simuler une synchronisation
      await Future.delayed(const Duration(seconds: 2));

      // Marquer la synchronisation comme terminée
      await SyncStatusService.markSyncCompleted();

      // Fermer l'indicateur de chargement
      if (mounted) Navigator.of(context).pop();

      // Recharger les données
      await _loadSyncData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synchronisation simulée terminée'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Fermer l'indicateur de chargement
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

  Future<void> _performUploadToServer() async {
    // Vérifier s'il y a des données à synchroniser
    if (_localActions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune donnée locale à synchroniser'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Compter les écritures comptables spécifiquement
    final ecrituresComptables = _localActions
        .where((action) => action.tableName == 'ecritures_comptables')
        .length;

    final autresDonnees = _localActions.length - ecrituresComptables;

    // Afficher un indicateur de chargement avec plus de détails
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Envoi de ${_localActions.length} modification(s) vers le serveur...',
            ),
            const SizedBox(height: 8),
            if (ecrituresComptables > 0)
              Text(
                '• $ecrituresComptables écritures comptables (groupées par journal)',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            if (autresDonnees > 0)
              Text(
                '• $autresDonnees autres modifications',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );

    try {
      final syncManager = SyncManager();

      // Récupérer les statistiques de synchronisation avant envoi
      final stats = await syncManager.getSyncStatistics();
      final totalUnsynced = stats['_total_unsynced'] ?? 0;

      log(
        '📊 Statistiques pré-synchronisation: $totalUnsynced enregistrements à synchroniser',
      );

      // Récupérer le token d'authentification depuis les préférences ou service Auth
      // Pour l'instant, utiliser des valeurs de test
      syncManager.setAuth('test_token_user', 'user@ayanna.school');

      // Utiliser notre nouvelle méthode de synchronisation
      bool success = await syncManager.syncAllLocalDataToServer();

      // Fermer l'indicateur de chargement
      if (mounted) Navigator.of(context).pop();

      if (success) {
        // Recharger les données pour voir les changements
        await _loadSyncData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✅ Données envoyées avec succès'),
                  if (ecrituresComptables > 0)
                    Text(
                      '• $ecrituresComptables écritures comptables synchronisées',
                    ),
                  if (autresDonnees > 0)
                    Text('• $autresDonnees autres modifications synchronisées'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ Synchronisation partiellement réussie - Voir les logs pour plus de détails',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Fermer l'indicateur de chargement
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de l\'envoi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _performForceFullUpload() async {
    // Confirmation avant synchronisation forcée
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Synchronisation Forcée'),
        content: const Text(
          'Cette action va envoyer TOUTES les données locales vers le serveur, '
          'même celles déjà synchronisées. Cela peut prendre du temps.\n\n'
          'Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Synchronisation forcée en cours...'),
            SizedBox(height: 8),
            Text(
              'Envoi de toutes les données locales',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );

    try {
      final syncManager = SyncManager();

      // Configuration d'authentification
      syncManager.setAuth('test_token_force', 'admin@ayanna.school');

      // Synchronisation forcée de toutes les données
      bool success = await syncManager.forceFullDataUpload();

      // Fermer l'indicateur de chargement
      if (mounted) Navigator.of(context).pop();

      // Recharger les données
      await _loadSyncData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '✅ Synchronisation forcée réussie - Toutes les données ont été envoyées'
                  : '⚠️ Synchronisation forcée partielle - Voir les logs pour détails',
            ),
            backgroundColor: success ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Fermer l'indicateur de chargement
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de la synchronisation forcée: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _showSyncStatistics() async {
    setState(() {
      _loading = true;
    });

    try {
      final syncManager = SyncManager();
      final stats = await syncManager.getSyncStatistics();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Statistiques de Synchronisation'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total à synchroniser: ${stats['_total_unsynced'] ?? 0} enregistrements',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total en base: ${stats['_total_records'] ?? 0} enregistrements',
                  ),
                  Text(
                    'Tables avec données non sync: ${stats['_tables_with_unsynced_data'] ?? 0}',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Détail par table:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: stats.entries
                            .where((e) => !e.key.startsWith('_'))
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text('${entry.key}: ${entry.value}'),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du calcul des statistiques: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Jamais synchronisé';

    // Calculer le temps écoulé depuis la synchronisation
    final now = DateTime.now();
    final difference = now.difference(date);

    String timeAgo = '';
    if (difference.inDays > 0) {
      timeAgo =
          'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      timeAgo =
          'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      timeAgo =
          'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      timeAgo = 'à l\'instant';
    }

    // Format principal avec information relative
    final formattedDate = DateFormat(
      'dd/MM/yyyy à HH:mm',
      'fr_FR',
    ).format(date);
    return '$formattedDate ($timeAgo)';
  }

  String _getSyncStatusMessage() {
    if (_lastSync == null) {
      return 'Aucune donnée de synchronisation disponible';
    }

    // Vérifier si c'est une synchronisation explicite (avec key = 'last_sync_date')
    // ou des données initiales du serveur
    if (_lastSync!.key == 'last_sync_date') {
      return 'Dernière synchronisation complète';
    } else {
      return 'Données importées du serveur';
    }
  }

  Color _getActionTypeColor(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'local_create':
        return Colors.green.shade600; // Vert pour créations locales
      case 'local_update':
        return Colors.orange.shade600; // Orange pour modifications locales
      case 'server_update':
        return Colors.purple.shade600; // Violet pour modifications serveur
      case 'create':
      case 'insert':
        return Colors
            .green
            .shade300; // Vert plus clair pour créations génériques
      case 'update':
      case 'modify':
        return Colors
            .orange
            .shade300; // Orange plus clair pour modifications génériques
      case 'delete':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getActionTypeIcon(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'local_create':
        return Icons
            .add_circle_outline; // Icône spécifique pour créations locales
      case 'local_update':
        return Icons
            .edit_outlined; // Icône spécifique pour modifications locales
      case 'server_update':
        return Icons
            .cloud_sync_outlined; // Icône spécifique pour modifications serveur
      case 'create':
      case 'insert':
        return Icons.add_circle;
      case 'update':
      case 'modify':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      default:
        return Icons.sync;
    }
  }

  String _getActionTypeLabel(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'local_create':
        return 'Créé localement';
      case 'local_update':
        return 'Modifié localement';
      case 'server_update':
        return 'Donnée serveur modifiée';
      case 'create':
      case 'insert':
        return 'Créé localement';
      case 'update':
      case 'modify':
        return 'Modifié localement';
      case 'delete':
        return 'Supprimé localement';
      default:
        return 'Action locale (${actionType})';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('État de Synchronisation'),
        backgroundColor: AyannaColors.orange,
        foregroundColor: AyannaColors.white,
        actions: [
          if (_localActions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.cloud_upload_outlined),
              onPressed: _loading ? null : _performUploadToServer,
              tooltip: 'Envoyer vers serveur',
            ),
          IconButton(
            icon: const Icon(Icons.sync_alt),
            onPressed: _loading ? null : _performSync,
            tooltip: 'Synchroniser',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _refreshData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      drawer: AyannaDrawer(
        selectedIndex: _drawerIndex,
        onItemSelected: (i) => setState(() => _drawerIndex = i),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSyncStatusCard(),
                    const SizedBox(height: 20),
                    _buildLocalActionsCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSyncStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sync, color: AyannaColors.orange, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getSyncStatusMessage(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AyannaColors.darkGrey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _lastSync != null
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _lastSync != null
                      ? Colors.green.shade200
                      : Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _lastSync != null ? Icons.check_circle : Icons.warning,
                    color: _lastSync != null ? Colors.green : Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(_lastSync?.updatedAt),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _lastSync?.key == 'last_sync_date'
                              ? 'Synchronisation complète effectuée'
                              : 'Données du serveur disponibles',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        if (_lastSync?.value != null)
                          Text(
                            'Serveur: ${_lastSync!.value}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
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

  Widget _buildLocalActionsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pending_actions,
                  color: AyannaColors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Actions Locales Non Synchronisées',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AyannaColors.darkGrey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _localActions.isEmpty
                    ? Colors.green.shade50
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _localActions.isEmpty
                      ? Colors.green.shade200
                      : Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _localActions.isEmpty
                        ? Icons.check_circle
                        : Icons.info_outline,
                    color: _localActions.isEmpty ? Colors.green : Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _localActions.isEmpty
                        ? 'Toutes les données sont synchronisées'
                        : '${_localActions.length} modification(s) locale(s) en attente',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (_localActions.isNotEmpty) ...[
              const SizedBox(height: 16),
              // Bouton pour envoyer les données vers le serveur
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _performUploadToServer,
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('Envoyer modifiées'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AyannaColors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _performForceFullUpload,
                      icon: const Icon(Icons.cloud_sync_outlined),
                      label: const Text('Forcer tout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Bouton pour voir les statistiques
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _showSyncStatistics,
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Voir statistiques de synchronisation'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AyannaColors.orange,
                    side: BorderSide(color: AyannaColors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Détail des modifications locales en attente:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AyannaColors.darkGrey,
                ),
              ),
              const SizedBox(height: 12),
              _buildActionsList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _localActions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final action = _localActions[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getActionTypeColor(
                    action.actionType,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getActionTypeIcon(action.actionType),
                  size: 20,
                  color: _getActionTypeColor(action.actionType),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            action.tableName == 'ecritures_comptables' &&
                                    action.data != null &&
                                    action.data!['display_text'] != null
                                ? action.data!['display_text']
                                : action.tableName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              action.tableName == 'ecritures_comptables' &&
                                      action.data != null &&
                                      action.data!['journal_id'] != null
                                  ? 'Journal: ${action.data!['journal_id']}'
                                  : 'ID: ${action.recordId}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getActionTypeLabel(action.actionType),
                      style: TextStyle(
                        color: _getActionTypeColor(action.actionType),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('dd/MM', 'fr_FR').format(action.updatedAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    DateFormat('HH:mm', 'fr_FR').format(action.updatedAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
