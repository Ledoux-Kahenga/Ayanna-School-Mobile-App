import 'package:ayanna_school/models/models.dart';
import 'package:ayanna_school/services/school_queries.dart';
import 'package:ayanna_school/vues/gestions%20frais/depense_sortie.dart';
import 'package:ayanna_school/vues/widgets/ayanna_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../../theme/ayanna_theme.dart';

class JournalCaisse extends StatefulWidget {
  const JournalCaisse({super.key});

  @override
  State<JournalCaisse> createState() => _JournalCaisseState();
}

class _JournalCaisseState extends State<JournalCaisse> {
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

    final entries = await SchoolQueries.getJournalEntries(
      _selectedDate,
      filter: _selectedFilter,
    );

    setState(() {
      _journalEntries = entries;
      _calculateTotals();
      _isLoading = false;
    });
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité d\'exportation PDF à implémenter.'),
      ),
    );
  }

  // [AMÉLIORÉ] Navigue et rafraîchit les données au retour
  Future<void> _navigateToDepensePage() async {
    final result = await Navigator.push<bool>(
      context, 
      MaterialPageRoute(builder: (context) => const DepenseSortiePage())
    );

    // Si la page de dépense a renvoyé 'true', on rafraîchit les données
    if (result == true) {
      _fetchJournalData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FC', decimalDigits: 2);
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
            tooltip: 'Nouvelle sortie de caisse',
            icon: const Icon(Icons.trending_down),
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
                ? const Center(child: Text('Aucune opération pour cette date.'))
                : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      elevation: 4,
                      child: Table(
                        border: TableBorder.all(color: AyannaColors.lightGrey),
                        columnWidths: const {
                          0: FlexColumnWidth(1.2),
                          1: FlexColumnWidth(3.5),
                          2: FlexColumnWidth(2.0),
                          3: FlexColumnWidth(1.5),
                        },
                        children: [
                          // Header Row
                          TableRow(
                            decoration: BoxDecoration(
                              color: AyannaColors.orange.withOpacity(0.1),
                            ),
                            children: [
                              _buildTableCell('Heure', isHeader: true),
                              _buildTableCell('Libellé', isHeader: true),
                              _buildTableCell('Montant', isHeader: true),
                              _buildTableCell('Type', isHeader: true),
                            ],
                          ),
                          // Data Rows
                          ..._journalEntries.map((entry) {
                            final isEntree = entry.typeOperation.toLowerCase() == 'entrée';
                            final montantColor = isEntree
                                ? Colors.green[700]
                                : Colors.red[700];
                            return TableRow(
                              children: [
                                _buildTableCell(
                                  timeFormat.format(entry.dateOperation),
                                  isData: true,
                                ),
                                _buildTableCell(entry.libelle, isData: true, alignLeft: true),
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
                          }).toList(),
                        ],
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
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isData = false,
    Color? color,
    bool alignLeft = false
  }) {
    final style = TextStyle(
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      color: color ?? (isHeader ? AyannaColors.orange : Colors.black87),
      fontSize: 14,
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, textAlign: alignLeft ? TextAlign.left : TextAlign.center, style: style),
    );
  }
}