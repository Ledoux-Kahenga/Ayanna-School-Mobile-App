import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/entities/eleve.dart';
import '../../services/providers/providers.dart';

/// Exemple d'utilisation des providers Riverpod pour afficher la liste des élèves
class ElevesListWidget extends ConsumerWidget {
  const ElevesListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écouter les changements de la liste des élèves
    final elevesAsyncValue = ref.watch(elevesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Élèves'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Rafraîchir les données depuis l'API
              ref.read(syncNotifierProvider.notifier).startSync();
            },
          ),
        ],
      ),
      body: elevesAsyncValue.when(
        // État de chargement
        loading: () => const Center(child: CircularProgressIndicator()),
        // État d'erreur
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Réessayer de charger les données
                      ref.invalidate(elevesNotifierProvider);
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
        // État avec données
        data:
            (eleves) => ListView.builder(
              itemCount: eleves.length,
              itemBuilder: (context, index) {
                final eleve = eleves[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(eleve.nom.substring(0, 1).toUpperCase()),
                    ),
                    title: Text('${eleve.prenom} ${eleve.nom}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (eleve.dateNaissance != null)
                          Text('Né(e) le: ${eleve.dateNaissance}'),
                        if (eleve.sexe != null) Text('Sexe: ${eleve.sexe}'),
                        if (eleve.matricule != null)
                          Text('Matricule: ${eleve.matricule}'),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Modifier'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete),
                                title: Text('Supprimer'),
                              ),
                            ),
                          ],
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _editEleve(context, ref, eleve);
                            break;
                          case 'delete':
                            _deleteEleve(context, ref, eleve);
                            break;
                        }
                      },
                    ),
                    onTap: () {
                      // Naviguer vers les détails de l'élève
                      _showEleveDetails(context, eleve);
                    },
                  ),
                );
              },
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addEleve(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Ajouter un nouvel élève
  void _addEleve(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => _EleveFormDialog(
            onSave: (eleve) async {
              try {
                await ref.read(elevesNotifierProvider.notifier).addEleve(eleve);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Élève ajouté avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
    );
  }

  /// Modifier un élève
  void _editEleve(BuildContext context, WidgetRef ref, Eleve eleve) {
    showDialog(
      context: context,
      builder:
          (context) => _EleveFormDialog(
            eleve: eleve,
            onSave: (updatedEleve) async {
              try {
                await ref
                    .read(elevesNotifierProvider.notifier)
                    .updateEleve(updatedEleve);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Élève modifié avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
    );
  }

  /// Supprimer un élève
  void _deleteEleve(BuildContext context, WidgetRef ref, Eleve eleve) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer l\'élève ${eleve.prenom} ${eleve.nom} ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await ref
                        .read(elevesNotifierProvider.notifier)
                        .deleteEleve(eleve);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Élève supprimé avec succès'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
  }

  /// Afficher les détails d'un élève
  void _showEleveDetails(BuildContext context, Eleve eleve) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${eleve.prenom} ${eleve.nom}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eleve.dateNaissance != null)
                  Text('Date de naissance: ${eleve.dateNaissance}'),
                if (eleve.sexe != null) Text('Sexe: ${eleve.sexe}'),
                if (eleve.lieuNaissance != null)
                  Text('Lieu de naissance: ${eleve.lieuNaissance}'),
                if (eleve.matricule != null)
                  Text('Matricule: ${eleve.matricule}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }
}

/// Dialog pour ajouter/modifier un élève
class _EleveFormDialog extends StatefulWidget {
  final Eleve? eleve;
  final Function(Eleve) onSave;

  const _EleveFormDialog({this.eleve, required this.onSave});

  @override
  State<_EleveFormDialog> createState() => _EleveFormDialogState();
}

class _EleveFormDialogState extends State<_EleveFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _lieuNaissanceController;
  late TextEditingController _matriculeController;
  String? _sexe;
  DateTime? _dateNaissance;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.eleve?.nom ?? '');
    _prenomController = TextEditingController(text: widget.eleve?.prenom ?? '');
    _lieuNaissanceController = TextEditingController(
      text: widget.eleve?.lieuNaissance ?? '',
    );
    _matriculeController = TextEditingController(
      text: widget.eleve?.matricule ?? '',
    );
    _sexe = widget.eleve?.sexe;
    _dateNaissance = widget.eleve?.dateNaissance;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _lieuNaissanceController.dispose();
    _matriculeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.eleve == null ? 'Ajouter un élève' : 'Modifier l\'élève',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prénom';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _sexe,
                decoration: const InputDecoration(labelText: 'Sexe'),
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('Masculin')),
                  DropdownMenuItem(value: 'F', child: Text('Féminin')),
                ],
                onChanged: (value) => setState(() => _sexe = value),
              ),
              TextFormField(
                controller: _lieuNaissanceController,
                decoration: const InputDecoration(
                  labelText: 'Lieu de naissance',
                ),
              ),
              TextFormField(
                controller: _matriculeController,
                decoration: const InputDecoration(labelText: 'Matricule'),
              ),
              ListTile(
                title: const Text('Date de naissance'),
                subtitle: Text(
                  _dateNaissance?.toLocal().toString().split(' ')[0] ??
                      'Non définie',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dateNaissance ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _dateNaissance = date);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final eleve = Eleve(
                id: widget.eleve?.id,
                nom: _nomController.text,
                prenom: _prenomController.text,
                sexe: _sexe,
                dateNaissance: _dateNaissance,
                lieuNaissance:
                    _lieuNaissanceController.text.isEmpty
                        ? null
                        : _lieuNaissanceController.text,
                matricule:
                    _matriculeController.text.isEmpty
                        ? null
                        : _matriculeController.text,
                classeId: widget.eleve?.classeId ?? 1, // ID par défaut
                dateCreation: widget.eleve?.dateCreation ?? DateTime.now(),
                dateModification: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              widget.onSave(eleve);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Sauvegarder'),
        ),
      ],
    );
  }
}
