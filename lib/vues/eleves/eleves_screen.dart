import 'package:flutter/material.dart';
import '../widgets/ayanna_appbar.dart';
import '../widgets/ayanna_drawer.dart';
import '../../models/models.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../theme/ayanna_theme.dart';
import '../../services/school_queries.dart';
import 'edit_eleve_screen.dart'; // Assurez-vous d'importer l'écran de modification

class ElevesScreen extends StatefulWidget {
  final AnneeScolaire? anneeScolaire;
  const ElevesScreen({super.key, this.anneeScolaire});

  @override
  State<ElevesScreen> createState() => _ElevesScreenState();
}

class _ElevesScreenState extends State<ElevesScreen> {
  String searchQuery = '';
  Classe? selectedClasse;
  String? selectedStatut;
  List<Classe> classes = [];
  List<String> statuts = ['actif', 'abandonné', 'transféré', 'exclu'];
  List<Eleve> eleves = [];
  List<Eleve> filteredEleves = [];
  bool isLoading = true; // Pour afficher un indicateur de chargement

  @override
  void initState() {
    super.initState();
    _initData(); // Appel de la nouvelle fonction de chargement
  }

  // MODIFIÉ : Nouvelle fonction centralisée pour charger toutes les données nécessaires
  Future<void> _initData() async {
    setState(() => isLoading = true);

    // 1. Détermine quelle année scolaire utiliser
    AnneeScolaire? anneeScolaireAUtiliser = widget.anneeScolaire;
    anneeScolaireAUtiliser ??= await SchoolQueries.getCurrentAnneeScolaire();

    // 2. Si une année scolaire est trouvée, charge les classes et les élèves
    if (anneeScolaireAUtiliser != null) {
      final loadedClasses = await SchoolQueries.getClassesByAnnee(
        anneeScolaireAUtiliser.id,
      );
      final loadedEleves = await SchoolQueries.getElevesByAnnee(
        anneeScolaireAUtiliser.id,
      );

      if (mounted) {
        setState(() {
          classes = loadedClasses;
          eleves = loadedEleves;
          filteredEleves = eleves;
        });
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _filterEleves() {
    setState(() {
      filteredEleves = eleves.where((e) {
        final matchClasse =
            selectedClasse == null || e.classeId == selectedClasse!.id;
        final matchStatut =
            selectedStatut == null || e.statut == selectedStatut;
        final matchSearch =
            searchQuery.isEmpty ||
            e.nom.toLowerCase().contains(searchQuery.toLowerCase()) ||
            e.prenom.toLowerCase().contains(searchQuery.toLowerCase());
        return matchClasse && matchStatut && matchSearch;
      }).toList();
    });
  }

  Future<void> _exportPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Liste des élèves',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Table.fromTextArray(
                headers: [
                  'Nom',
                  'Post-nom',
                  'Prénom',
                  'Classe',
                  'Responsable',
                  'Tél Responsable',
                ],
                data: filteredEleves
                    .map(
                      (e) => [
                        e.nom,
                        e.postnom,
                        e.prenom,
                        e.classeNom ?? '-',
                        e.responsableNom,
                        e.responsableTelephone ?? '-',
                      ],
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    int drawerIndex = 3;
    return Scaffold(
      appBar: AyannaAppBar(
        title: 'Liste des élèves',
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exporter PDF',
            onPressed: _exportPDF,
          ),
          // Le bouton Ajouter un élève est maintenant un FloatingActionButton
        ],
      ),
      drawer: AyannaDrawer(
        selectedIndex: drawerIndex,
        onItemSelected: (i) => setState(() => drawerIndex = i),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Column(
          children: [
           Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AyannaColors.orange,
                      width: 2.0,
                    ),
                  ),
                ),
              child: TextField(
                decoration: InputDecoration(
                      hintText: 'Rechercher un élève',
                      hintStyle: const TextStyle(color: Color(0xFF666666)),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AyannaColors.orange,
                      ),
                      filled: true,
                      fillColor: AyannaColors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 16,
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  
                onChanged: (value) {
                  searchQuery = value;
                  _filterEleves();
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Classe?>(
                    value: selectedClasse,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Classe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: AyannaColors.orange, width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: AyannaColors.orange, width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: AyannaColors.orange, width: 1.0),
                      ),
                    ),
                    
                    hint: const Text('Toutes les classes'),
                    items: [
                      const DropdownMenuItem<Classe?>(
                        value: null,
                        child: Text('Toutes les classes'),
                      ),
                      ...classes.map((classe) {
                        return DropdownMenuItem<Classe>(
                          value: classe,
                          child: Text(classe.nom),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      selectedClasse = value;
                      _filterEleves();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: selectedStatut,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Statut',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: AyannaColors.orange, width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: AyannaColors.orange, width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: AyannaColors.orange, width: 1.0),
                      ),
                    ),
                    hint: const Text('Tous les statuts'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tous les statuts'),
                      ),
                      ...statuts.map((statut) {
                        return DropdownMenuItem<String>(
                          value: statut,
                          child: Text(statut),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      selectedStatut = value;
                      _filterEleves();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEleves.isEmpty
                      ? const Center(child: Text('Aucun élève trouvé.'))
                      : SingleChildScrollView(
                          child: Table(
                            border: TableBorder.all(
                              color: AyannaColors.lightGrey,
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(0.5),
                              1: FlexColumnWidth(2.5),
                              2: FlexColumnWidth(1.5),
                            },
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(
                                  color: AyannaColors.orange,
                                ),
                                children: [
                                  _HeaderCell('N°'),
                                  _HeaderCell('Nom complet'),
                                  _HeaderCell('Classe'),
                                ],
                              ),
                              ...filteredEleves.asMap().entries.map(
                                (entry) {
                                  final index = entry.key;
                                  final eleve = entry.value;
                                  return TableRow(
                                    children: [
                                      _DataCell((index + 1).toString()),
                                      GestureDetector(
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditEleveScreen(eleve: eleve),
                                            ),
                                          );
                                          if (result == true) {
                                            _initData();
                                          }
                                        },
                                        child: _DataCell(
                                          '${eleve.nom.toUpperCase()}${eleve.postnom != null && eleve.postnom!.isNotEmpty ? ' ${eleve.postnom!.toUpperCase()}' : ''} ${eleve.prenomCapitalized}',
                                        ),
                                      ),
                                      _DataCell(eleve.classeNom ?? '-'),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed('/add-eleve', arguments: selectedClasse?.id);
          if (result == true) {
            _initData();
          }
        },
        tooltip: 'Ajouter un élève',
        backgroundColor: AyannaColors.orange,
        foregroundColor: AyannaColors.white,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AyannaColors.white,
          fontSize: 14,
        ),
        // textAlign: TextAlign.center,
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  const _DataCell(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
        // textAlign: TextAlign.center,
      ),
    );
  }
}