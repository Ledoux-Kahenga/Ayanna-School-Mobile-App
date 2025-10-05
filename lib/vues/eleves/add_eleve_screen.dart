import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayanna_school/models/entities/entities.dart';
import 'package:ayanna_school/services/providers/providers.dart';
import '../../theme/ayanna_theme.dart';

class AddEleveScreen extends ConsumerStatefulWidget {
  final int? classeId;
  const AddEleveScreen({super.key, this.classeId});

  @override
  ConsumerState<AddEleveScreen> createState() => _AddEleveScreenState();
}

class _AddEleveScreenState extends ConsumerState<AddEleveScreen> {
  final _formKey = GlobalKey<FormState>();
  String nom = '';
  String postnom = '';
  String prenom = '';
  String? sexe;
  String? dateNaissance;
  String? lieuNaissance;
  String? numeroPermanent;
  int? classeId;
  String? classe;
  List<Classe> classesDisponibles = [];
  int? responsableId;
  String? matricule;
  String statut = 'actif';
  // Champs responsable
  String responsableNom = '';
  String responsableTelephone = '';
  String responsableEmail = '';
  String responsableAdresse = '';

  @override
  void initState() {
    super.initState();
    classeId = widget.classeId;
    _chargerClasses();
  }

  Future<void> _chargerClasses() async {
    try {
      final anneeScolaire = await ref.read(currentAnneeScolaireProvider.future);
      if (anneeScolaire != null) {
        final allClasses = await ref.read(classesNotifierProvider.future);
        final classes = allClasses
            .where((classe) => classe.anneeScolaireId == anneeScolaire.id)
            .toList();
        setState(() {
          classesDisponibles = classes;
        });
      }
    } catch (e) {
      print('Erreur chargement classes: $e');
    }
  }

  // Méthode pour formater le prénom (première lettre majuscule, reste en minuscule)
  String _formatPrenom(String prenom) {
    if (prenom.isEmpty) return prenom;
    return prenom[0].toUpperCase() + prenom.substring(1).toLowerCase();
  }

  Future<void> _saveEleve() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        int? finalResponsableId = responsableId;
        if (responsableNom.trim().isNotEmpty) {
          final now = DateTime.now();
          final nouveauResponsable = Responsable(
            id: null,
            serverId: null,
            isSync: false,
            nom: responsableNom.trim(),
            telephone: responsableTelephone.trim().isNotEmpty
                ? responsableTelephone.trim()
                : null,
            adresse: responsableAdresse.trim().isNotEmpty
                ? responsableAdresse.trim()
                : null,
            code: null,
            dateCreation: now,
            dateModification: now,
            updatedAt: now,
          );

          await ref
              .read(responsablesNotifierProvider.notifier)
              .addResponsable(nouveauResponsable);

          final allResponsables = await ref.read(
            responsablesNotifierProvider.future,
          );
          final createdResponsable = allResponsables.lastWhere(
            (r) => r.nom == responsableNom.trim(),
          );
          finalResponsableId = createdResponsable.id;
        }

        final now = DateTime.now();
        final nouvelEleve = Eleve(
          id: null,
          serverId: null,
          isSync: false,
          nom: nom.trim().toUpperCase(),
          prenom: _formatPrenom(prenom.trim()),
          postnom: postnom.trim().isNotEmpty
              ? postnom.trim().toUpperCase()
              : null,
          sexe: sexe,
          dateNaissance: dateNaissance != null
              ? DateTime.tryParse(dateNaissance!)
              : null,
          lieuNaissance: lieuNaissance,
          numeroPermanent: numeroPermanent,
          classeId: classeId,
          responsableId: finalResponsableId,
          matricule: matricule,
          statut: statut,
          dateCreation: now,
          dateModification: now,
          updatedAt: now,
        );

        await ref.read(elevesNotifierProvider.notifier).addEleve(nouvelEleve);

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        print('Erreur creation eleve: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }

  // Styles de bordure réutilisables pour les champs de formulaire
  final InputDecoration _formFieldDecoration = InputDecoration(
    border: const OutlineInputBorder(
      borderSide: BorderSide(color: AyannaColors.orange, width: 0.5),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: AyannaColors.orange, width: 0.5),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: AyannaColors.orange, width: 1.0),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un élève'),
        backgroundColor: AyannaColors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // SECTION 1 : INFORMATION PERSONNELLE
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INFORMATION PERSONNELLE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AyannaColors.orange,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: _formFieldDecoration.copyWith(
                            labelText: 'Nom',
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Nom requis' : null,
                          onSaved: (v) => nom = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: _formFieldDecoration.copyWith(
                            labelText: 'Post-nom',
                          ),
                          onSaved: (v) => postnom = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: _formFieldDecoration.copyWith(
                            labelText: 'Prénom',
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Prénom requis' : null,
                          onSaved: (v) => prenom = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: _formFieldDecoration.copyWith(
                            labelText: 'Sexe',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'M',
                              child: Text('Masculin'),
                            ),
                            DropdownMenuItem(
                              value: 'F',
                              child: Text('Féminin'),
                            ),
                          ],
                          onChanged: (v) => setState(() => sexe = v),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: _formFieldDecoration.copyWith(
                            labelText: 'Date de naissance',
                          ),
                          onSaved: (v) => dateNaissance = v,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: _formFieldDecoration.copyWith(
                            labelText: 'Lieu de naissance',
                          ),
                          onSaved: (v) => lieuNaissance = v,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: _formFieldDecoration.copyWith(
                            labelText: 'Numéro permanent',
                          ),
                          onSaved: (v) => numeroPermanent = v,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                // SECTION 2 : INFORMATION SCOLAIRES
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INFORMATION SCOLAIRES',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AyannaColors.orange,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          decoration: _formFieldDecoration.copyWith(
                            labelText: 'Classe',
                          ),
                          value: classeId,
                          items: classesDisponibles
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.nom),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => classeId = v),
                          validator: (v) => v == null ? 'Classe requise' : null,
                          onSaved: (v) => classeId = v,
                        ),
                      ],
                    ),
                  ),
                ),
                // SECTION 3 : CONTACT RESPONSABLE
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CONTACT RESPONSABLE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AyannaColors.orange,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: _formFieldDecoration.copyWith(
                            labelText: 'Nom du responsable',
                          ),
                          onSaved: (v) => responsableNom = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: _formFieldDecoration.copyWith(
                            labelText: 'Téléphone parent',
                          ),
                          onSaved: (v) => responsableTelephone = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: _formFieldDecoration.copyWith(
                            labelText: 'Email',
                          ),
                          onSaved: (v) => responsableEmail = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: _formFieldDecoration.copyWith(
                            labelText: 'Adresse',
                          ),
                          onSaved: (v) => responsableAdresse = v ?? '',
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AyannaColors.orange,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _saveEleve,
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(color: AyannaColors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
