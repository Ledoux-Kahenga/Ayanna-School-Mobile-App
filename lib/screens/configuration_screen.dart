import 'package:flutter/material.dart';
import '../theme/ayanna_theme.dart';
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
  String _selectedCurrency = 'CDF';
  final TextEditingController _exchangeRateController = TextEditingController();
  bool _currencyLoading = true;
  List<AnneeScolaire> _annees = [];
  AnneeScolaire? _selectedYear;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCurrencyConfig();
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

  // Load currency and exchange rate from preferences
  Future<void> _loadCurrencyConfig() async {
    final currency = await getAppCurrency();
    final rate = getExchangeRate();
    setState(() {
      _selectedCurrency = currency;
      _exchangeRateController.text = rate.toString();
      _currencyLoading = false;
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

      // Save currency config
      await setAppCurrency(_selectedCurrency);
      final rate = double.tryParse(_exchangeRateController.text);
      if (rate != null && rate > 0) {
        await setExchangeRate(rate);
      }

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
          : AppBar(
              title: const Text('Configuration'),
              backgroundColor: AyannaColors.orange,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _saving ? null : _saveConfiguration,
              ),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section année scolaire
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.school, color: AyannaColors.orange),
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
                      else ...[
                        DropdownButtonFormField<AnneeScolaire>(
                          value: _annees.any((a) => a.id == _selectedYear?.id)
                              ? _selectedYear
                              : null,
                          decoration: const InputDecoration(
                            labelText: "Sélectionner l'année scolaire",
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
                    ],
                  ),
                ),
              ),

              // Section configuration monnaie
              Card(
                margin: const EdgeInsets.only(top: 24),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: AyannaColors.orange),
                          const SizedBox(width: 12),
                          Text(
                            'Configuration de la monnaie',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Franc Congolais (CDF)'),
                              value: 'CDF',
                              groupValue: _selectedCurrency,
                              onChanged: (val) {
                                setState(() => _selectedCurrency = val!);
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Dollar américain (USD)'),
                              value: 'USD',
                              groupValue: _selectedCurrency,
                              onChanged: (val) {
                                setState(() => _selectedCurrency = val!);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _exchangeRateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Taux de change (1 USD = ... CDF)',
                          prefixIcon: Icon(Icons.swap_horiz),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton Sauvegarder
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Sauvegarder'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AyannaColors.orange,
                  ),
                  onPressed: _saving ? null : _saveConfiguration,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
