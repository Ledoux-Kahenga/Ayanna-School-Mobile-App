import 'package:ayanna_school/vues/widgets/facture_recu_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/ayanna_theme.dart';
import '../widgets/ayanna_drawer.dart';
import '../../services/school_queries.dart';
import '../../models/models.dart';
import '../../services/app_preferences.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class PaiementDesFrais extends StatefulWidget {
  final AnneeScolaire? anneeScolaire;
  const PaiementDesFrais({super.key, this.anneeScolaire});

  @override
  State<PaiementDesFrais> createState() => _PaiementDesFraisState();
}

class _PaiementDesFraisState extends State<PaiementDesFrais> {
  List<Eleve> _eleves = [];
  List<Eleve> _filteredEleves = [];
  bool _loading = false;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  Eleve? _selectedEleve;
  List<FraisDetails> _fraisDetails = [];
  List<Classe> _classes = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterEleves);
    _initData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    setState(() {
      _loading = true;
      _eleves = [];
      _filteredEleves = [];
      _errorMessage = '';
      _selectedEleve = null;
      _fraisDetails = [];
      _classes = [];
    });
    try {
      AnneeScolaire? anneeScolaireAUtiliser = widget.anneeScolaire;
      anneeScolaireAUtiliser ??= await SchoolQueries.getCurrentAnneeScolaire();
      if (anneeScolaireAUtiliser != null) {
        final loadedClasses = await SchoolQueries.getClassesByAnnee(
          anneeScolaireAUtiliser.id,
        );
        final loadedEleves = await SchoolQueries.getElevesByAnnee(
          anneeScolaireAUtiliser.id,
        );
        setState(() {
          _classes = loadedClasses;
          _eleves = loadedEleves;
          _filteredEleves = _eleves;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des élèves: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _filterEleves() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredEleves = _eleves;
      });
      return;
    }
    final filtered = _eleves
        .where(
          (e) =>
              e.nom.toLowerCase().contains(query) ||
              e.prenom.toLowerCase().contains(query) ||
              (e.matricule?.toLowerCase().contains(query) ?? false),
        )
        .toList();
    // Tri alphabétique
    filtered.sort((a, b) {
      final nomCmp = a.nom.toLowerCase().compareTo(b.nom.toLowerCase());
      if (nomCmp != 0) return nomCmp;
      return a.prenom.toLowerCase().compareTo(b.prenom.toLowerCase());
    });
    setState(() {
      _filteredEleves = filtered;
    });
  }

  Future<void> _loadFraisForEleve(Eleve eleve) async {
    setState(() {
      _selectedEleve = eleve;
      _fraisDetails = [];
      _loading = true;
    });
    try {
      final details = await SchoolQueries.getEleveFraisDetails(eleve.id);
      setState(() {
        _fraisDetails = details.fraisDetails;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Erreur lors du chargement des frais: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int drawerIndex = 0;
    return WillPopScope(
      onWillPop: () async {
        if (_selectedEleve != null) {
          // Si on est sur la vue des frais, le bouton de retour doit revenir à la liste des élèves
          setState(() {
            _selectedEleve = null;
            _fraisDetails = [];
          });
          return false; // Empêche l'application de se fermer
        } else {
          // Si on est sur la liste des élèves (premier niveau), on peut demander une confirmation de sortie
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Quitter l'application"),
              content: const Text(
                "Voulez-vous vraiment quitter Ayanna School ?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AyannaColors.orange,
                  ),
                  child: const Text('Quitter'),
                ),
              ],
            ),
          );
          return shouldExit ?? false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AyannaColors.orange,
          foregroundColor: AyannaColors.white,
          title: const Text(
            'Paiement frais',
            style: TextStyle(color: AyannaColors.white),
          ),
          iconTheme: const IconThemeData(color: AyannaColors.white),
        ),
        drawer: AyannaDrawer(
          selectedIndex: drawerIndex,
          onItemSelected: (i) => setState(() => drawerIndex = i),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                if (_selectedEleve == null)
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AyannaColors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AyannaColors.lightGrey.withOpacity(0.5),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: AyannaColors.darkGrey,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un élève (nom, prénom)',
                        hintStyle: const TextStyle(color: Color(0xFF666666)),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AyannaColors.orange,
                        ),
                        filled: true,
                        fillColor: AyannaColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AyannaColors.lightGrey,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AyannaColors.orange,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                if (_loading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_errorMessage.isNotEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                else if (_selectedEleve == null)
                  Expanded(
                    child: _filteredEleves.isEmpty
                        ? const Center(child: Text('Aucun élève trouvé.'))
                        : ListView.separated(
                            itemCount: _filteredEleves.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              thickness: 0.7,
                              color: AyannaColors.lightGrey,
                              indent: 16,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, i) {
                              final e = _filteredEleves[i];
                              return Card(
                                margin: EdgeInsets.zero,
                                elevation: 0,
                                shape: const RoundedRectangleBorder(),
                                color: AyannaColors.white,
                                child: ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AyannaColors.orange
                                        .withOpacity(0.15),
                                    child: Text(
                                      '${e.prenom[0]}${e.nom[0]}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AyannaColors.orange,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    '${e.nom.toUpperCase()}${e.postnom != null && e.postnom!.isNotEmpty ? ' ${e.postnom!.toUpperCase()}' : ''} ${e.prenomCapitalized}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: AyannaColors.darkGrey,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (e.matricule != null)
                                        Text(
                                          'Mat: ${e.matricule}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF666666),
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Classe : ${e.classeNom ?? "-"}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AyannaColors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: AyannaColors.orange,
                                  ),
                                  shape: const RoundedRectangleBorder(),
                                  onTap: () => _loadFraisForEleve(e),
                                ),
                              );
                            },
                          ),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
                    child: Text(
                      _selectedEleve!.prenomCapitalized,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AyannaColors.darkGrey,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _selectedEleve!.nomPostnomMaj,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AyannaColors.orange,
                        fontSize: 26,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_selectedEleve!.matricule != null)
                    Column(
                      children: [
                        Text(
                          'Matricule : ${_selectedEleve!.matricule!}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Classe : ${_selectedEleve!.classeNom ?? "-"}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AyannaColors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _fraisDetails.isEmpty
                        ? const Center(
                            child: Text('Aucun frais trouvé pour cet élève.'),
                          )
                        : ListView.separated(
                            itemCount: _fraisDetails.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final fd = _fraisDetails[i];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              fd.frais.nom,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                          Text(
                                            fd.statut == 'en_ordre'
                                                ? 'En ordre'
                                                : fd.statut ==
                                                      'partiellement_paye'
                                                ? 'Partiel'
                                                : 'Pas en ordre',
                                            style: TextStyle(
                                              color: fd.statut == 'en_ordre'
                                                  ? AyannaColors.successGreen
                                                  : fd.statut ==
                                                        'partiellement_paye'
                                                  ? AyannaColors.orange
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      FutureBuilder<String>(
                                        future: formatAmount(fd.frais.montant),
                                        builder: (context, snapshot) => Text(
                                          'Montant : ${snapshot.data ?? fd.frais.montant.toStringAsFixed(0)}',
                                        ),
                                      ),
                                      FutureBuilder<String>(
                                        future: formatAmount(fd.montantPaye),
                                        builder: (context, snapshot) => Text(
                                          'Payé : ${snapshot.data ?? fd.montantPaye.toStringAsFixed(0)}',
                                        ),
                                      ),
                                      FutureBuilder<String>(
                                        future: formatAmount(fd.resteAPayer),
                                        builder: (context, snapshot) => Text(
                                          'Reste : ${snapshot.data ?? fd.resteAPayer.toStringAsFixed(0)}',
                                        ),
                                      ),
                                      if (fd
                                          .historiquePaiements
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Historique :',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                        _buildPaiementTable(
                                          fd.historiquePaiements,
                                        ), // Table view here
                                      ],
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (fd.resteAPayer > 0)
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.payment),
                                              label: const Text('Régler'),
                                              onPressed: () async {
                                                final montantController =
                                                    TextEditingController();
                                                final result = await showDialog<double>(
                                                  context: context,
                                                  builder: (ctx) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                        'Effectuer un paiement',
                                                      ),
                                                      content: TextField(
                                                        controller:
                                                            montantController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration: InputDecoration(
                                                          labelText:
                                                              'Montant à payer (max ${fd.resteAPayer.toStringAsFixed(0)})',
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                ctx,
                                                              ).pop(),
                                                          child: const Text(
                                                            'Annuler',
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            final value =
                                                                double.tryParse(
                                                                  montantController
                                                                      .text,
                                                                );
                                                            if (value != null &&
                                                                value > 0 &&
                                                                value <=
                                                                    fd.resteAPayer) {
                                                              Navigator.of(
                                                                ctx,
                                                              ).pop(value);
                                                            }
                                                          },
                                                          child: const Text(
                                                            'Valider',
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                                if (result != null) {
                                                  final paiement = PaiementFrais(
                                                    id: 0,
                                                    eleveId: _selectedEleve!.id,
                                                    fraisScolaireId:
                                                        fd.frais.id,
                                                    montantPaye: result,
                                                    datePaiement: DateFormat(
                                                      'dd-MM-yyyy',
                                                    ).format(DateTime.now()),
                                                    resteAPayer:
                                                        fd.resteAPayer - result,
                                                    statut:
                                                        fd.resteAPayer -
                                                                result <=
                                                            0
                                                        ? 'en_ordre'
                                                        : 'partiellement_paye',
                                                    userId: 1,
                                                  );
                                                  await SchoolQueries.insertPaiement(
                                                    _selectedEleve!.id,
                                                    fd.frais.id,
                                                    result,
                                                    2,
                                                    2,
                                                  );
                                                  await _loadFraisForEleve(
                                                    _selectedEleve!,
                                                  );
                                                }
                                              },
                                            ),
                                          if (fd.montantPaye > 0)
                                            const SizedBox(width: 8),
                                          if (fd.montantPaye > 0)
                                            ElevatedButton.icon(
                                              icon: fd.showRecu
                                                  ? const Icon(Icons.print)
                                                  : const Icon(
                                                      Icons.receipt_long,
                                                    ),
                                              label: Text(
                                                fd.showRecu
                                                    ? 'Imprimer'
                                                    : 'Facture',
                                              ),
                                              onPressed: () async {
                                                if (!fd.showRecu) {
                                                  setState(() {
                                                    fd.showRecu = true;
                                                  });
                                                } else {
                                                  // Impression PDF avec le package printing
                                                  await Printing.layoutPdf(
                                                    onLayout: (format) async {
                                                      final doc = pw.Document();
                                                      doc.addPage(
                                                        pw.Page(
                                                          build: (pw.Context context) {
                                                            return pw.Column(
                                                              crossAxisAlignment: pw
                                                                  .CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                pw.Text(
                                                                  'Généré par Ayanna School - ${DateTime.now()}',
                                                                ),
                                                                pw.Text(
                                                                  'Default School',
                                                                ),
                                                                pw.Text(
                                                                  '14 Av. Bunduki, Q. Plateau, C. Annexe',
                                                                ),
                                                                pw.Text(
                                                                  'Tél : +243997554905',
                                                                ),
                                                                pw.Text(
                                                                  'Email : comtact@school.com',
                                                                ),
                                                                pw.Divider(),
                                                                pw.Text(
                                                                  'REÇU FRAIS',
                                                                  style: pw.TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight: pw
                                                                        .FontWeight
                                                                        .bold,
                                                                  ),
                                                                ),
                                                                pw.Text(
                                                                  'Élève : ${_selectedEleve!.prenomCapitalized} ${_selectedEleve!.nomPostnomMaj}',
                                                                ),
                                                                pw.Text(
                                                                  'Classe : ${_selectedEleve!.classeNom ?? "-"}',
                                                                ),
                                                                pw.Text(
                                                                  'Frais : ${fd.frais.nom}',
                                                                ),
                                                                pw.Text(
                                                                  'Paiements :',
                                                                ),
                                                                pw.Table.fromTextArray(
                                                                  headers: [
                                                                    'Date',
                                                                    'Montant',
                                                                    'Caissier',
                                                                  ],
                                                                  data: fd
                                                                      .historiquePaiements
                                                                      .map(
                                                                        (p) => [
                                                                          p.datePaiement,
                                                                          p.montantPaye,

                                                                          'Admin',
                                                                        ],
                                                                      )
                                                                      .toList(),
                                                                ),
                                                                pw.Text(
                                                                  'Total payé : ${fd.montantPaye.toInt()} Fc',
                                                                ),
                                                                pw.Text(
                                                                  'Reste : ${fd.resteAPayer.toInt()} Fc',
                                                                ),
                                                                pw.Text(
                                                                  'Statut : ${fd.statut == 'en_ordre'
                                                                      ? 'En ordre'
                                                                      : fd.statut == 'partiellement_paye'
                                                                      ? 'Partiel'
                                                                      : 'Pas en ordre'}',
                                                                ),
                                                                pw.SizedBox(
                                                                  height: 16,
                                                                ),
                                                                pw.Text(
                                                                  'Merci pour votre paiement.',
                                                                  style: pw.TextStyle(
                                                                    fontStyle: pw
                                                                        .FontStyle
                                                                        .italic,
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      );
                                                      return doc.save();
                                                    },
                                                  );
                                                  setState(() {
                                                    fd.showRecu = false;
                                                  });
                                                }
                                              },
                                            ),
                                        ],
                                      ),
                                      if (fd.showRecu ?? false)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: FactureRecuWidget(
                                            eleve:
                                                '${_selectedEleve!.prenomCapitalized} ${_selectedEleve!.nomPostnomMaj}',
                                            classe:
                                                _selectedEleve!.classeNom ??
                                                '-',
                                            frais: fd.frais.nom,
                                            paiements: fd.historiquePaiements
                                                .map(
                                                  (p) => {
                                                    'date': p.datePaiement,
                                                    'montant': p.montantPaye
                                                        .toStringAsFixed(0),
                                                    'caissier': 'Admin',
                                                  },
                                                )
                                                .toList(),
                                            totalPaye: fd.montantPaye.toInt(),
                                            reste: fd.resteAPayer.toInt(),
                                            statut: fd.statut == 'en_ordre'
                                                ? 'En ordre'
                                                : fd.statut ==
                                                      'partiellement_paye'
                                                ? 'Partiel'
                                                : 'Pas en ordre',
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedEleve = null;
                        _fraisDetails = [];
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Retour à la liste'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // New widget for the table view
  Widget _buildPaiementTable(List<PaiementFrais> paiements) {
    if (paiements.isEmpty) {
      return const Text("Aucun paiement enregistré.");
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AyannaColors.lightGrey),
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: const BorderSide(color: AyannaColors.lightGrey),
        ),
        columnWidths: const {
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.0),
        },
        children: [
          // Header Row
          TableRow(
            decoration: BoxDecoration(
              color: AyannaColors.orange.withOpacity(0.1),
            ),
            children: [
              _buildTableCell('Date', isHeader: true),
              _buildTableCell('Montant', isHeader: true),
              _buildTableCell('Caissier', isHeader: true),
            ],
          ),
          // Data Rows
          ...paiements.map((p) {
            return TableRow(
              children: [
                _buildTableCell(p.datePaiement),
                _buildTableCell('${p.montantPaye.toStringAsFixed(0)} Fc'),
                _buildTableCell('Admin'),
              ],
            );
          }),
        ],
      ),
    );
  }

  // Helper method for consistent cell styling
  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? AyannaColors.orange : AyannaColors.darkGrey,
          fontSize: 14,
        ),
      ),
    );
  }
}
