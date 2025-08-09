import 'package:flutter/material.dart';
import '../widgets/ayanna_appbar.dart';
import '../widgets/ayanna_widgets.dart';
import '../widgets/dashboard_card.dart';
import '../services/school_queries.dart';
import '../models/models.dart';

class ElevesScreen extends StatefulWidget {
  final Classe classe;
  const ElevesScreen({required this.classe, super.key});

  @override
  State<ElevesScreen> createState() => _ElevesScreenState();
}

class _ElevesScreenState extends State<ElevesScreen> {
  List<Eleve> _eleves = [];
  bool _loading = true;
  int _totalEleves = 0;
  int _enOrdre = 0;
  int _pasEnOrdre = 0;
  double _totalAttendu = 0;
  double _totalRecu = 0;
  String _fraisNom = '';

  @override
  void initState() {
    super.initState();
    _fetchDashboardAndEleves();
  }

  Future<void> _fetchDashboardAndEleves() async {
    final eleves = await SchoolQueries.getElevesByClasse(widget.classe.id);
    final dashboardData = await SchoolQueries.getDashboardDataForClasse(
      widget.classe.id,
    );

    setState(() {
      _eleves = eleves;
      _totalEleves = dashboardData['totalEleves'];
      _enOrdre = dashboardData['enOrdre'];
      _pasEnOrdre = dashboardData['pasEnOrdre'];
      _totalAttendu = dashboardData['totalAttendu'];
      _totalRecu = dashboardData['totalRecu'];
      _fraisNom = dashboardData['fraisNom'];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AyannaAppBar(title: 'Élèves - ${widget.classe.nom}'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AyannaLogo(size: 60),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  DashboardCard(
                    label: 'Total élèves',
                    value: '$_totalEleves',
                    icon: Icons.people,
                  ),
                  DashboardCard(
                    label: 'En ordre',
                    value: '$_enOrdre',
                    icon: Icons.check_circle,
                    color: Colors.green[100],
                  ),
                  DashboardCard(
                    label: 'Pas en ordre',
                    value: '$_pasEnOrdre',
                    icon: Icons.warning,
                    color: Colors.red[100],
                  ),
                  if (_fraisNom.isNotEmpty)
                    DashboardCard(
                      label: 'Total attendu ($_fraisNom)',
                      value: _totalAttendu.toStringAsFixed(2),
                      icon: Icons.attach_money,
                    ),
                  if (_fraisNom.isNotEmpty)
                    DashboardCard(
                      label: 'Total reçu ($_fraisNom)',
                      value: _totalRecu.toStringAsFixed(2),
                      icon: Icons.payments,
                      color: Colors.blue[100],
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Liste des élèves',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (_eleves.isEmpty)
                const Center(child: Text('Aucun élève trouvé.'))
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _eleves.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      final e = _eleves[i];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(
                          '${e.prenom} ${e.nom}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        subtitle: e.matricule != null
                            ? Text('Matricule : ${e.matricule}')
                            : null,
                        onTap: () {
                          // TODO: Naviguer vers la fiche élève ou gestion des paiements
                        },
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
}
