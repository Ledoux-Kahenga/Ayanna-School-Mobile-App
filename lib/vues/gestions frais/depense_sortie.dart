// Fichier : lib/vues/depense_sortie.dart

import 'package:ayanna_school/services/app_preferences.dart';
import 'package:ayanna_school/services/providers/providers.dart';
import 'package:ayanna_school/theme/ayanna_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DepenseSortiePage extends ConsumerStatefulWidget {
  const DepenseSortiePage({super.key});

  @override
  ConsumerState<DepenseSortiePage> createState() => _DepenseSortiePageState();
}

class _DepenseSortiePageState extends ConsumerState<DepenseSortiePage> {
  final _formKey = GlobalKey<FormState>();
  String? compteSelectionne;
  final TextEditingController _libelleController = TextEditingController();
  final TextEditingController _pieceJustificationController =
      TextEditingController();
  final TextEditingController _observationController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  bool _isLoading = false;

  double _soldeCaisse = 0.0;
  bool _soldeLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSoldeCaisse(); // Charger le solde au démarrage
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Rafraîchir le solde à chaque fois que la page devient visible
    _fetchSoldeCaisse();
  }

  Future<void> _fetchSoldeCaisse() async {
    print('🔄 Début _fetchSoldeCaisse...');
    try {
      final solde = await ref
          .read(journauxComptablesNotifierProvider.notifier)
          .getSoldeCaisse();
      print('✅ Solde récupéré: $solde');
      if (mounted) {
        setState(() {
          _soldeCaisse = solde;
          _soldeLoading = false;
        });
        print('✅ État mis à jour avec solde: $_soldeCaisse');
      }
    } catch (e) {
      print('❌ Erreur _fetchSoldeCaisse: $e');
      if (mounted) {
        setState(() {
          _soldeLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement du solde: $e')),
        );
      }
    }
  }

  Future<void> _enregistrerDepense() async {
    if (_formKey.currentState!.validate()) {
      // 1. Get the amount to be spent
      final double montantDepense = double.parse(_montantController.text);

      // 2. Afficher un loader pendant la vérification
      setState(() {
        _isLoading = true;
      });

      try {
        // 3. Refresh the cash balance before the transaction
        print('🔍 Vérification du solde avant dépense...');
        final soldeActuel = await ref
            .read(journauxComptablesNotifierProvider.notifier)
            .getSoldeCaisse();

        print('💰 Solde caisse actuel: $soldeActuel');
        print('💸 Montant de la dépense: $montantDepense');

        // 4. Check if the cash balance is sufficient
        if (soldeActuel < montantDepense) {
          final manquant = montantDepense - soldeActuel;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Solde insuffisant en caisse !\n'
                  'Disponible : ${NumberFormat("#,##0", "fr_FR").format(soldeActuel)} ${AppPreferences().devise}\n'
                  'Demandé : ${NumberFormat("#,##0", "fr_FR").format(montantDepense)} ${AppPreferences().devise}\n'
                  'Manquant : ${NumberFormat("#,##0", "fr_FR").format(manquant)} ${AppPreferences().devise}',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
            setState(() {
              _isLoading = false;
            });
          }
          return; // Stop the execution here if the balance is insufficient
        }

        print('✅ Solde suffisant, enregistrement de la dépense...');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur vérification solde: $e'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // 5. Proceed with the expense registration

      try {
        final authState = await ref.read(authNotifierProvider.future);

        await ref
            .read(journauxComptablesNotifierProvider.notifier)
            .insertSortieCaisse(
              entrepriseId: authState.entrepriseId ?? 2,
              montant: montantDepense,
              libelle: _libelleController.text,
              compteDestinationId: int.parse(compteSelectionne!),
              pieceJustification: _pieceJustificationController.text.isNotEmpty
                  ? _pieceJustificationController.text
                  : null,
              observation: _observationController.text.isNotEmpty
                  ? _observationController.text
                  : null,
              userId: authState.userId ?? 2,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dépense enregistrée avec succès'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer la devise depuis la table entreprise si disponible
    String devise = AppPreferences().devise;
    try {
      final entreprisesAsync = ref.watch(entreprisesNotifierProvider);
      if (entreprisesAsync.hasValue) {
        final list = entreprisesAsync.value!;
        if (list.isNotEmpty) devise = list.first.devise ?? devise;
      }
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle sortie de caisse'),
        backgroundColor: AyannaColors.orange,
        foregroundColor: AyannaColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Dropdown pour le compte de destination
              Consumer(
                builder: (context, ref, child) {
                  final comptesAsync = ref.watch(
                    comptesComptablesNotifierProvider,
                  );

                  return comptesAsync.when(
                    data: (comptes) {
                      // Filtrer uniquement les comptes de charges (classe 6)
                      final comptesCharges = comptes.where((compte) {
                        return compte.numero.startsWith('6');
                      }).toList();

                      if (comptesCharges.isEmpty) {
                        return const Text(
                          "Aucun compte de charge (classe 6) disponible.",
                        );
                      }

                      return DropdownButtonFormField<String>(
                        value: compteSelectionne,
                        decoration: const InputDecoration(
                          labelText:
                              'Compte de destination (Charge - Classe 6)',
                        ),
                        isExpanded: true,
                        items: comptesCharges.map((compte) {
                          return DropdownMenuItem<String>(
                            value: compte.id.toString(),
                            child: Text(
                              '${compte.numero} - ${compte.libelle}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            compteSelectionne = value;
                          });
                        },
                        validator: (value) => value == null
                            ? 'Veuillez sélectionner un compte de charge'
                            : null,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text("Erreur de chargement: $error"),
                  );
                },
              ),

              const SizedBox(height: 16),
              // Champ pour le libellé de la dépense
              TextFormField(
                controller: _libelleController,
                decoration: const InputDecoration(
                  labelText: 'Libellé de la dépense',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer un libellé' : null,
              ),
              const SizedBox(height: 16),
              // Champ pour le montant
              TextFormField(
                controller: _montantController,
                decoration: InputDecoration(
                  labelText: 'Montant',
                  suffixText: devise,
                  helperText: 'Montant de la dépense à effectuer',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Rafraîchir l'affichage pour montrer l'avertissement si nécessaire
                  setState(() {});
                },
                validator: (value) {
                  if (value!.isEmpty) return 'Veuillez entrer le montant';
                  final montant = double.tryParse(value);
                  if (montant == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  if (montant <= 0) {
                    return 'Le montant doit être positif';
                  }
                  // Validation supplémentaire : vérifier le solde
                  if (!_soldeLoading && montant > _soldeCaisse) {
                    return 'Solde insuffisant (disponible: ${NumberFormat("#,##0", "fr_FR").format(_soldeCaisse)})';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _soldeLoading
                    ? const Center(child: Text("Chargement du solde..."))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Disponible en caisse : ${NumberFormat("#,##0", "fr_FR").format(_soldeCaisse)} $devise',
                            style: TextStyle(
                              color: _soldeCaisse > 0
                                  ? Colors.green.shade800
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          // Afficher un avertissement si le montant saisi dépasse le solde
                          if (_montantController.text.isNotEmpty &&
                              double.tryParse(_montantController.text) !=
                                  null &&
                              double.parse(_montantController.text) >
                                  _soldeCaisse)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Montant supérieur au solde disponible !',
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              // Champ pour la pièce de justification
              TextFormField(
                controller: _pieceJustificationController,
                decoration: const InputDecoration(
                  labelText: 'Pièce de justification (référence)',
                ),
              ),
              const SizedBox(height: 16),
              // Champ pour l'observation
              TextFormField(
                controller: _observationController,
                decoration: const InputDecoration(labelText: 'Observation'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _enregistrerDepense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AyannaColors.orange,
                        foregroundColor: AyannaColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Enregistrer la dépense'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
