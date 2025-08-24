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

class _ClassElevesScreenState extends State<ClassElevesScreen> {
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
      backgroundColor: AyannaColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AyannaColors.orange,
        foregroundColor: AyannaColors.white,
        title: Text(
          'Élèves - ${widget.classe.nom}',
          style: const TextStyle(
            color: AyannaColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: AyannaColors.white),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 350,
                  child: _fraisList.isEmpty
                      ? const Text('Aucun frais trouvé')
                      : DropdownButtonFormField<int>(
                          value: _selectedFrais?.id,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Selectionner un frais',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: const BorderSide(
                                color: AyannaColors.orange,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: const BorderSide(
                                color: AyannaColors.orange,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: const BorderSide(
                                color: AyannaColors.orange,
                                width: 1.5,
                              ),
                            ),
                          ),

                          dropdownColor: AyannaColors.white,
                          iconEnabledColor: AyannaColors.orange,
                          items: _fraisList
                              .map(
                                (frais) => DropdownMenuItem<int>(
                                  value: frais.id,
                                  child: Text(
                                    '${frais.nom} (${frais.montant.toStringAsFixed(0)})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AyannaColors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
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
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 1.1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                children: [
                  _buildDashboardCard(
                    'Total',
                    '$_totalEleves',
                    Icons.people,
                    AyannaColors.white,
                  ),
                  _buildDashboardCard(
                    'En ordre',
                    '$_enOrdre',
                    Icons.check_circle,
                    AyannaColors.white,
                  ),
                  _buildDashboardCard(
                    'Pas en ordre',
                    '$_pasEnOrdre',
                    Icons.warning,
                    AyannaColors.white,
                  ),
                  _buildDashboardCard(
                    'Attendu',
                    _totalAttendu.toStringAsFixed(0),
                    Icons.attach_money,
                    AyannaColors.white,
                  ),
                  _buildDashboardCard(
                    'Reçu',
                    _totalRecu.toStringAsFixed(0),
                    Icons.payments,
                    AyannaColors.white,
                  ),
                  _buildDashboardCard(
                    'Reste',
                    (_totalAttendu - _totalRecu).toStringAsFixed(0),
                    Icons.trending_down,
                    AyannaColors.white,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _eleves.isEmpty
                    ? const Center(child: Text('Aucun élève trouvé.'))
                    : SingleChildScrollView(
                        child: Table(
                          border: TableBorder.all(
                            color: AyannaColors.lightGrey.withOpacity(0.5),
                            width: 1,
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(2),
                          },
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(
                                color: AyannaColors.orange,
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Matricule',
                                    style: TextStyle(
                                      color: AyannaColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Nom Complet',
                                    style: TextStyle(
                                      color: AyannaColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ..._eleves.map((e) {
                              return TableRow(
                                children: [
                                  InkWell(
                                    onTap: () => _navigateToEleveDetails(e),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                        horizontal: 8.0,
                                      ),
                                      child: Text(e.matricule ?? 'N/A'),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _navigateToEleveDetails(e),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                        horizontal: 8.0,
                                      ),
                                      child: Text(
                                        '${e.nom.toUpperCase()} ${e.postnom?.toUpperCase() ?? ''} ${e.prenom}',
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToEleveDetails(Eleve eleve) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ClasseEleveDetailsScreen(eleve: eleve)),
    );
  }

  Widget _buildDashboardCard(
    String label,
    String value,
    IconData icon,
    Color? color,
  ) {
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Card(
        color: color ?? AyannaColors.white,
        elevation: 1,
        shadowColor: AyannaColors.lightGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        child: Padding(
          padding:  EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: AyannaColors.orange),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AyannaColors.darkGrey,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AyannaColors.darkGrey,
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
}
