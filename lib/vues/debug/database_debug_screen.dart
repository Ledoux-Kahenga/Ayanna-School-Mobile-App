import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'sync_test_screen.dart';

class DatabaseDebugScreen extends StatefulWidget {
  @override
  _DatabaseDebugScreenState createState() => _DatabaseDebugScreenState();
}

class _DatabaseDebugScreenState extends State<DatabaseDebugScreen> {
  Map<String, int> tableCounts = {};
  Map<String, List<Map<String, dynamic>>> tableData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatabaseInfo();
  }

  Future<void> _loadDatabaseInfo() async {
    setState(() => isLoading = true);

    try {
      final db = await DatabaseService.database;

      final tables = [
        'entreprises',
        'utilisateurs',
        'comptes_config',
        'comptes_comptables',
        'annees_scolaires',
        'classes',
        'eleves',
        'frais_scolaires',
        'paiement_frais',
        'journaux_comptables',
      ];

      Map<String, int> counts = {};
      Map<String, List<Map<String, dynamic>>> data = {};

      for (String table in tables) {
        try {
          final result = await db.query(table, limit: 10);
          counts[table] = result.length;
          data[table] = result;
        } catch (e) {
          counts[table] = -1; // Erreur
          data[table] = [];
        }
      }

      setState(() {
        tableCounts = counts;
        tableData = data;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur inspection BD: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Base de Données'),
        actions: [
          IconButton(
            icon: Icon(Icons.cloud_sync),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SyncTestScreen()),
            ),
            tooltip: 'Test Synchronisation',
          ),
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadDatabaseInfo),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tableCounts.keys.length,
              itemBuilder: (context, index) {
                final tableName = tableCounts.keys.elementAt(index);
                final count = tableCounts[tableName]!;
                final data = tableData[tableName]!;

                return ExpansionTile(
                  title: Text('$tableName'),
                  subtitle: Text(
                    count == -1 ? 'ERREUR' : '$count enregistrements',
                    style: TextStyle(
                      color: count == -1 ? Colors.red : Colors.green,
                    ),
                  ),
                  children: [
                    if (data.isNotEmpty)
                      ...data
                          .map(
                            (row) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: row.entries
                                        .map(
                                          (entry) => Text(
                                            '${entry.key}: ${entry.value}',
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList()
                    else
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Aucun enregistrement'),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
