import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/entities/eleve.dart';
import '../../models/entities/frais_scolaire.dart';
import '../../models/entities/entreprise.dart';
import '../../services/providers/providers.dart';
import '../../theme/ayanna_theme.dart';

/// Page de test pour démontrer l'insertion de paiements avec écritures comptables automatiques
class TestPaiementEcrituresPage extends ConsumerStatefulWidget {
  const TestPaiementEcrituresPage({super.key});

  @override
  ConsumerState<TestPaiementEcrituresPage> createState() =>
      _TestPaiementEcrituresPageState();
}

class _TestPaiementEcrituresPageState
    extends ConsumerState<TestPaiementEcrituresPage> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();

  Eleve? _selectedEleve;
  FraisScolaire? _selectedFrais;
  Entreprise? _selectedEntreprise;
  bool _isLoading = false;

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _validateDatabase() async {
    try {
      print('🔍 Validation complète de la base de données:');

      // Vérifier les élèves
      final eleveDao = ref.read(eleveDaoProvider);
      final eleves = await eleveDao.getAllEleves();
      print('  - Nombre d\'élèves: ${eleves.length}');
      if (eleves.isNotEmpty) {
        print(
          '  - Premier élève: ${eleves.first.nom} (ID: ${eleves.first.id})',
        );
      }

      // Vérifier les frais
      final fraisDao = ref.read(fraisScolaireDaoProvider);
      final frais = await fraisDao.getAllFraisScolaires();
      print('  - Nombre de frais: ${frais.length}');
      if (frais.isNotEmpty) {
        print('  - Premier frais: ${frais.first.nom} (ID: ${frais.first.id})');
      }

      // Vérifier les utilisateurs
      final userDao = ref.read(utilisateurDaoProvider);
      final users = await userDao.getAllUtilisateurs();
      print('  - Nombre d\'utilisateurs: ${users.length}');
      if (users.isNotEmpty) {
        print(
          '  - Premier utilisateur: ${users.first.nom} (ID: ${users.first.id})',
        );
      }

      // Vérifier les entreprises
      final entrepriseDao = ref.read(entrepriseDaoProvider);
      final entreprises = await entrepriseDao.getAllEntreprises();
      print('  - Nombre d\'entreprises: ${entreprises.length}');
      if (entreprises.isNotEmpty) {
        print(
          '  - Première entreprise: ${entreprises.first.nom} (ID: ${entreprises.first.id})',
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la validation: $e');
    }
  }

  Future<void> _enregistrerPaiementComplet() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEleve == null ||
        _selectedFrais == null ||
        _selectedEntreprise == null) {
      _showErrorDialog('Veuillez sélectionner tous les champs requis.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final montant = double.parse(_montantController.text);

      // Vérifications des contraintes avant insertion
      print('🔍 Vérification des données:');
      print('  - Élève ID: ${_selectedEleve!.id}');
      print('  - Frais ID: ${_selectedFrais!.id}');
      print('  - Entreprise ID: ${_selectedEntreprise!.id}');
      print('  - Montant: $montant');

      // Vérifier que l'élève existe
      final eleveDao = ref.read(eleveDaoProvider);
      final eleveExiste = await eleveDao.getEleveById(_selectedEleve!.id!);
      if (eleveExiste == null) {
        throw Exception(
          'L\'élève sélectionné n\'existe pas dans la base de données',
        );
      }

      // Vérifier que le frais existe
      final fraisDao = ref.read(fraisScolaireDaoProvider);
      final fraisExiste = await fraisDao.getFraisScolaireById(
        _selectedFrais!.id!,
      );
      if (fraisExiste == null) {
        throw Exception(
          'Le frais sélectionné n\'existe pas dans la base de données',
        );
      }

      // Vérifier qu'un utilisateur existe
      final userDao = ref.read(utilisateurDaoProvider);
      final users = await userDao.getAllUtilisateurs();
      if (users.isEmpty) {
        throw Exception('Aucun utilisateur n\'existe dans la base de données');
      }
      final userId = users.first.id!;
      print('  - Utilisateur ID: $userId');

      print('✅ Toutes les vérifications sont OK, enregistrement en cours...');

      // Utiliser la nouvelle méthode avec écritures comptables
      await ref
          .read(paiementsFraisNotifierProvider.notifier)
          .enregistrerPaiementAvecEcritures(
            eleveId: _selectedEleve!.id!,
            fraisId: _selectedFrais!.id!,
            montant: montant,
            entrepriseId: _selectedEntreprise!.id!,
            userId: userId,
          );

      _showSuccessDialog(
        'Paiement enregistré avec succès!\n\n'
        'Élève: ${_selectedEleve!.nom} ${_selectedEleve!.prenom}\n'
        'Frais: ${_selectedFrais!.nom}\n'
        'Montant: ${NumberFormat.currency(locale: 'fr_FR', symbol: 'CDF').format(montant)}\n\n'
        'Les écritures comptables ont été automatiquement créées.',
      );

      _resetForm();
    } catch (e) {
      print('❌ Erreur lors de l\'enregistrement du paiement complet: $e');

      String errorMessage = 'Erreur lors de l\'enregistrement: ';
      if (e.toString().contains('FOREIGN KEY constraint failed')) {
        errorMessage +=
            'Les données sélectionnées sont invalides. '
            'Vérifiez que l\'élève et le frais existent dans la base de données.';
      } else if (e.toString().contains('n\'existe pas')) {
        errorMessage += e.toString();
      } else {
        errorMessage += e.toString();
      }

      _showErrorDialog(errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _montantController.clear();
    setState(() {
      _selectedEleve = null;
      _selectedFrais = null;
      _selectedEntreprise = null;
    });
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Succès'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Erreur'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final elevesAsync = ref.watch(elevesNotifierProvider);
    final fraisAsync = ref.watch(fraisScolairesNotifierProvider);
    final entreprisesAsync = ref.watch(entreprisesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Paiement avec Écritures'),
        backgroundColor: AyannaColors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: AyannaColors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Cette page permet de tester l\'insertion d\'un paiement avec création automatique des écritures comptables dans les tables journaux_comptables et ecritures_comptables.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sélection de l'entreprise
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Entreprise/École',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      entreprisesAsync.when(
                        data: (entreprises) =>
                            DropdownButtonFormField<Entreprise>(
                              value: _selectedEntreprise,
                              decoration: const InputDecoration(
                                hintText: 'Sélectionner une entreprise',
                                border: OutlineInputBorder(),
                              ),
                              items: entreprises.map((entreprise) {
                                return DropdownMenuItem(
                                  value: entreprise,
                                  child: Text(entreprise.nom),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedEntreprise = value);
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Veuillez sélectionner une entreprise';
                                }
                                return null;
                              },
                            ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Text('Erreur: $error'),
                      ),
                    ],
                  ),
                ),
              ),

              // Sélection de l'élève
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Élève',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      elevesAsync.when(
                        data: (eleves) => DropdownButtonFormField<Eleve>(
                          value: _selectedEleve,
                          decoration: const InputDecoration(
                            hintText: 'Sélectionner un élève',
                            border: OutlineInputBorder(),
                          ),
                          items: eleves.map((eleve) {
                            return DropdownMenuItem(
                              value: eleve,
                              child: Text('${eleve.nom} ${eleve.prenom}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedEleve = value);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Veuillez sélectionner un élève';
                            }
                            return null;
                          },
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Text('Erreur: $error'),
                      ),
                    ],
                  ),
                ),
              ),

              // Sélection du frais
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Frais scolaire',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      fraisAsync.when(
                        data: (frais) => DropdownButtonFormField<FraisScolaire>(
                          value: _selectedFrais,
                          decoration: const InputDecoration(
                            hintText: 'Sélectionner un frais',
                            border: OutlineInputBorder(),
                          ),
                          items: frais.map((f) {
                            return DropdownMenuItem(
                              value: f,
                              child: Text(
                                '${f.nom} - ${NumberFormat.currency(locale: 'fr_FR', symbol: 'CDF').format(f.montant)}',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedFrais = value);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Veuillez sélectionner un frais';
                            }
                            return null;
                          },
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Text('Erreur: $error'),
                      ),
                    ],
                  ),
                ),
              ),

              // Montant du paiement
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Montant du paiement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _montantController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Entrer le montant',
                          border: OutlineInputBorder(),
                          suffixText: 'CDF',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un montant';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Veuillez entrer un montant valide';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Le montant doit être supérieur à 0';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bouton d'enregistrement
              ElevatedButton(
                onPressed: _isLoading ? null : _enregistrerPaiementComplet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AyannaColors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Enregistrement en cours...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 8),
                          Text(
                            'Enregistrer Paiement + Écritures',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              // Bouton de validation de la base de données
              OutlinedButton(
                onPressed: _isLoading ? null : _validateDatabase,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bug_report, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Valider Base de Données (Debug)',
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Bouton de réinitialisation
              OutlinedButton(
                onPressed: _isLoading ? null : _resetForm,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AyannaColors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Réinitialiser',
                  style: TextStyle(color: AyannaColors.orange, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
