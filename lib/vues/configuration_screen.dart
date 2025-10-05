import 'package:ayanna_school/vues/widgets/ayanna_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/ayanna_theme.dart';
import '../models/entities/annee_scolaire.dart';
import '../services/providers/providers.dart';

class ConfigurationScreen extends ConsumerStatefulWidget {
  final bool isFirstSetup;
  const ConfigurationScreen({this.isFirstSetup = true, super.key});

  @override
  ConsumerState<ConfigurationScreen> createState() =>
      _ConfigurationScreenState();
}

class _ConfigurationScreenState extends ConsumerState<ConfigurationScreen> {
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
    setState(() {
      _loading = true;
    });
    try {
      final annees = await ref.read(anneesScolairesNotifierProvider.future);
      final currentYear = await ref.read(currentAnneeScolaireProvider.future);

      setState(() {
        _annees = annees;
        if (currentYear != null) {
          _selectedYear = currentYear;
        } else if (_annees.isNotEmpty) {
          _selectedYear = _annees.first;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur chargement des données: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveConfiguration() async {
    if (_selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une année scolaire.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });
    try {
      await ref
          .read(configEcolesNotifierProvider.notifier)
          .updateCurrentAnneeScolaire(_selectedYear!.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration sauvegardée avec succès.'),
            backgroundColor: Colors.green,
          ),
        );
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
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int drawerIndex = 4;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
        backgroundColor: AyannaColors.orange,
        foregroundColor: AyannaColors.white,
      ),
      drawer: AyannaDrawer(
        selectedIndex: drawerIndex,
        onItemSelected: (i) => setState(() => drawerIndex = i),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuration de l\'année scolaire',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(height: 24),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<AnneeScolaire>(
                            value: _selectedYear,
                            decoration: const InputDecoration(
                              labelText: 'Année scolaire en cours',
                              border: OutlineInputBorder(),
                            ),
                            items: _annees.map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year.nom),
                              );
                            }).toList(),
                            onChanged: (value) {
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
                              'Période: ${_selectedYear!.dateDebut.toString().substring(0, 10)} - ${_selectedYear!.dateFin.toString().substring(0, 10)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Sauvegarder'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AyannaColors.orange,
                        foregroundColor: AyannaColors.white,
                      ),
                      onPressed: _saving ? null : _saveConfiguration,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
