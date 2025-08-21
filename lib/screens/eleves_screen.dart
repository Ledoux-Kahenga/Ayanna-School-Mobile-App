import 'package:flutter/material.dart';
import '../theme/ayanna_theme.dart';
import '../widgets/ayanna_appbar.dart';
import '../widgets/ayanna_widgets.dart';
import '../services/school_queries.dart';
import '../models/models.dart';
import 'eleve_details_screen.dart';

class ElevesScreen extends StatefulWidget {
  final Classe classe;
  const ElevesScreen({required this.classe, super.key});

  @override
  State<ElevesScreen> createState() => _ElevesScreenState();
}

class _ElevesScreenState extends State<ElevesScreen> {
  List<Eleve> _eleves = [];
  List<FraisScolaire> _fraisList = [];
  FraisScolaire? _selectedFrais;
  bool _loading = true;
  int _totalEleves = 0;
  int _enOrdre = 0;
  int _pasEnOrdre = 0;
  double _totalAttendu = 0;
  double _totalRecu = 0;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final eleves = await SchoolQueries.getElevesByClasse(widget.classe.id);
      final fraisList = await SchoolQueries.getAllFraisByClasse(
        widget.classe.id,
      );

      setState(() {
        _eleves = eleves;
        _fraisList = fraisList;
        _selectedFrais = fraisList.isNotEmpty ? fraisList.first : null;
        _loading = false;
      });

      if (_selectedFrais != null) {
        _updateDashboard(_selectedFrais!);
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _updateDashboard(FraisScolaire frais) async {
    final dashboardData = await SchoolQueries.getDashboardDataForFrais(
      widget.classe.id,
      frais.id,
    );

    setState(() {
      _totalEleves = dashboardData['totalEleves'];
      _enOrdre = dashboardData['enOrdre'];
      _pasEnOrdre = dashboardData['pasEnOrdre'];
      _totalAttendu = dashboardData['totalAttendu'];
      _totalRecu = dashboardData['totalRecu'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AyannaAppBar(title: 'Élèves - ${widget.classe.nom}'),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // En-tête compact avec logo et dropdown frais
            Row(
              children: [
                const AyannaLogo(size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: _fraisList.isEmpty
                      ? const Text('Aucun frais trouvé')
                      : DropdownButtonFormField<int>(
                          value: _selectedFrais?.id,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Sélectionner un frais',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _fraisList
                              .map(
                                (frais) => DropdownMenuItem<int>(
                                  value: frais.id,
                                  child: Text(
                                    '${frais.nom} (${frais.montant.toStringAsFixed(0)})',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (int? fraisId) {
                            if (fraisId != null) {
                              final selectedFrais = _fraisList.firstWhere(
                                (f) => f.id == fraisId,
                              );
                              setState(() {
                                _selectedFrais = selectedFrais;
                              });
                              _updateDashboard(selectedFrais);
                            }
                          },
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else ...[
              // Dashboard compact en grid 2x3
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 1.1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _buildDashboardCard(
                    'Total',
                    '$_totalEleves',
                    Icons.people,
                    AyannaColors.selectionBlue.withOpacity(0.1),
                  ),
                  _buildDashboardCard(
                    'En ordre',
                    '$_enOrdre',
                    Icons.check_circle,
                    AyannaColors.successGreen.withOpacity(0.1),
                  ),
                  _buildDashboardCard(
                    'Pas en ordre',
                    '$_pasEnOrdre',
                    Icons.warning,
                    Colors.red.withOpacity(0.1),
                  ),
                  _buildDashboardCard(
                    'Attendu',
                    _totalAttendu.toStringAsFixed(0),
                    Icons.attach_money,
                    AyannaColors.orange.withOpacity(0.1),
                  ),
                  _buildDashboardCard(
                    'Reçu',
                    _totalRecu.toStringAsFixed(0),
                    Icons.payments,
                    Colors.purple.withOpacity(0.1),
                  ),
                  _buildDashboardCard(
                    'Reste',
                    (_totalAttendu - _totalRecu).toStringAsFixed(0),
                    Icons.trending_down,
                    AyannaColors.lightGrey,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Liste des élèves
              Expanded(
                child: _eleves.isEmpty
                    ? const Center(child: Text('Aucun élève trouvé.'))
                    : ListView.separated(
                        itemCount: _eleves.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (context, i) {
                          final e = _eleves[i];
                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  '${e.prenom[0]}${e.nom[0]}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                '${e.prenom} ${e.nom}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: e.matricule != null
                                  ? Text(
                                      'Mat: ${e.matricule}',
                                      style: const TextStyle(fontSize: 12),
                                    )
                                  : null,
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () => _navigateToEleveDetails(e),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToEleveDetails(Eleve eleve) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EleveDetailsScreen(eleve: eleve)));
  }

  Widget _buildDashboardCard(
    String label,
    String value,
    IconData icon,
    Color? color,
  ) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
