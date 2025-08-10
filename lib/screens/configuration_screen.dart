import 'package:flutter/material.dart';
import '../widgets/ayanna_appbar.dart';
import '../widgets/ayanna_widgets.dart';
import '../services/school_queries.dart';
import '../services/app_preferences.dart';
import '../models/models.dart';
import '../ayanna_theme.dart';

class ConfigurationScreen extends StatefulWidget {
  final bool isFirstSetup;
  const ConfigurationScreen({this.isFirstSetup = true, super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  List<AnneeScolaire> _annees = [];
  AnneeScolaire? _selectedYear;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final annees = await SchoolQueries.getAllAnneesScolaires();
    final currentYearId = await AppPreferences.getCurrentSchoolYearId();

    setState(() {
      _annees = annees;
      if (currentYearId != null) {
        _selectedYear = annees.where((a) => a.id == currentYearId).firstOrNull;
      } else {
        _selectedYear = annees.where((a) => a.enCours == 1).firstOrNull;
      }

      // Si aucune année trouvée ou si l'année sélectionnée n'est pas dans la liste, prendre la première
      if (_selectedYear == null && annees.isNotEmpty) {
        _selectedYear = annees.first;
      } else if (_selectedYear != null &&
          !annees.any((a) => a.id == _selectedYear!.id)) {
        _selectedYear = annees.isNotEmpty ? annees.first : null;
      }

      _loading = false;
    });
  }

  Future<void> _saveConfiguration() async {
    if (_selectedYear == null) return;

    setState(() => _saving = true);

    try {
      // Marque l'année sélectionnée comme en cours dans la base
      await SchoolQueries.setCurrentSchoolYear(_selectedYear!.id);

      // Sauvegarde dans les préférences
      await AppPreferences.setCurrentSchoolYearId(_selectedYear!.id);

      if (widget.isFirstSetup) {
        await AppPreferences.setFirstLaunchCompleted();
      }

      if (mounted) {
        // Navigation vers la page des classes
        Navigator.of(context).pushReplacementNamed('/classes');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isFirstSetup
          ? null
          : const AyannaAppBar(title: 'Configuration'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isFirstSetup) ...[
                const SizedBox(height: 40),
                const Center(child: AyannaLogo(size: 100)),
                const SizedBox(height: 40),
                Text(
                  'Configuration initiale',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bienvenue sur Ayanna School ! Veuillez sélectionner l\'année scolaire en cours pour commencer.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const SizedBox(height: 20),
                Text(
                  'Paramètres de l\'application',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
              const SizedBox(height: 40),

              // Section année scolaire
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.school, color: AyannaTheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            'Année scolaire en cours',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_loading)
                        const Center(child: CircularProgressIndicator())
                      else if (_annees.isEmpty)
                        const Center(
                          child: Text('Aucune année scolaire disponible'),
                        )
                      else
                        DropdownButtonFormField<AnneeScolaire>(
                          value: _annees.any((a) => a.id == _selectedYear?.id)
                              ? _selectedYear
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Sélectionner l\'année scolaire',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          items: _annees.map((annee) {
                            return DropdownMenuItem<AnneeScolaire>(
                              value: annee,
                              child: Text(annee.nom),
                            );
                          }).toList(),
                          onChanged: (AnneeScolaire? value) {
                            setState(() {
                              _selectedYear = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Veuillez sélectionner une année scolaire';
                            }
                            return null;
                          },
                        ),
                      if (_selectedYear != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Période: ${_selectedYear!.dateDebut} - ${_selectedYear!.dateFin}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.2),

              // Bouton de validation
              _saving
                  ? const Center(child: CircularProgressIndicator())
                  : AyannaButton(
                      text: widget.isFirstSetup ? 'Commencer' : 'Sauvegarder',
                      onPressed: _selectedYear != null
                          ? () => _saveConfiguration()
                          : null,
                    ),

              if (!widget.isFirstSetup) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AyannaTheme.primary,
                    side: BorderSide(color: AyannaTheme.primary),
                  ),
                  child: const Text('Annuler'),
                ),
              ],

              const SizedBox(height: 24), // Padding bottom
            ],
          ),
        ),
      ),
    );
  }
}
