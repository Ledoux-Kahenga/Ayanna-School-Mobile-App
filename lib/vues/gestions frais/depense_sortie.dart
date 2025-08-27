// Fichier : lib/vues/depense_sortie.dart

import 'package:ayanna_school/models/models.dart';
import 'package:ayanna_school/services/school_queries.dart';
import 'package:ayanna_school/theme/ayanna_theme.dart';
import 'package:flutter/material.dart';

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

  Future<void> _enregistrerDepense() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await SchoolQueries.insertSortieCaisse(
          entrepriseId: 2, // Remplacez par l'ID de votre entreprise
          montant: double.parse(_montantController.text),
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
        // Ferme la page et renvoie 'true' pour indiquer le succès
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
