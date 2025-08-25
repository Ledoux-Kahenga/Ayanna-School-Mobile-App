// Fichier : lib/vues/classes/classe_eleves_screen.dart

import 'package:ayanna_school/vues/classes/classe_elevePDF.dart';
import 'package:flutter/material.dart';
import '../../theme/ayanna_theme.dart';
import '../../services/school_queries.dart';
import '../../models/models.dart';
import 'classe_eleve_details_screen.dart';

class ClassElevesScreen extends StatefulWidget {
  final Classe classe;
  
  const ClassElevesScreen({required this.classe, super.key});

  @override
  State<ClassElevesScreen> createState() => _ClassElevesScreenState();
}

enum EleveFilter { tous, enOrdre, pasEnOrdre }

class _ClassElevesScreenState extends State<ClassElevesScreen> {
  List<Eleve> _eleves = [];
  List<Eleve> _filteredEleves = [];
  Map<int, List<PaiementFrais>> _elevePaiements = {}; // Nouvelle map pour stocker les paiements
  List<FraisScolaire> _fraisList = [];
  FraisScolaire? _selectedFrais;
  bool _loading = true;
  int _totalEleves = 0;
  int _enOrdre = 0;
  int _pasEnOrdre = 0;
  double _totalAttendu = 0;
  double _totalRecu = 0;
  EleveFilter _currentFilter = EleveFilter.tous;
  

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    try {
      final eleves = await SchoolQueries.getElevesByClasse(widget.classe.id);
      final fraisList = await SchoolQueries.getAllFraisByClasse(
        widget.classe.id,
      );

      // Récupération des paiements pour chaque élève
      final Map<int, List<PaiementFrais>> paiementsMap = {};
      for (final eleve in eleves) {
        final paiements = await SchoolQueries.getPaiementsByEleve(eleve.id);
        paiementsMap[eleve.id] = paiements;
      }

      setState(() {
        _eleves = eleves;
        _fraisList = fraisList;
        _selectedFrais = fraisList.isNotEmpty ? fraisList.first : null;
        _elevePaiements = paiementsMap; // Stockage des paiements
        _calculateDashboardData();
        _filterEleves(_currentFilter);
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print('Erreur lors du chargement des données: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _calculateDashboardData() {
    if (_selectedFrais == null) {
      _totalEleves = 0;
      _enOrdre = 0;
      _pasEnOrdre = 0;
      _totalAttendu = 0;
      _totalRecu = 0;
      return;
    }

    _totalEleves = _eleves.length;
    _totalAttendu = _eleves.length * _selectedFrais!.montant;
    _totalRecu = 0;
    _enOrdre = 0;
    _pasEnOrdre = 0;

    for (final eleve in _eleves) {
      final montantPaye = (_elevePaiements[eleve.id] ?? []) // Utilisation de la nouvelle map
          .where((fraisPaye) => fraisPaye.fraisScolaireId == _selectedFrais!.id)
          .fold<double>(0.0, (sum, item) => sum + item.montantPaye);

      _totalRecu += montantPaye;

      if (montantPaye >= _selectedFrais!.montant) {
        _enOrdre++;
      } else {
        _pasEnOrdre++;
      }
    }
  }

  void _filterEleves(EleveFilter filter) {
    setState(() {
      _currentFilter = filter;
      if (filter == EleveFilter.tous) {
        _filteredEleves = _eleves;
      } else if (filter == EleveFilter.enOrdre) {
        _filteredEleves = _eleves.where((e) {
          final montantPaye = (_elevePaiements[e.id] ?? []) // Utilisation de la nouvelle map
              .where(
                  (fraisPaye) => fraisPaye.fraisScolaireId == _selectedFrais!.id)
              .fold<double>(0.0, (sum, item) => sum + item.montantPaye);
          return montantPaye >= _selectedFrais!.montant;
        }).toList();
      } else {
        _filteredEleves = _eleves.where((e) {
          final montantPaye = (_elevePaiements[e.id] ?? []) // Utilisation de la nouvelle map
              .where(
                  (fraisPaye) => fraisPaye.fraisScolaireId == _selectedFrais!.id)
              .fold<double>(0.0, (sum, item) => sum + item.montantPaye);
          return montantPaye < _selectedFrais!.montant;
        }).toList();
      }
    });
  }

  void _navigateToEleveDetails(Eleve eleve) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClasseEleveDetailsScreen(
          eleve: eleve,
          frais: _selectedFrais,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (pas de changement ici, tout le reste du widget est correct)
    return Scaffold(
      backgroundColor: AyannaColors.lightGrey,
      appBar: AppBar(
        title: Text('Classe: ${widget.classe.nom}'),
        backgroundColor: AyannaColors.orange,
        foregroundColor: AyannaColors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _eleves.isEmpty
              ? const Center(child: Text('Aucun élève trouvé pour cette classe.'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Sélection du type de frais
                        _fraisList.isEmpty
                            ? const Text('Aucun frais scolaire défini pour cette classe.')
                            : DropdownButtonFormField<FraisScolaire>(
                                value: _selectedFrais,
                                decoration: const InputDecoration(
                                  labelText: 'Sélectionner un frais',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: AyannaColors.white,
                                ),
                                items: _fraisList
                                    .map((frais) => DropdownMenuItem(
                                          value: frais,
                                          child: Text(frais.nom),
                                        ))
                                    .toList(),
                                onChanged: (frais) {
                                  setState(() {
                                    _selectedFrais = frais;
                                    _calculateDashboardData();
                                    _filterEleves(_currentFilter);
                                  });
                                },
                              ),
                        const SizedBox(height: 16),
                        // TABLEAU DE BORD DYNAMIQUE EN BOUTONS
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildDashboardCard(
                              'Total',
                              _totalEleves.toString(),
                              Icons.group,
                              _currentFilter == EleveFilter.tous,
                              () => _filterEleves(EleveFilter.tous),
                            ),
                            _buildDashboardCard(
                              'En ordre',
                              _enOrdre.toString(),
                              Icons.check_circle_outline,
                              _currentFilter == EleveFilter.enOrdre,
                              () => _filterEleves(EleveFilter.enOrdre),
                            ),
                            _buildDashboardCard(
                              'Pas en ordre',
                              _pasEnOrdre.toString(),
                              Icons.warning_amber,
                              _currentFilter == EleveFilter.pasEnOrdre,
                              () => _filterEleves(EleveFilter.pasEnOrdre),
                            ),
                            _buildDashboardCard(
                              'Montant total payé',
                              '${_totalRecu.toStringAsFixed(2)} \$',
                              Icons.monetization_on,
                              false,
                              () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // TABLEAU DES ÉLÈVES
                        if (_selectedFrais != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Liste des élèves (${_filteredEleves.length})',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Card(
                                elevation: 1,
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(1),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(2),
                                    3: FlexColumnWidth(1),
                                  },
                                  border: TableBorder.all(
                                    color: AyannaColors.lightGrey.withOpacity(0.5),
                                    width: 1,
                                  ),
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(
                                        color: AyannaColors.orange,
                                      ),
                                      children:  [
                                        _buildTableHeader('N°'),
                                        _buildTableHeader('Nom'),
                                        _buildTableHeader('Prénom'),
                                        _buildTableHeader('Statut'),
                                      ],
                                    ),
                                    ..._filteredEleves.asMap().entries.map(
                                      (entry) {
                                        final index = entry.key;
                                        final eleve = entry.value;
                                        final montantPaye = (_elevePaiements[eleve.id] ?? []) // Utilisation de la nouvelle map
                                            .where((f) => f.fraisScolaireId == _selectedFrais!.id)
                                            .fold<double>(0.0, (sum, item) => sum + item.montantPaye);

                                        final estEnOrdre = montantPaye >= _selectedFrais!.montant;
                                        
                                        return TableRow(
                                          children: [
                                            InkWell(
                                              onTap: () => _navigateToEleveDetails(eleve),
                                              child: _buildTableCell('${index + 1}'),
                                            ),
                                            InkWell(
                                              onTap: () => _navigateToEleveDetails(eleve),
                                              child: _buildTableCell(eleve.nom),
                                            ),
                                            InkWell(
                                              onTap: () => _navigateToEleveDetails(eleve),
                                              child: _buildTableCell(eleve.prenom),
                                            ),
                                            InkWell(
                                              onTap: () => _navigateToEleveDetails(eleve),
                                              child: _buildTableCell(
                                                estEnOrdre ? 'Oui' : 'Non',
                                                color: estEnOrdre ? Colors.green[800] : Colors.red[800],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ).toList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ... (les méthodes _buildDashboardCard, _buildTableHeader, _buildTableCell ne changent pas)
  Widget _buildDashboardCard(
    String label,
    String value,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Card(
      color: isSelected ? AyannaColors.orange.withOpacity(0.8) : AyannaColors.white,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? AyannaColors.white : AyannaColors.orange,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AyannaColors.white : AyannaColors.darkGrey,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AyannaColors.white : AyannaColors.darkGrey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: AyannaColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? Colors.black87,
        ),
      ),
    );
  }
}