import 'package:ayanna_school/vues/widgets/facture_recu_widget.dart';
import 'package:flutter/material.dart';
import '../../theme/ayanna_theme.dart';
import '../widgets/ayanna_appbar.dart';
import '../widgets/ayanna_drawer.dart';
import '../../services/school_queries.dart';
import '../../models/models.dart';
import '../../services/app_preferences.dart';
import '../widgets/facture_dialog.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;


class PaiementDesFrais extends StatefulWidget {


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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterEleves);
    _loadAllEleves();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllEleves() async {
    setState(() {
      _loading = true;
      _eleves = [];
      _filteredEleves = [];
      _errorMessage = '';
      _selectedEleve = null;
      _fraisDetails = [];
    });
    try {
      // Récupère tous les élèves de l'année scolaire courante
      // Utilise la valeur de l'année scolaire courante passée depuis main.dart
      final yearId = 1; // Remplacez par la logique pour obtenir l'année scolaire courante
      if (yearId == null) {
        setState(() {
          _loading = false;
          // _errorMessage = 'Aucune année scolaire sélectionnée.${widget.anneeScolaire?.nom}';
          // print('Année Scolaire en cours dans frais : ${widget.anneeScolaire?.nom}');
        });
        return;
      }
      final classes = await SchoolQueries.getClassesByAnnee(yearId);
      // Create a map of classeId to class name
      final classeIdToNom = {for (var c in classes) c.id: c.nom};
      List<Eleve> allEleves = [];
      for (final classe in classes) {
        final eleves = await SchoolQueries.getElevesByClasse(classe.id);
        // For each eleve, set classeNom
        final elevesWithClasseNom = eleves
            .map(
              (e) => Eleve(
                id: e.id,
                nom: e.nom,
                prenom: e.prenom,
                sexe: e.sexe,
                dateNaissance: e.dateNaissance,
                lieuNaissance: e.lieuNaissance,
                numeroPermanent: e.numeroPermanent,
                classeId: e.classeId,
                responsableId: e.responsableId,
                matricule: e.matricule,
                postnom: e.postnom,
                statut: e.statut,
                classeNom: classe.nom,
              ),
            )
            .toList();
        allEleves.addAll(elevesWithClasseNom);
      }
      // Tri alphabétique par nom puis prénom
      allEleves.sort((a, b) {
        final nomCmp = a.nom.toLowerCase().compareTo(b.nom.toLowerCase());
        if (nomCmp != 0) return nomCmp;
        return a.prenom.toLowerCase().compareTo(b.prenom.toLowerCase());
      });
      setState(() {
        _eleves = allEleves;
        _filteredEleves = allEleves;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Erreur lors du chargement des élèves: $e';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AyannaColors.orange,
        foregroundColor: AyannaColors.white,
        title: const Text(
          'Paiement frais',
          style: TextStyle(color: AyannaColors.white),
        ),
        iconTheme: const IconThemeData(color: AyannaColors.white),
      ),
      drawer: const AyannaDrawer(),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
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
                                  '${e.nom.toUpperCase()}${e.postnom != null && e.postnom!.isNotEmpty ? ' ' + e.postnom!.toUpperCase() : ''} ${e.prenomCapitalized}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AyannaColors.darkGrey,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    if (fd.historiquePaiements.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Historique :',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      ...fd.historiquePaiements.map(
                                        (p) => Text(
                                          '• ${p.datePaiement} : +${p.montantPaye.toStringAsFixed(0)}',
                                        ),
                                      ),
                                    ],
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
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
                                                          TextInputType.number,
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
                                                  fraisScolaireId: fd.frais.id,
                                                  montantPaye: result,
                                                  datePaiement: DateTime.now()
                                                      .toIso8601String()
                                                      .substring(0, 10),
                                                  resteAPayer:
                                                      fd.resteAPayer - result,
                                                  statut:
                                                      fd.resteAPayer - result <=
                                                          0
                                                      ? 'en_ordre'
                                                      : 'partiellement_paye',
                                                  userId: 1,
                                                );
                                                await SchoolQueries.insertPaiement(
                                                  paiement,
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
                                                                  fontSize: 20,
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
                                                                        p.montantPaye
                                                                            .toStringAsFixed(
                                                                              0,
                                                                            ),
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
                                              _selectedEleve!
                                                  .prenomCapitalized +
                                              ' ' +
                                              _selectedEleve!.nomPostnomMaj,
                                          classe:
                                              _selectedEleve!.classeNom ?? '-',
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
    );
  }
}

// Ici, l'année scolaire est utilisée uniquement pour charger les élèves et frais liés à l'année courante.
