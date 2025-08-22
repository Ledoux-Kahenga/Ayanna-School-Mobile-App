import 'package:flutter/material.dart';
import '../../theme/ayanna_theme.dart';
import '../widgets/ayanna_appbar.dart';
import '../widgets/ayanna_widgets.dart';
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
                            labelText: 'Sélectionner un frais',
                            labelStyle: const TextStyle(
                              color: AyannaColors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AyannaColors.orange,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AyannaColors.orange,
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
                            isDense: true,
                            filled: true,
                            fillColor: AyannaColors.white,
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
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
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
                    : ListView.separated(
                        itemCount: _eleves.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (context, i) {
                          final e = _eleves[i];
                          return Card(
                            margin: EdgeInsets.zero,
                            color: AyannaColors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                                '${e.nom.toUpperCase()} ${e.prenom}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AyannaColors.darkGrey,
                                ),
                              ),
                              subtitle: e.matricule != null
                                  ? Text(
                                      'Mat: ${e.matricule}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF666666),
                                      ),
                                    )
                                  : null,
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AyannaColors.orange,
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
    return Card(
      color: color ?? AyannaColors.white,
      elevation: 2,
      shadowColor: AyannaColors.lightGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
    );
  }
}
