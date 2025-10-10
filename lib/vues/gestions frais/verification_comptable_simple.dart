import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/providers/database_provider.dart';

class VerificationComptablePage extends ConsumerStatefulWidget {
  const VerificationComptablePage({super.key});

  @override
  _VerificationComptablePageState createState() =>
      _VerificationComptablePageState();
}

class _VerificationComptablePageState
    extends ConsumerState<VerificationComptablePage> {
  final List<Map<String, dynamic>> _verificationResults = [];
  bool _isLoading = false;
  double _totalDebit = 0;
  double _totalCredit = 0;
  int _nombreEcritures = 0;

  @override
  void initState() {
    super.initState();
    _verifierEquilibreComptable();
  }

  Future<void> _verifierEquilibreComptable() async {
    setState(() {
      _isLoading = true;
      _verificationResults.clear();
    });

    try {
      final database = ref.read(databaseProvider);
      final journauxDao = database.journalComptableDao;
      final ecrituresDao = database.ecritureComptableDao;

      // Récupérer tous les journaux
      final journaux = await journauxDao.getAllJournauxComptables();
      print('📋 Vérification de ${journaux.length} journaux comptables');

      double grandTotalDebit = 0;
      double grandTotalCredit = 0;
      int totalEcritures = 0;

      for (final journal in journaux) {
        // Récupérer les écritures du journal
        final ecritures = await ecrituresDao.getEcrituresComptablesByJournal(
          journal.id!,
        );

        double journalDebit = 0;
        double journalCredit = 0;

        for (final ecriture in ecritures) {
          journalDebit += ecriture.debit ?? 0;
          journalCredit += ecriture.credit ?? 0;
        }

        grandTotalDebit += journalDebit;
        grandTotalCredit += journalCredit;
        totalEcritures += ecritures.length;

        // Vérifier l'équilibre du journal
        bool equilibre = (journalDebit - journalCredit).abs() < 0.01;

        _verificationResults.add({
          'journal': journal,
          'nombreEcritures': ecritures.length,
          'totalDebit': journalDebit,
          'totalCredit': journalCredit,
          'equilibre': equilibre,
          'ecritures': ecritures,
        });
      }

      setState(() {
        _totalDebit = grandTotalDebit;
        _totalCredit = grandTotalCredit;
        _nombreEcritures = totalEcritures;
        _isLoading = false;
      });

      print(
        '💰 Total général - Débit: $_totalDebit CDF, Crédit: $_totalCredit CDF',
      );
      print(
        '⚖️ Équilibre général: ${(_totalDebit - _totalCredit).abs() < 0.01 ? "✅ ÉQUILIBRÉ" : "❌ DÉSÉQUILIBRÉ"}',
      );
    } catch (e) {
      print('❌ Erreur lors de la vérification comptable: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool equilibreGeneral = (_totalDebit - _totalCredit).abs() < 0.01;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification Comptable'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _verifierEquilibreComptable,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Résumé général
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: equilibreGeneral
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: equilibreGeneral ? Colors.green : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RÉSUMÉ GÉNÉRAL',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: equilibreGeneral
                              ? Colors.green[800]
                              : Colors.red[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nombre d\'écritures: $_nombreEcritures'),
                                Text(
                                  'Total Débit: ${_totalDebit.toStringAsFixed(2)} CDF',
                                ),
                                Text(
                                  'Total Crédit: ${_totalCredit.toStringAsFixed(2)} CDF',
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            equilibreGeneral ? Icons.check_circle : Icons.error,
                            color: equilibreGeneral ? Colors.green : Colors.red,
                            size: 40,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        equilibreGeneral
                            ? 'COMPTABILITÉ ÉQUILIBRÉE ✅'
                            : 'COMPTABILITÉ DÉSÉQUILIBRÉE ❌',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: equilibreGeneral
                              ? Colors.green[800]
                              : Colors.red[800],
                        ),
                      ),
                    ],
                  ),
                ),

                // Liste des journaux
                Expanded(
                  child: ListView.builder(
                    itemCount: _verificationResults.length,
                    itemBuilder: (context, index) {
                      final result = _verificationResults[index];
                      final journal = result['journal'];
                      final equilibre = result['equilibre'] as bool;
                      final totalDebit = result['totalDebit'] as double;
                      final totalCredit = result['totalCredit'] as double;
                      final nombreEcritures = result['nombreEcritures'] as int;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Icon(
                            equilibre ? Icons.check_circle : Icons.error,
                            color: equilibre ? Colors.green : Colors.red,
                          ),
                          title: Text(
                            'Journal ${journal.id} - ${journal.libelle}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Écritures: $nombreEcritures'),
                              Text(
                                'Débit: ${totalDebit.toStringAsFixed(2)} CDF',
                              ),
                              Text(
                                'Crédit: ${totalCredit.toStringAsFixed(2)} CDF',
                              ),
                              Text(
                                equilibre ? 'ÉQUILIBRÉ ✅' : 'DÉSÉQUILIBRÉ ❌',
                                style: TextStyle(
                                  color: equilibre ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
