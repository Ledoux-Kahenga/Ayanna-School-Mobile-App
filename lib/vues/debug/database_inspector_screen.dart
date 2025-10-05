import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database_inspector_service.dart';

class DatabaseInspectorScreen extends ConsumerStatefulWidget {
  const DatabaseInspectorScreen({super.key});

  @override
  ConsumerState<DatabaseInspectorScreen> createState() =>
      _DatabaseInspectorScreenState();
}

class _DatabaseInspectorScreenState
    extends ConsumerState<DatabaseInspectorScreen> {
  Map<String, dynamic>? _dbInfo;
  List<String>? _tableNames;
  String? _selectedTable;
  List<Map<String, dynamic>>? _tableInfo;
  int? _tableCount;
  List<Map<String, dynamic>>? _tableSample;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDatabaseInfo();
    _loadTableNames();
  }

  Future<void> _loadDatabaseInfo() async {
    setState(() => _isLoading = true);
    try {
      final info = await DatabaseInspectorService.getDatabaseInfo();
      setState(() => _dbInfo = info);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTableNames() async {
    setState(() => _isLoading = true);
    try {
      final tables = await DatabaseInspectorService.getTableNames();
      setState(() => _tableNames = tables);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTableDetails(String tableName) async {
    setState(() => _isLoading = true);
    try {
      final info = await DatabaseInspectorService.getTableInfo(tableName);
      final count = await DatabaseInspectorService.getTableCount(tableName);
      final sample = await DatabaseInspectorService.getTableSample(tableName);

      setState(() {
        _selectedTable = tableName;
        _tableInfo = info;
        _tableCount = count;
        _tableSample = sample;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportDatabase() async {
    setState(() => _isLoading = true);
    try {
      await DatabaseInspectorService.shareDatabase();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Base de données exportée avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de l\'export: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspecteur Base de Données'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isLoading ? null : _exportDatabase,
            tooltip: 'Exporter la base de données',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading
                ? null
                : () {
                    _loadDatabaseInfo();
                    _loadTableNames();
                    setState(() {
                      _selectedTable = null;
                      _tableInfo = null;
                      _tableCount = null;
                      _tableSample = null;
                    });
                  },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDatabaseInfo(),
                  const SizedBox(height: 24),
                  _buildTablesList(),
                  if (_selectedTable != null) ...[
                    const SizedBox(height: 24),
                    _buildTableDetails(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDatabaseInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations Base de Données',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_dbInfo != null) ...[
              _buildInfoRow('Chemin', _dbInfo!['path'] ?? 'N/A'),
              _buildInfoRow('Existe', _dbInfo!['exists']?.toString() ?? 'N/A'),
              _buildInfoRow('Taille', _dbInfo!['sizeFormatted'] ?? 'N/A'),
              _buildInfoRow(
                'Dernière modification',
                _dbInfo!['lastModified'] ?? 'N/A',
              ),
            ] else
              const Text('Informations non disponibles'),
          ],
        ),
      ),
    );
  }

  Widget _buildTablesList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tables',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_tableNames != null)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tableNames!
                    .map(
                      (table) => ElevatedButton(
                        onPressed: () => _loadTableDetails(table),
                        child: Text(table),
                      ),
                    )
                    .toList(),
              )
            else
              const Text('Tables non disponibles'),
          ],
        ),
      ),
    );
  }

  Widget _buildTableDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails de la table: $_selectedTable',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_tableCount != null)
              _buildInfoRow(
                'Nombre d\'enregistrements',
                _tableCount.toString(),
              ),
            const SizedBox(height: 16),
            if (_tableInfo != null) ...[
              const Text(
                'Colonnes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._tableInfo!.map(
                (col) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${col['name']} (${col['type']})'),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_tableSample != null && _tableSample!.isNotEmpty) ...[
              const Text(
                'Échantillon de données:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._tableSample!.map(
                (row) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    row.entries.map((e) => '${e.key}: ${e.value}').join(', '),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
