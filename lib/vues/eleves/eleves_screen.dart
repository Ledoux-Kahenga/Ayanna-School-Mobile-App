import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/ayanna_appbar.dart';
import '../widgets/ayanna_drawer.dart';
import 'package:ayanna_school/models/entities/entities.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../theme/ayanna_theme.dart';
import 'package:ayanna_school/services/providers/providers.dart';
import 'edit_eleve_screen.dart';

class ElevesScreen extends ConsumerStatefulWidget {
  final AnneeScolaire? anneeScolaire;
  const ElevesScreen({super.key, this.anneeScolaire});

  @override
  ConsumerState<ElevesScreen> createState() => _ElevesScreenState();
}

class _ElevesScreenState extends ConsumerState<ElevesScreen> {
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

  // Fonction centralisée pour charger toutes les données nécessaires
  Future<void> _initData() async {
    setState(() => isLoading = true);

    try {
      // 1. Détermine quelle année scolaire utiliser
      AnneeScolaire? anneeScolaireAUtiliser = widget.anneeScolaire;
      if (anneeScolaireAUtiliser == null) {
        anneeScolaireAUtiliser = await ref.read(
          currentAnneeScolaireProvider.future,
        );
      }

      if (anneeScolaireAUtiliser != null) {
        // 2. Charge les classes filtrées par année scolaire
        final allClasses = await ref.read(classesNotifierProvider.future);
        final loadedClasses = allClasses
            .where(
              (classe) => classe.anneeScolaireId == anneeScolaireAUtiliser!.id,
            )
            .toList();

        // 3. Charge les élèves filtrés par année scolaire (via les classes)
        final allEleves = await ref.read(elevesNotifierProvider.future);
        final classeIds = loadedClasses.map((c) => c.id).toSet();
        final loadedEleves = allEleves
            .where((eleve) => classeIds.contains(eleve.classeId))
            .toList();

        if (mounted) {
          setState(() {
            classes = loadedClasses;
            eleves = loadedEleves;
            filteredEleves = eleves;
          });
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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
    // Charger les responsables et classes pour le PDF
    final allResponsables = await ref.read(responsablesNotifierProvider.future);
    final responsablesMap = {for (var r in allResponsables) r.id: r};
    final classesMap = {for (var c in classes) c.id: c};

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
                data: filteredEleves.map((e) {
                  final responsable = e.responsableId != null
                      ? responsablesMap[e.responsableId]
                      : null;
                  final classe = e.classeId != null
                      ? classesMap[e.classeId]
                      : null;

                  return [
                    e.nom,
                    e.postnom ?? '-',
                    e.prenom,
                    classe?.nom ?? '-',
                    responsable?.nom ?? '-',
                    responsable?.telephone ?? '-',
                  ];
                }).toList(),
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
                  bottom: BorderSide(color: AyannaColors.orange, width: 2.0),
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
                        borderSide: const BorderSide(
                          color: AyannaColors.orange,
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(
                          color: AyannaColors.orange,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(
                          color: AyannaColors.orange,
                          width: 1.0,
                        ),
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
                        borderSide: const BorderSide(
                          color: AyannaColors.orange,
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(
                          color: AyannaColors.orange,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(
                          color: AyannaColors.orange,
                          width: 1.0,
                        ),
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
                        border: TableBorder.all(color: AyannaColors.lightGrey),
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
                          ...filteredEleves.asMap().entries.map((entry) {
                            final index = entry.key;
                            final eleve = entry.value;
                            // Trouver la classe correspondante
                            final classe = eleve.classeId != null
                                ? classes.firstWhere(
                                    (c) => c.id == eleve.classeId,
                                    orElse: () => Classe(
                                      id: null,
                                      serverId: null,
                                      isSync: false,
                                      nom: '-',
                                      anneeScolaireId: 0,
                                      effectif: 0,
                                      dateCreation: DateTime.now(),
                                      dateModification: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                    ),
                                  )
                                : null;
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
                                _DataCell(classe?.nom ?? '-'),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).pushNamed('/add-eleve', arguments: selectedClasse?.id);
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
