import 'package:flutter/material.dart';
import 'dart:developer';
import '../../services/sync_manager.dart';
import '../../services/database_service.dart';

class SyncTestScreen extends StatefulWidget {
  const SyncTestScreen({super.key});

  @override
  State<SyncTestScreen> createState() => _SyncTestScreenState();
}

class _SyncTestScreenState extends State<SyncTestScreen> {
  bool _loading = false;
  String _output = '';
  final SyncManager _syncManager = SyncManager();

  @override
  void initState() {
    super.initState();
    // Pour les tests, on peut utiliser des credentials de test
    _syncManager.setAuth('test_token', 'test@example.com');
  }

  void _addOutput(String message) {
    setState(() {
      _output += '$message\n';
    });
    log(message);
  }

  Future<void> _createTestEcrituresComptables() async {
    setState(() {
      _loading = true;
      _output = '';
    });

    try {
      _addOutput('=== CRÉATION D\'ÉCRITURES COMPTABLES DE TEST ===');

      final db = await DatabaseService.database;

      // Créer un journal de test
      final journalId = DateTime.now().millisecondsSinceEpoch % 1000000;

      // Créer plusieurs écritures pour ce journal (une écriture complète)
      final ecritures = [
        {
          'journal_id': journalId,
          'compte_comptable_id': 1, // Supposons que le compte 1 existe
          'debit': 1000.0,
          'credit': 0.0,
          'ordre': 1,
          'date_ecriture': DateTime.now().toIso8601String(),
          'libelle': 'Test débit - Frais de scolarité',
          'reference': 'TEST-${journalId}-1',
          'date_creation': DateTime.now().toIso8601String(),
          'date_modification': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'synced': 0, // Non synchronisé
        },
        {
          'journal_id': journalId,
          'compte_comptable_id': 2, // Supposons que le compte 2 existe
          'debit': 0.0,
          'credit': 1000.0,
          'ordre': 2,
          'date_ecriture': DateTime.now().toIso8601String(),
          'libelle': 'Test crédit - Recette frais scolarité',
          'reference': 'TEST-${journalId}-2',
          'date_creation': DateTime.now().toIso8601String(),
          'date_modification': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'synced': 0, // Non synchronisé
        },
      ];

      for (final ecriture in ecritures) {
        await db.insert('ecritures_comptables', ecriture);
        _addOutput('✅ Écriture créée: ${ecriture['libelle']}');
      }

      _addOutput(
        '✅ ${ecritures.length} écritures comptables créées avec journal_id: $journalId',
      );

      // Vérifier l'équilibre
      final totalDebit = ecritures.fold<double>(
        0.0,
        (sum, e) => sum + (e['debit'] as double),
      );
      final totalCredit = ecritures.fold<double>(
        0.0,
        (sum, e) => sum + (e['credit'] as double),
      );

      _addOutput('💰 Total débit: $totalDebit, Total crédit: $totalCredit');
      _addOutput(
        totalDebit == totalCredit
            ? '✅ Journal équilibré'
            : '❌ Journal déséquilibré',
      );
    } catch (e, stackTrace) {
      _addOutput('❌ Erreur lors de la création des écritures: $e');
      log('Stack trace: $stackTrace');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _testSyncEcritures() async {
    setState(() {
      _loading = true;
      _output = '';
    });

    try {
      _addOutput('=== TEST SYNCHRONISATION ÉCRITURES COMPTABLES ===');

      // Vérifier combien d'écritures non synchronisées nous avons
      final db = await DatabaseService.database;
      final unsyncedCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ecritures_comptables WHERE synced = 0 OR synced IS NULL',
      );
      final count = unsyncedCount.first['count'] as int;

      _addOutput('📊 $count écritures comptables non synchronisées trouvées');

      if (count == 0) {
        _addOutput(
          '⚠️ Aucune écriture à synchroniser. Créez d\'abord des écritures de test.',
        );
        return;
      }

      // Tester la synchronisation
      _addOutput('🚀 Démarrage de la synchronisation...');

      // Note: Sans serveur réel, cela échouera mais nous verrons la logique
      bool success = await _syncManager.syncEcrituresComptablesToServer();

      _addOutput(
        success
            ? '✅ Synchronisation réussie'
            : '❌ Synchronisation échouée (normal sans serveur réel)',
      );
    } catch (e, stackTrace) {
      _addOutput('❌ Erreur lors du test de synchronisation: $e');
      log('Stack trace: $stackTrace');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _viewUnsyncedEcritures() async {
    setState(() {
      _loading = true;
      _output = '';
    });

    try {
      _addOutput('=== ÉCRITURES COMPTABLES NON SYNCHRONISÉES ===');

      final db = await DatabaseService.database;
      final unsynced = await db.rawQuery('''
        SELECT * FROM ecritures_comptables 
        WHERE synced = 0 OR synced IS NULL
        ORDER BY journal_id, ordre
      ''');

      if (unsynced.isEmpty) {
        _addOutput('✅ Aucune écriture comptable non synchronisée');
        return;
      }

      _addOutput(
        '📋 ${unsynced.length} écritures comptables non synchronisées:',
      );

      // Grouper par journal_id pour affichage
      final Map<int, List<Map<String, Object?>>> parJournal = {};
      for (final ecriture in unsynced) {
        final journalId = ecriture['journal_id'] as int;
        if (!parJournal.containsKey(journalId)) {
          parJournal[journalId] = [];
        }
        parJournal[journalId]!.add(ecriture);
      }

      for (final journalId in parJournal.keys) {
        final ecrituresJournal = parJournal[journalId]!;
        double totalDebit = 0;
        double totalCredit = 0;

        _addOutput(
          '\n📚 Journal ID: $journalId (${ecrituresJournal.length} écritures)',
        );

        for (final ecriture in ecrituresJournal) {
          final debit = (ecriture['debit'] as num?)?.toDouble() ?? 0;
          final credit = (ecriture['credit'] as num?)?.toDouble() ?? 0;
          totalDebit += debit;
          totalCredit += credit;

          _addOutput('  • ${ecriture['libelle']} - D: $debit, C: $credit');
        }

        _addOutput(
          '  💰 Total: D: $totalDebit, C: $totalCredit ${totalDebit == totalCredit ? "✅" : "❌"}',
        );
      }
    } catch (e) {
      _addOutput('❌ Erreur lors de la consultation: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Synchronisation Comptable'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Boutons d'actions
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton.icon(
                  onPressed: _loading ? null : _createTestEcrituresComptables,
                  icon: const Icon(Icons.add),
                  label: const Text('Créer écritures test'),
                ),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _viewUnsyncedEcritures,
                  icon: const Icon(Icons.list),
                  label: const Text('Voir non synchronisées'),
                ),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _testSyncEcritures,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Test sync vers serveur'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Zone d'output
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _output.isEmpty
                              ? 'Sélectionnez une action pour commencer...'
                              : _output,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
