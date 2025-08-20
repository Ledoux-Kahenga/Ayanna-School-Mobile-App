import 'package:flutter/material.dart';
import '../widgets/ayanna_appbar.dart';
import '../widgets/ayanna_drawer.dart';
import '../services/school_queries.dart';
import '../models/models.dart';
import '../ayanna_theme.dart';
import '../services/app_preferences.dart';

class EleveGlobalScreen extends StatefulWidget {
  const EleveGlobalScreen({super.key});

  @override
  State<EleveGlobalScreen> createState() => _EleveGlobalScreenState();
}

class _EleveGlobalScreenState extends State<EleveGlobalScreen> {
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
      final yearId = await AppPreferences.getCurrentSchoolYearId();
      if (yearId == null) {
        setState(() {
          _loading = false;
          _errorMessage = 'Aucune année scolaire sélectionnée.';
        });
        return;
      }
      final classes = await SchoolQueries.getClassesByAnnee(yearId);
      List<Eleve> allEleves = [];
      for (final classe in classes) {
        final eleves = await SchoolQueries.getElevesByClasse(classe.id);
        allEleves.addAll(eleves);
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
      appBar: const AyannaAppBar(title: 'Recherche Élève'),
      drawer: const AyannaDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Rechercher un élève (nom, prénom, matricule)',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
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
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 4),
                          itemBuilder: (context, i) {
                            final e = _filteredEleves[i];
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
                                onTap: () => _loadFraisForEleve(e),
                              ),
                            );
                          },
                        ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    '${_selectedEleve!.prenom} ${_selectedEleve!.nom}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AyannaTheme.primary,
                    ),
                  ),
                ),
                if (_selectedEleve!.matricule != null)
                  Text(
                    'Matricule : ${_selectedEleve!.matricule!}',
                    style: Theme.of(context).textTheme.bodyMedium,
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
                                                ? Colors.green
                                                : fd.statut ==
                                                      'partiellement_paye'
                                                ? Colors.orange
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Montant : ${fd.frais.montant.toStringAsFixed(0)}',
                                    ),
                                    Text(
                                      'Payé : ${fd.montantPaye.toStringAsFixed(0)}',
                                    ),
                                    Text(
                                      'Reste : ${fd.resteAPayer.toStringAsFixed(0)}',
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
                                    if (fd.resteAPayer > 0) ...[
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton.icon(
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
                                              // Enregistre le paiement
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
                                                    fd.resteAPayer - result <= 0
                                                    ? 'en_ordre'
                                                    : 'partiellement_paye',
                                                userId:
                                                    1, // à adapter selon l'utilisateur connecté
                                              );
                                              await SchoolQueries.insertPaiement(
                                                paiement,
                                              );
                                              // Recharge les frais
                                              await _loadFraisForEleve(
                                                _selectedEleve!,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
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
