import 'package:ayanna_school/models/entities/journal_comptable.dart';
import 'package:ayanna_school/services/app_preferences.dart';
import 'package:ayanna_school/services/providers/providers.dart';
import 'package:ayanna_school/vues/gestions%20frais/depense_sortie.dart';
import 'package:ayanna_school/vues/gestions%20frais/journal_caisse_pdf.dart';
import 'package:ayanna_school/vues/gestions%20frais/test_paiement_ecritures_page.dart';
import 'package:ayanna_school/vues/gestions%20frais/verification_comptable_simple.dart';
import 'package:ayanna_school/vues/widgets/ayanna_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/ayanna_theme.dart';

class JournalCaisse extends ConsumerStatefulWidget {
  const JournalCaisse({super.key});

  @override
  ConsumerState<JournalCaisse> createState() => _JournalCaisseState();
}

class _JournalCaisseState extends ConsumerState<JournalCaisse> {
  int _drawerIndex = 1;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'Tous';
  List<JournalComptable> _journalEntries = [];

  double _totalEntrees = 0.0;
  double _totalSorties = 0.0;
  double get _soldeDuJour => _totalEntrees - _totalSorties;

  @override
  void initState() {
    super.initState();
    _fetchJournalData();
  }

  Future<void> _fetchJournalData() async {
    setState(() {
      _isLoading = true;
    });

    print('🔍 Récupération des données du journal...');
    print('  - Date sélectionnée: ${_selectedDate.toString()}');
    print('  - Filtre appliqué: $_selectedFilter');

    final entries = await ref
        .read(journauxComptablesNotifierProvider.notifier)
        .getJournalEntries(_selectedDate, filter: _selectedFilter);

    print('  - Nombre d\'entrées trouvées: ${entries.length}');

    if (entries.isNotEmpty) {
      print(
        '  - Première entrée: ${entries.first.libelle} (${entries.first.montant})',
      );
    }

    setState(() {
      _journalEntries = entries;
      _calculateTotals();
      _isLoading = false;
    });
  }

  /// Récupère les informations détaillées d'un paiement de frais
  Future<Map<String, String>> _getPaiementDetails(int? paiementFraisId) async {
    if (paiementFraisId == null) {
      return {'eleve': '', 'frais': '', 'detail': ''};
    }

    try {
      // Récupérer le paiement
      final paiementDao = ref.read(paiementFraisDaoProvider);
      final paiement = await paiementDao.getPaiementFraisById(paiementFraisId);

      if (paiement == null) {
        return {'eleve': '', 'frais': '', 'detail': ''};
      }

      // Récupérer l'élève
      final eleveDao = ref.read(eleveDaoProvider);
      final eleve = await eleveDao.getEleveById(paiement.eleveId);

      // Récupérer le frais
      final fraisDao = ref.read(fraisScolaireDaoProvider);
      final frais = await fraisDao.getFraisScolaireById(
        paiement.fraisScolaireId,
      );

      final nomEleve = eleve != null
          ? '${eleve.nom} ${eleve.prenom}'.trim()
          : 'Élève inconnu';

      final nomFrais = frais?.nom ?? 'Frais inconnu';

      final statut = paiement.statut ?? 'En cours';
      final resteAPayer = paiement.resteAPayer ?? 0.0;

      String detail = statut;
      if (resteAPayer > 0) {
        final currencyFormat = NumberFormat.currency(
          locale: 'fr_FR',
          symbol: 'CDF',
          decimalDigits: 0,
        );
        detail += '\nReste: ${currencyFormat.format(resteAPayer)}';
      }

      return {'eleve': nomEleve, 'frais': nomFrais, 'detail': detail};
    } catch (e) {
      print('Erreur lors de la récupération des détails du paiement: $e');
      return {'eleve': '', 'frais': '', 'detail': ''};
    }
  }

  void _calculateTotals() {
    double entrees = 0.0;
    double sorties = 0.0;
    for (var entry in _journalEntries) {
      if (entry.typeOperation.toLowerCase() == 'entrée') {
        entrees += entry.montant;
      } else if (entry.typeOperation.toLowerCase() == 'sortie') {
        sorties += entry.montant;
      }
    }
    _totalEntrees = entrees;
    _totalSorties = sorties;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchJournalData();
    }
  }

  Future<void> _exportToPdf() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await generateAndPrintJournalPdf(
        _journalEntries,
        _selectedDate,
        _totalEntrees,
        _totalSorties,
        _soldeDuJour,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Facture générée avec succès.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la génération du PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // [AMÉLIORÉ] Navigue et rafraîchit les données au retour
  Future<void> _navigateToDepensePage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const DepenseSortiePage()),
    );

    // Si la page de dépense a renvoyé 'true', on rafraîchit les données
    if (result == true) {
      _fetchJournalData();
    }
  }

  // [NOUVEAU] Navigue vers la page de test des paiements avec écritures
  Future<void> _navigateToTestPaiementPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TestPaiementEcrituresPage(),
      ),
    );
    // Rafraîchir les données au retour pour voir les nouvelles écritures
    _fetchJournalData();
  }

  // [NOUVEAU] Navigue vers la page de vérification comptable
  Future<void> _navigateToVerificationComptable() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VerificationComptablePage(),
      ),
    );
  }

  // [DEBUG] Méthode pour débugger les données du journal
  Future<void> _debugJournalData() async {
    try {
      print('🔍 DEBUG - Vérification complète des données du journal');

      final journalDao = ref.read(journalComptableDaoProvider);

      // Récupérer TOUTES les entrées du journal
      final allEntries = await journalDao.getAllJournauxComptables();
      print('  - Total entrées dans la base: ${allEntries.length}');

      if (allEntries.isNotEmpty) {
        print('  - Entrées récentes:');
        for (int i = 0; i < allEntries.length && i < 5; i++) {
          final entry = allEntries[i];
          print(
            '    ${i + 1}. ${entry.libelle} - ${entry.montant} CDF (${entry.dateOperation})',
          );
        }
      }

      // Vérifier spécifiquement pour aujourd'hui
      final today = DateTime.now();
      final todayEntries = allEntries.where((entry) {
        final entryDate = entry.dateOperation;
        return entryDate.year == today.year &&
            entryDate.month == today.month &&
            entryDate.day == today.day;
      }).toList();

      print(
        '  - Entrées pour aujourd\'hui (${today.day}/${today.month}/${today.year}): ${todayEntries.length}',
      );

      if (todayEntries.isNotEmpty) {
        for (final entry in todayEntries) {
          print('    -> ${entry.libelle} - ${entry.montant} CDF');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Debug terminé. Total: ${allEntries.length} entrées. Aujourd\'hui: ${todayEntries.length}',
          ),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      print('❌ Erreur lors du debug: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur debug: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: AppPreferences().devise,
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'fr_FR');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      drawer: AyannaDrawer(
        selectedIndex: _drawerIndex,
        onItemSelected: (i) => setState(() => _drawerIndex = i),
      ),
      appBar: AppBar(
        backgroundColor: AyannaColors.orange,
        foregroundColor: AyannaColors.white,
        title: const Text('Journal de Caisse'),
        iconTheme: const IconThemeData(color: AyannaColors.white),
        elevation: 2,
        actions: [
          IconButton(
            tooltip: 'Debug Journal (Console)',
            icon: const Icon(Icons.bug_report),
            onPressed: _debugJournalData,
          ),
          IconButton(
            tooltip: 'Test Paiement + Écritures',
            icon: const Icon(Icons.receipt_long),
            onPressed: _navigateToTestPaiementPage,
          ),
          IconButton(
            tooltip: 'Vérification Comptable (Débit=Crédit)',
            icon: const Icon(Icons.balance),
            onPressed: _navigateToVerificationComptable,
          ),
          IconButton(
            tooltip: 'Nouvelle sortie de caisse',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _navigateToDepensePage, // [AMÉLIORÉ]
          ),
          IconButton(
            tooltip: 'Exporter en PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPdf,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(context, dateFormat),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _journalEntries.isEmpty
                ? RefreshIndicator(
                    onRefresh: _fetchJournalData,
                    child: const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'Aucune opération pour cette date.\nTirez vers le bas pour actualiser.',
                          ),
                        ),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchJournalData,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        elevation: 4,
                        child: Table(
                          border: TableBorder.all(
                            color: AyannaColors.lightGrey,
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(1.0),
                            1: FlexColumnWidth(3.0),
                            2: FlexColumnWidth(2.0),
                            3: FlexColumnWidth(1.5),
                            4: FlexColumnWidth(1.2),
                          },
                          children: [
                            // Header Row
                            TableRow(
                              decoration: BoxDecoration(
                                color: AyannaColors.orange.withOpacity(0.1),
                              ),
                              children: [
                                _buildTableCell('Heure', isHeader: true),
                                _buildTableCell('Description', isHeader: true),
                                _buildTableCell('Élève/Détail', isHeader: true),
                                _buildTableCell('Montant', isHeader: true),
                                _buildTableCell('Type', isHeader: true),
                              ],
                            ),
                            // Data Rows
                            ..._journalEntries.map((entry) {
                              final isEntree =
                                  entry.typeOperation.toLowerCase() == 'entrée';
                              final montantColor = isEntree
                                  ? Colors.green[700]
                                  : Colors.red[700];

                              return TableRow(
                                children: [
                                  _buildTableCell(
                                    timeFormat.format(entry.dateOperation),
                                    isData: true,
                                  ),
                                  _buildDescriptionCell(entry),
                                  _buildJournalDetailCell(entry),
                                  _buildTableCell(
                                    currencyFormat.format(entry.montant),
                                    isData: true,
                                    color: montantColor,
                                  ),
                                  _buildTableCell(
                                    entry.typeOperation,
                                    isData: true,
                                    color: montantColor,
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          _buildSummary(currencyFormat),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, DateFormat dateFormat) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_today),
            label: Text(dateFormat.format(_selectedDate)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
              });
              _fetchJournalData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Aujourd\'hui'),
          ),
          DropdownButton<String>(
            value: _selectedFilter,
            items: ['Tous', 'Entrée', 'Sortie']
                .map(
                  (label) => DropdownMenuItem(value: label, child: Text(label)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedFilter = value;
                });
                _fetchJournalData();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(NumberFormat currencyFormat) {
    // Calculer les statistiques détaillées
    final paiements = _journalEntries
        .where(
          (e) =>
              e.typeOperation.toLowerCase() == 'entrée' &&
              e.paiementFraisId != null,
        )
        .toList();
    final autresEntrees = _journalEntries
        .where(
          (e) =>
              e.typeOperation.toLowerCase() == 'entrée' &&
              e.paiementFraisId == null,
        )
        .toList();

    final totalPaiements = paiements.fold<double>(
      0.0,
      (sum, e) => sum + e.montant,
    );
    final totalAutresEntrees = autresEntrees.fold<double>(
      0.0,
      (sum, e) => sum + e.montant,
    );

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Détail des entrées
            if (paiements.isNotEmpty) ...[
              _buildSummaryRow(
                'Paiements frais (${paiements.length}):',
                totalPaiements,
                Colors.green[600]!,
                currencyFormat,
              ),
            ],
            if (autresEntrees.isNotEmpty) ...[
              _buildSummaryRow(
                'Autres entrées (${autresEntrees.length}):',
                totalAutresEntrees,
                Colors.green[400]!,
                currencyFormat,
              ),
            ],
            _buildSummaryRow(
              'Total des Entrées:',
              _totalEntrees,
              Colors.green[700]!,
              currencyFormat,
            ),
            _buildSummaryRow(
              'Total des Sorties:',
              _totalSorties,
              Colors.red[700]!,
              currencyFormat,
            ),
            const Divider(),
            _buildSummaryRow(
              'Solde du Jour:',
              _soldeDuJour,
              _soldeDuJour >= 0 ? Colors.blue[800]! : Colors.red[700]!,
              currencyFormat,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value,
    Color color,
    NumberFormat format, {
    bool isTotal = false,
  }) {
    final style = TextStyle(
      fontSize: isTotal ? 18 : 16,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style.copyWith(color: Colors.black87)),
          Text(format.format(value), style: style),
        ],
      ),
    );
  }

  /// Construit la cellule de description pour une entrée du journal
  Widget _buildDescriptionCell(JournalComptable entry) {
    if (entry.paiementFraisId == null) {
      // Opération générale (sortie, autre)
      return _buildTableCell(entry.libelle, isData: true, alignLeft: true);
    }

    // Paiement de frais - récupérer le nom du frais
    return FutureBuilder<Map<String, String>>(
      future: _getPaiementDetails(entry.paiementFraisId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildTableCell(entry.libelle, isData: true, alignLeft: true);
        }

        final details =
            snapshot.data ?? {'eleve': '', 'frais': '', 'detail': ''};
        final fraisNom = details['frais'];

        return _buildTableCell(
          fraisNom?.isNotEmpty == true ? fraisNom! : entry.libelle,
          isData: true,
          alignLeft: true,
        );
      },
    );
  }

  /// Construit la cellule des détails pour une entrée du journal
  Widget _buildJournalDetailCell(JournalComptable entry) {
    if (entry.paiementFraisId == null) {
      return _buildTableCell(
        'Opération générale',
        isData: true,
        alignLeft: true,
      );
    }

    return FutureBuilder<Map<String, String>>(
      future: _getPaiementDetails(entry.paiementFraisId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final details =
            snapshot.data ?? {'eleve': '', 'frais': '', 'detail': ''};

        String eleveDetail = details['eleve'] ?? '';
        if (details['detail']?.isNotEmpty == true &&
            details['detail'] != 'complet') {
          eleveDetail += '\n(${details['detail']})';
        }

        return _buildTableCell(
          eleveDetail.isNotEmpty ? eleveDetail : 'Paiement en cours...',
          isData: true,
          alignLeft: true,
        );
      },
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isData = false,
    Color? color,
    bool alignLeft = false,
  }) {
    final style = TextStyle(
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      color: color ?? (isHeader ? AyannaColors.orange : Colors.black87),
      fontSize: 14,
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: alignLeft ? TextAlign.left : TextAlign.center,
        style: style,
      ),
    );
  }
}
