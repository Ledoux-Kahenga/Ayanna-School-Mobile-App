import 'package:flutter/material.dart';
import '../widgets/ayanna_appbar.dart';
import '../widgets/ayanna_drawer.dart';
import '../../models/models.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../theme/ayanna_theme.dart';
import '../../services/school_queries.dart';

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
  List<String> statuts = ['actif', 'inactif', 'exclu'];
  List<Eleve> eleves = [];
  List<Eleve> filteredEleves = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
    filteredEleves = eleves;
  }

  Future<void> _loadClasses() async {
    final year = widget.anneeScolaire;
    if (year != null) {
      final loadedClasses = await SchoolQueries.getClassesByAnnee(year.id);
      setState(() {
        classes = loadedClasses;
      });
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
                headers: ['Nom', 'Prénom', 'Classe', 'Statut'],
                data: filteredEleves
                    .map(
                      (e) => [
                        e.nom,
                        e.prenom,
                        e.classeNom ?? '-',
                        e.statut ?? '-',
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
    return Scaffold(
      appBar: AyannaAppBar(
        title: 'Liste des élèves',
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exporter PDF',
            onPressed: _exportPDF,
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Ajouter un élève',
            onPressed: () async {
              final result = await Navigator.of(
                context,
              ).pushNamed('/add-eleve', arguments: selectedClasse?.id);
              if (result == true) {
                // TODO: Recharger les élèves depuis la base
                setState(() {
                  // Vous pouvez ici appeler une méthode pour rafraîchir la liste
                });
              }
            },
          ),
        ],
      ),
      drawer: const AyannaDrawer(),
      body: Container(
        color: AyannaColors.orange.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Rechercher un élève',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  searchQuery = value;
                  _filterEleves();
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Classe>(
                      value: selectedClasse,
                      decoration: const InputDecoration(
                        labelText: 'Classe',
                        border: OutlineInputBorder(),
                      ),
                      items: classes.map((classe) {
                        return DropdownMenuItem<Classe>(
                          value: classe,
                          child: Text(classe.nom),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedClasse = value;
                        _filterEleves();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedStatut,
                      decoration: const InputDecoration(
                        labelText: 'Statut',
                        border: OutlineInputBorder(),
                      ),
                      items: statuts.map((statut) {
                        return DropdownMenuItem<String>(
                          value: statut,
                          child: Text(statut),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedStatut = value;
                        _filterEleves();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: filteredEleves.isEmpty
                    ? const Center(child: Text('Aucun élève trouvé.'))
                    : ListView.builder(
                        itemCount: filteredEleves.length,
                        itemBuilder: (context, index) {
                          final eleve = filteredEleves[index];
                          return Card(
                            color: AyannaColors.orange.withOpacity(0.2),
                            child: ListTile(
                              title: Text(eleve.formattedNomPrenom),
                              subtitle: Text(
                                'Classe: ${eleve.classeNom ?? '-'} | Statut: ${eleve.statut ?? '-'}',
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
