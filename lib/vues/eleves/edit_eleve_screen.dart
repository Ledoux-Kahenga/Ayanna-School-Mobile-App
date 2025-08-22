import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/school_queries.dart';
import '../../theme/ayanna_theme.dart';

class EditEleveScreen extends StatefulWidget {
  final Eleve eleve;
  final AnneeScolaire? anneeScolaire;
  const EditEleveScreen({Key? key, required this.eleve, this.anneeScolaire})
    : super(key: key);

  @override
  State<EditEleveScreen> createState() => _EditEleveScreenState();
}

class _EditEleveScreenState extends State<EditEleveScreen> {
  final _formKey = GlobalKey<FormState>();
  late String nom;
  late String prenom;
  String? sexe;
  String? dateNaissance;
  String? lieuNaissance;
  String? numeroPermanent;
  int? classeId;
  int? responsableId;
  String? matricule;
  String? postnom;
  String statut = 'actif';

  @override
  void initState() {
    super.initState();
    nom = widget.eleve.nom;
    prenom = widget.eleve.prenom;
    sexe = widget.eleve.sexe;
    dateNaissance = widget.eleve.dateNaissance;
    lieuNaissance = widget.eleve.lieuNaissance;
    numeroPermanent = widget.eleve.numeroPermanent;
    classeId = widget.eleve.classeId;
    responsableId = widget.eleve.responsableId;
    matricule = widget.eleve.matricule;
    postnom = widget.eleve.postnom;
    statut = widget.eleve.statut ?? 'actif';
  }

  Future<void> _updateEleve() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await SchoolQueries.updateEleve(widget.eleve.id, {
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
        title: const Text('Modifier un élève'),
        backgroundColor: AyannaColors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: nom,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
                onSaved: (v) => nom = v ?? '',
              ),
              TextFormField(
                initialValue: prenom,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Prénom requis' : null,
                onSaved: (v) => prenom = v ?? '',
              ),
              DropdownButtonFormField<String>(
                value: sexe,
                decoration: const InputDecoration(labelText: 'Sexe'),
                items: ['M', 'F']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => sexe = v,
              ),
              TextFormField(
                initialValue: dateNaissance,
                decoration: const InputDecoration(
                  labelText: 'Date de naissance',
                ),
                onSaved: (v) => dateNaissance = v,
              ),
              TextFormField(
                initialValue: lieuNaissance,
                decoration: const InputDecoration(
                  labelText: 'Lieu de naissance',
                ),
                onSaved: (v) => lieuNaissance = v,
              ),
              TextFormField(
                initialValue: numeroPermanent,
                decoration: const InputDecoration(
                  labelText: 'Numéro permanent',
                ),
                onSaved: (v) => numeroPermanent = v,
              ),
              TextFormField(
                initialValue: matricule,
                decoration: const InputDecoration(labelText: 'Matricule'),
                onSaved: (v) => matricule = v,
              ),
              TextFormField(
                initialValue: postnom,
                decoration: const InputDecoration(labelText: 'Postnom'),
                onSaved: (v) => postnom = v,
              ),
              TextFormField(
                initialValue: responsableId?.toString(),
                decoration: const InputDecoration(labelText: 'ID Responsable'),
                keyboardType: TextInputType.number,
                onSaved: (v) => responsableId = int.tryParse(v ?? ''),
              ),
              DropdownButtonFormField<String>(
                value: statut,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: ['actif', 'inactif', 'exclu']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => statut = v ?? 'actif',
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AyannaColors.orange,
                ),
                onPressed: _updateEleve,
                child: const Text('Enregistrer les modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
