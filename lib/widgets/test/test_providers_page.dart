import 'package:ayanna_school/services/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/entities/utilisateur.dart';
import '../../services/providers/data_provider_corrected.dart';

/// Page de test pour démontrer l'utilisation des providers avec mode offline
class TestProvidersPage extends ConsumerStatefulWidget {
  const TestProvidersPage({super.key});

  @override
  ConsumerState<TestProvidersPage> createState() => _TestProvidersPageState();
}

class _TestProvidersPageState extends ConsumerState<TestProvidersPage> {
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Observer l'état de connectivité
    final connectivity = ref.watch(isConnectedProvider);
    final isConnected = connectivity;

    // Observer la liste des utilisateurs
    final utilisateursAsync = ref.watch(utilisateursNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Providers'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Indicateur de connectivité
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isConnected ? Icons.wifi : Icons.wifi_off,
                  color: isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  isConnected ? 'En ligne' : 'Hors ligne',
                  style: TextStyle(
                    color: isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section d'ajout d'utilisateur
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ajouter un utilisateur',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _prenomController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _ajouterUtilisateur,
                        child: const Text('Ajouter'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Message d'information sur le mode offline
            if (!isConnected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Mode hors ligne: les données sont sauvegardées localement et seront synchronisées automatiquement quand la connexion sera rétablie.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Liste des utilisateurs
            const Text(
              'Liste des utilisateurs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: utilisateursAsync.when(
                data: (utilisateurs) {
                  if (utilisateurs.isEmpty) {
                    return const Center(
                      child: Text('Aucun utilisateur trouvé'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(utilisateurServiceProvider);
                    },
                    child: ListView.builder(
                      itemCount: utilisateurs.length,
                      itemBuilder: (context, index) {
                        final utilisateur = utilisateurs[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                utilisateur.nom
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                              ),
                            ),
                            title: Text(utilisateur.nom ?? 'Nom non défini'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(utilisateur.email ?? 'Email non défini'),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      utilisateur.isSync == true
                                          ? Icons.cloud_done
                                          : Icons.cloud_off,
                                      size: 16,
                                      color:
                                          utilisateur.isSync == true
                                              ? Colors.green
                                              : Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      utilisateur.isSync == true
                                          ? 'Synchronisé'
                                          : 'Non synchronisé',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            utilisateur.isSync == true
                                                ? Colors.green
                                                : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    _modifierUtilisateur(utilisateur);
                                    break;
                                  case 'delete':
                                    _supprimerUtilisateur(utilisateur);
                                    break;
                                
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit),
                                          SizedBox(width: 8),
                                          Text('Modifier'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Supprimer'),
                                        ],
                                      ),
                                    ),
                                    if (utilisateur.isSync != true)
                                      const PopupMenuItem(
                                        value: 'sync',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.sync,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Synchroniser'),
                                          ],
                                        ),
                                      ),
                                  ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur: $error',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref.invalidate(utilisateurServiceProvider);
                            },
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.invalidate(utilisateurServiceProvider);
        },
        tooltip: 'Actualiser',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Future<void> _ajouterUtilisateur() async {
    final prenom = _prenomController.text.trim();
    final nom = _nomController.text.trim();

    if (prenom.isEmpty || nom.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs', Colors.red);
      return;
    }

    try {
      final nouvelUtilisateur = Utilisateur(
        prenom: prenom,
        nom: nom,
        email: '$prenom.$nom@exemple.com', // Email généré
        motDePasseHash: 'hash_temporaire',
        role: 'utilisateur',
        entrepriseId: 1, // ID par défaut
        isSync: false, // Sera mis à true après synchronisation
        actif: true,
        dateCreation: DateTime.now(),
        dateModification: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await ref
          .read(utilisateursNotifierProvider.notifier)
          .addUtilisateur(nouvelUtilisateur);

   
        _prenomController.clear();
        _nomController.clear();
        _showSnackBar('Utilisateur ajouté avec succès', Colors.green);
    
    } catch (e) {
      _showSnackBar('Erreur: $e', Colors.red);
    }
  }

  Future<void> _modifierUtilisateur(Utilisateur utilisateur) async {
    // Pré-remplir les champs avec les données existantes
    _prenomController.text = utilisateur.prenom;
    _nomController.text = utilisateur.nom;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Modifier l\'utilisateur'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _prenomController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Modifier'),
              ),
            ],
          ),
    );

    if (result == true) {
      try {
        final utilisateurModifie = Utilisateur(
          id: utilisateur.id,
          serverId: utilisateur.serverId,
          prenom: _prenomController.text.trim(),
          nom: _nomController.text.trim(),
          email:
              '${_prenomController.text.trim()}.${_nomController.text.trim()}@exemple.com',
          motDePasseHash: utilisateur.motDePasseHash,
          role: utilisateur.role,
          entrepriseId: utilisateur.entrepriseId,
          isSync: false, // Marquer comme non synchronisé après modification
          actif: utilisateur.actif,
          dateCreation: utilisateur.dateCreation,
          dateModification: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final success = await ref
            .read(utilisateursNotifierProvider.notifier)
            .updateUtilisateur(utilisateurModifie);

        _showSnackBar('Utilisateur modifié avec succès', Colors.green);
      } catch (e) {
        _showSnackBar('Erreur: $e', Colors.red);
      }
    }

    _prenomController.clear();
    _nomController.clear();
  }

  Future<void> _supprimerUtilisateur(Utilisateur utilisateur) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer l\'utilisateur "${utilisateur.nom}" ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );

    if (result == true && utilisateur.id != null) {
      try {
        final success = await ref
            .read(utilisateursNotifierProvider.notifier)
            .deleteUtilisateur(utilisateur);

        _showSnackBar('Utilisateur supprimé avec succès', Colors.green);
      } catch (e) {
        _showSnackBar('Erreur: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
