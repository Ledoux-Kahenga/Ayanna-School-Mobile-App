// Fichier : lib/vues/depense_sortie.dart

import 'package:ayanna_school/models/models.dart';
import 'package:ayanna_school/services/app_preferences.dart';
import 'package:ayanna_school/services/school_queries.dart';
import 'package:ayanna_school/theme/ayanna_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DepenseSortiePage extends StatefulWidget {
  const DepenseSortiePage({super.key});

  @override
  State<DepenseSortiePage> createState() => _DepenseSortiePageState();
}

class _DepenseSortiePageState extends State<DepenseSortiePage> {
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

   Future<void> _fetchSoldeCaisse() async {
    try {
      final solde = await SchoolQueries.getSoldeCaisse();
      if (mounted) {
        setState(() {
          _soldeCaisse = solde;
          _soldeLoading = false;
        });
      }
    } catch (e) {
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
    
    // 2. Refresh the cash balance before the transaction
    await _fetchSoldeCaisse();

    // 3. Check if the cash balance is sufficient
    if (_soldeCaisse < montantDepense) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le montant de la dépense est supérieur au solde de la caisse.'),
          backgroundColor: Colors.orange,
        ),
      );
      return; // Stop the execution here if the balance is insufficient
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await SchoolQueries.insertSortieCaisse(
        entrepriseId: 2, // Remplacez par l'ID de votre entreprise
        montant: montantDepense,
        libelle: _libelleController.text,
        compteDestinationId: int.parse(compteSelectionne!),
        pieceJustification: _pieceJustificationController.text.isNotEmpty
            ? _pieceJustificationController.text
            : null,
        observation: _observationController.text.isNotEmpty
            ? _observationController.text
            : null,
        userId: 2, // Remplacez par l'ID de l'utilisateur connecté
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dépense enregistrée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
  @override
  Widget build(BuildContext context) {
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
              FutureBuilder<List<CompteComptable>>(
                future: SchoolQueries.getComptesComptables(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text("Erreur de chargement: ${snapshot.error}");
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Aucun compte de charge disponible.");
                  }
                  final comptes = snapshot.data!;
                  // ADD a 'return' statement here
                  return DropdownButtonFormField<String>(
                    // Ajoutez la propriété 'value' ici
                    value: compteSelectionne,
                    decoration: const InputDecoration(
                      labelText: 'Compte de destination (Charge)',
                    ),
                    isExpanded: true,
                    items: comptes.map((compte) {
                      return DropdownMenuItem<String>(
                        value: compte.id.toString(),
                        child: Text(
                          '${compte.numero} - ${compte.libelle}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      // Utilisez setState pour mettre à jour l'état
                      setState(() {
                        compteSelectionne = value;
                      });
                    },
                    validator: (value) => value == null
                        ? 'Veuillez sélectionner un compte'
                        : null,
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
                decoration: const InputDecoration(labelText: 'Montant'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Veuillez entrer le montant';
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Le montant doit être positif';
                  }
                  return null;
                },
              ),
                Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _soldeLoading
                    ? const Center(child: Text("Chargement du solde..."))
                    : Text(
                        'Disponible en caisse : ${NumberFormat("#,##0", "fr_FR").format(_soldeCaisse)} ${AppPreferences().devise}',
                        style: TextStyle(
                          color: _soldeCaisse > 0 ? Colors.green.shade800 : Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
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
