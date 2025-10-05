import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayanna_school/models/entities/entities.dart';
import 'package:ayanna_school/services/providers/providers.dart';
import '../../theme/ayanna_theme.dart';

class EditEleveScreen extends ConsumerStatefulWidget {
  final Eleve eleve;
  const EditEleveScreen({super.key, required this.eleve});

  @override
  ConsumerState<EditEleveScreen> createState() => _EditEleveScreenState();
}

class _EditEleveScreenState extends ConsumerState<EditEleveScreen> {
  final _formKey = GlobalKey<FormState>();

  // Élève
  late String nom;
  late String prenom;
  late String postnom;
  String? sexe;
  String? dateNaissance;
  String? lieuNaissance;
  String? numeroPermanent;
  int? classeId;
  String statut = 'actif';

  // Responsable
  Responsable? responsable;
  late String responsableNom;
  late String responsableTelephone;
  late String responsableAdresse;

  List<Classe> classesDisponibles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);

    try {
      final eleve = widget.eleve;
      nom = eleve.nom;
      prenom = eleve.prenom;
      postnom = eleve.postnom ?? '';
      sexe = eleve.sexe;
      if (sexe == 'Masculin') {
        sexe = 'M';
      } else if (sexe == 'Féminin') {
        sexe = 'F';
      }
      dateNaissance = eleve.dateNaissance?.toIso8601String().split('T')[0];
      lieuNaissance = eleve.lieuNaissance;
      numeroPermanent = eleve.numeroPermanent;
      classeId = eleve.classeId;
      statut = eleve.statut ?? 'actif';

      // Charger le responsable
      if (eleve.responsableId != null) {
        final allResponsables = await ref.read(
          responsablesNotifierProvider.future,
        );
        responsable = allResponsables.firstWhere(
          (r) => r.id == eleve.responsableId,
          orElse: () => Responsable(
            id: null,
            serverId: null,
            isSync: false,
            nom: null,
            code: null,
            telephone: null,
            adresse: null,
            dateCreation: DateTime.now(),
            dateModification: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
      responsableNom = responsable?.nom ?? '';
      responsableTelephone = responsable?.telephone ?? '';
      responsableAdresse = responsable?.adresse ?? '';

      // Charger les classes de l'année scolaire en cours
      final annee = await ref.read(currentAnneeScolaireProvider.future);
      if (annee != null) {
        final allClasses = await ref.read(classesNotifierProvider.future);
        classesDisponibles = allClasses
            .where((classe) => classe.anneeScolaireId == annee.id)
            .toList();
      }
    } catch (e) {
      print('Erreur chargement donnees: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _updateEleve() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // 1. Mettre à jour le responsable
        if (responsable != null && responsable!.id != null) {
          final updatedResponsable = responsable!.copyWith(
            nom: responsableNom,
            telephone: responsableTelephone,
            adresse: responsableAdresse,
            dateModification: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await ref
              .read(responsablesNotifierProvider.notifier)
              .updateResponsable(updatedResponsable);
        }

        // 2. Mettre à jour l'élève
        final updatedEleve = widget.eleve.copyWith(
          nom: nom,
          prenom: prenom,
          postnom: postnom,
          sexe: sexe,
          dateNaissance: dateNaissance != null
              ? DateTime.tryParse(dateNaissance!)
              : null,
          lieuNaissance: lieuNaissance,
          numeroPermanent: numeroPermanent,
          classeId: classeId,
          statut: statut,
          dateModification: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await ref
            .read(elevesNotifierProvider.notifier)
            .updateEleve(updatedEleve);

        if (mounted) Navigator.of(context).pop(true);
      } catch (e) {
        print('Erreur mise a jour eleve: $e');
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
        title: const Text('Modifier un élève'),
        backgroundColor: AyannaColors.orange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                                initialValue: nom,
                                decoration: _formFieldDecoration.copyWith(
                                  labelText: 'Nom',
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Champ requis' : null,
                                onSaved: (v) => nom = v!,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                initialValue: prenom,
                                decoration: _formFieldDecoration.copyWith(
                                  labelText: 'Prénom',
                                ),
                                onSaved: (v) => prenom = v ?? '',
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                initialValue: postnom,
                                decoration: _formFieldDecoration.copyWith(
                                  labelText: 'Post-nom',
                                ),
                                onSaved: (v) => postnom = v ?? '',
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: sexe,
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
                                initialValue: dateNaissance,
                                decoration: _formFieldDecoration.copyWith(
                                  labelText: 'Date de naissance',
                                ),
                                onSaved: (v) => dateNaissance = v ?? '',
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                initialValue: lieuNaissance,
                                decoration: _formFieldDecoration.copyWith(
                                  labelText: 'Lieu de naissance',
                                ),
                                onSaved: (v) => lieuNaissance = v ?? '',
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                initialValue: numeroPermanent,
                                decoration: _formFieldDecoration.copyWith(
                                  labelText: 'Numéro permanent',
                                ),
                                onSaved: (v) => numeroPermanent = v ?? '',
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<int>(
                                value: classeId,
                                decoration: _formFieldDecoration.copyWith(
                                  labelText: 'Classe',
                                ),
                                items: classesDisponibles
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(c.nom),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() => classeId = v),
                                validator: (v) =>
                                    v == null ? 'Classe requise' : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // SECTION 2 : CONTACT RESPONSABLE
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
                                initialValue: responsableNom,
                                decoration: _formFieldDecoration.copyWith(
                                  labelText: 'Nom du responsable',
                                ),
                                onSaved: (v) => responsableNom = v ?? '',
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                initialValue: responsableTelephone,
                                decoration: _formFieldDecoration.copyWith(
                                  labelText: 'Téléphone du responsable',
                                ),
                                onSaved: (v) => responsableTelephone = v ?? '',
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                initialValue: responsableAdresse,
                                decoration: _formFieldDecoration.copyWith(
                                  labelText: 'Adresse du responsable',
                                ),
                                onSaved: (v) => responsableAdresse = v ?? '',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AyannaColors.orange,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _updateEleve,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            'Enregistrer les modifications',
                            style: TextStyle(color: AyannaColors.white),
                          ),
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
