import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/school_queries.dart';
import '../../theme/ayanna_theme.dart';

class AddEleveScreen extends StatefulWidget {
  final int? classeId;
  final AnneeScolaire? anneeScolaire;
  const AddEleveScreen({Key? key, this.classeId, this.anneeScolaire})
    : super(key: key);

  @override
  State<AddEleveScreen> createState() => _AddEleveScreenState();
}

class _AddEleveScreenState extends State<AddEleveScreen> {
  final _formKey = GlobalKey<FormState>();
  String nom = '';
  String postNom = '';
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
  String? postnom;
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
    _chargerClasses(); // Call the function after its declaration

  }

  Future<void> _chargerClasses() async {
    final anneeId = widget.anneeScolaire?.id;
    if (anneeId != null) {
      final classes = await SchoolQueries.getClassesByAnnee(anneeId);
      setState(() {
        classesDisponibles = classes;
      });
    }
  }

  Future<void> _saveEleve() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db =
          await SchoolQueries.getAllAnneesScolaires(); // Just to ensure DB is ready
      await SchoolQueries.insertEleve({
        'nom': nom,
        'prenom': prenom,
        'sexe': sexe,
        'date_naissance': dateNaissance,
        'lieu_naissance': lieuNaissance,
        'numero_permanent': numeroPermanent,
        'classe_id': classeId,
        'responsable_id': responsableId,
        'matricule': matricule,
        'postnom': postnom,
        'statut': statut,
      });
      Navigator.of(context).pop(true);
    }
  }

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
          child: ListView(
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
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Nom'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Nom requis' : null,
                        onSaved: (v) => nom = v ?? '',
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Post-nom',
                        ),
                        onSaved: (v) => postNom = v ?? '',
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Prénom'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Prénom requis' : null,
                        onSaved: (v) => prenom = v ?? '',
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Sexe'),
                        items: ['M', 'F']
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (v) => sexe = v,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Date de naissance',
                        ),
                        onSaved: (v) => dateNaissance = v,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Lieu de naissance',
                        ),
                        onSaved: (v) => lieuNaissance = v,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Numéro permanent',
                        ),
                        onSaved: (v) => numeroPermanent = v,
                      ),
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
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Classe'),
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
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nom du responsable',
                        ),
                        onSaved: (v) => responsableNom = v ?? '',
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Téléphone parent',
                        ),
                        onSaved: (v) => responsableTelephone = v ?? '',
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Email'),
                        onSaved: (v) => responsableEmail = v ?? '',
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Adresse'),
                        onSaved: (v) => responsableAdresse = v ?? '',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AyannaColors.orange,
                ),
                onPressed: _saveEleve,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
