import 'package:flutter/material.dart';
import '../models/sync_response.dart';

/// Widget pour afficher les résultats d'un mapping d'IDs
class IdMappingResultWidget extends StatelessWidget {
  final SyncUploadResponse uploadResponse;
  final bool showDetails;

  const IdMappingResultWidget({
    Key? key,
    required this.uploadResponse,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!uploadResponse.hasIdMapping) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Text('Aucun mapping d\'ID dans cette réponse'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sync_alt, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Mapping des IDs réussi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Statistiques générales
            _buildStatisticsRow(),

            if (showDetails) ...[
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),

              // Grouper par table
              ..._buildMappingsByTable(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsRow() {
    final totalMappings = uploadResponse.totalMappedIds;
    final affectedTables = uploadResponse.affectedTables;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total mappings',
            totalMappings.toString(),
            Icons.swap_horiz,
            Colors.blue,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Tables affectées',
            affectedTables.length.toString(),
            Icons.table_chart,
            Colors.orange,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Statut',
            uploadResponse.success ? 'Succès' : 'Échec',
            uploadResponse.success ? Icons.check_circle : Icons.error,
            uploadResponse.success ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMappingsByTable() {
    final mappingsByTable = <String, List<IdMapping>>{};

    // Grouper les mappings par table
    for (final mapping in uploadResponse.idMapping!) {
      mappingsByTable.putIfAbsent(mapping.table, () => []).add(mapping);
    }

    return mappingsByTable.entries.map((entry) {
      final tableName = entry.key;
      final mappings = entry.value;

      return ExpansionTile(
        leading: Icon(_getTableIcon(tableName)),
        title: Text(
          tableName.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${mappings.length} élément(s) mappé(s)'),
        children:
            mappings
                .map(
                  (mapping) => ListTile(
                    dense: true,
                    leading: Icon(Icons.arrow_forward, size: 16),
                    title: Text(
                      'ID Local: ${mapping.idLocal} → ID Serveur: ${mapping.idServeur}',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                )
                .toList(),
      );
    }).toList();
  }

  IconData _getTableIcon(String tableName) {
    switch (tableName.toLowerCase()) {
      case 'eleves':
        return Icons.school;
      case 'enseignants':
        return Icons.person;
      case 'classes':
        return Icons.class_;
      case 'notes':
        return Icons.grade;
      case 'presences':
        return Icons.check_circle;
      case 'parents':
        return Icons.family_restroom;
      case 'cours':
        return Icons.book;
      case 'matieres':
        return Icons.subject;
      case 'annees_scolaires':
        return Icons.calendar_today;
      case 'frais_scolaires':
        return Icons.attach_money;
      case 'paiements':
        return Icons.payment;
      case 'utilisateurs':
        return Icons.account_circle;
      default:
        return Icons.table_chart;
    }
  }
}

/// Widget compact pour afficher un résumé du mapping
class IdMappingSummaryWidget extends StatelessWidget {
  final SyncUploadResponse uploadResponse;

  const IdMappingSummaryWidget({Key? key, required this.uploadResponse})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!uploadResponse.hasIdMapping) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync_alt, color: Colors.green, size: 16),
          SizedBox(width: 4),
          Text(
            '${uploadResponse.totalMappedIds} IDs mappés',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher l'historique des mappings
class IdMappingHistoryWidget extends StatelessWidget {
  final List<SyncUploadResponse> uploadHistory;

  const IdMappingHistoryWidget({Key? key, required this.uploadHistory})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsesWithMapping =
        uploadHistory.where((response) => response.hasIdMapping).toList();

    if (responsesWithMapping.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Aucun historique de mapping',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.history),
                SizedBox(width: 8),
                Text(
                  'Historique des mappings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Divider(),
          ...responsesWithMapping
              .take(5)
              .map(
                (response) => ListTile(
                  leading: Icon(
                    Icons.sync_alt,
                    color: response.success ? Colors.green : Colors.red,
                  ),
                  title: Text('${response.totalMappedIds} IDs mappés'),
                  subtitle: Text(
                    '${response.affectedTables.length} table(s): ${response.affectedTables.take(3).join(", ")}${response.affectedTables.length > 3 ? "..." : ""}',
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () => _showMappingDetails(context, response),
                ),
              ),
          if (responsesWithMapping.length > 5)
            Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Et ${responsesWithMapping.length - 5} autres...',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showMappingDetails(BuildContext context, SyncUploadResponse response) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Détails du mapping'),
            content: SingleChildScrollView(
              child: IdMappingResultWidget(
                uploadResponse: response,
                showDetails: true,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Fermer'),
              ),
            ],
          ),
    );
  }
}
