import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_upload_request.dart';
import '../models/entities/eleve.dart';
import '../services/api/sync_service.dart';

/// Exemple pratique d'utilisation de la structure d'upload pour sync
class SyncUploadExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Exemple Upload Sync')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _exempleUploadEleve(),
              child: Text('Upload Élève Modifié'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _exempleUploadPlusieurs(),
              child: Text('Upload Plusieurs Changements'),
            ),
          ],
        ),
      ),
    );
  }

  /// Exemple 1: Upload d'un élève modifié
  Future<void> _exempleUploadEleve() async {
    // Créer un élève avec les données exactes de votre exemple
    final eleve = Eleve(
      serverId: 71, // ID du serveur
      nom: "Kalombo",
      postnom: "Kante",
      prenom: "Elvis",
      sexe: "Masculin",
      statut: "actif",
      dateNaissance: DateTime.parse("2015-09-12"),
      matricule: "EKAKAEL469",
      classeId: 38,
      responsableId: 99,
      dateCreation: DateTime.parse("2025-09-12T16:28:53.000000+00:00"),
      dateModification: DateTime.parse("2025-09-12T16:28:53.000000+00:00"),
      updatedAt: DateTime.parse("2025-09-12T16:31:24.000000+00:00"),
    );

    // Construire la requête d'upload
    final builder = SyncUploadRequestBuilder(clientId: 'flutter-client');

    // Préparer les données de l'élève (retirer les champs locaux)
    final eleveData = eleve.toJson();
    eleveData.remove('id'); // Retirer l'ID local
    eleveData.remove('is_sync'); // Retirer le statut de sync local

    // Ajouter le changement comme modification
    builder.addUpdate('eleves', eleveData);

    // Construire la requête finale
    final uploadRequest = builder.build();

    print('Requête construite:');
    print('JSON: ${uploadRequest.toJson()}');

    // Pour envoyer la requête :
    // final syncService = SyncService.create();
    // final response = await syncService.uploadChanges(uploadRequest);
  }

  /// Exemple 2: Upload de plusieurs changements
  Future<void> _exempleUploadPlusieurs() async {
    final builder = SyncUploadRequestBuilder(clientId: 'flutter-client');

    // Élève modifié
    final eleveModifie = {
      "id": 71,
      "nom": "Kalombo",
      "postnom": "Kante",
      "prenom": "Elvis",
      "sexe": "Masculin",
      "statut": "actif",
      "date_naissance": "2015-09-12",
      "lieu_naissance": null,
      "matricule": "EKAKAEL469",
      "numero_permanent": null,
      "classe_id": 38,
      "responsable_id": 99,
      "date_creation": "2025-09-12T16:28:53.000000+00:00",
      "date_modification": "2025-09-12T16:28:53.000000+00:00",
      "updated_at": "2025-09-12T16:31:24.000000+00:00",
    };

    // Nouvel élève
    final nouvelEleve = {
      "id": 75,
      "nom": "Akili",
      "postnom": "Mali",
      "prenom": "Chrispin",
      "sexe": "Masculin",
      "statut": "actif",
      "date_naissance": "2015-09-14",
      "lieu_naissance": "Goma",
      "matricule": "EAKMACH688",
      "numero_permanent": null,
      "classe_id": 40,
      "responsable_id": 101,
      "date_creation": "2025-09-14T14:20:52.000000+00:00",
      "date_modification": "2025-09-14T14:20:52.000000+00:00",
      "updated_at": "2025-09-14T14:21:38.000000+00:00",
    };

    // Ajouter les changements
    builder.addUpdate('eleves', eleveModifie);
    builder.addInsert('eleves', nouvelEleve);

    // Construire la requête
    final uploadRequest = builder.build();

    print('Requête avec plusieurs changements:');
    print('Nombre de changements: ${uploadRequest.changes.length}');
    print('JSON complet:');
    print(uploadRequest.toJson());

    // La structure JSON générée correspondra exactement à votre exemple :
    // {
    //   "client_id": "flutter-client",
    //   "changes": [
    //     {
    //       "table": "eleves",
    //       "operation": "update",
    //       "action": "modifié",
    //       "data": { ... }
    //     },
    //     {
    //       "table": "eleves",
    //       "operation": "insert",
    //       "action": "ajout",
    //       "data": { ... }
    //     }
    //   ],
    //   "timestamp": "2025-10-04T..."
    // }
  }
}

/// Classe utilitaire pour faciliter l'upload
class QuickSyncUploader {
  final SyncUploadRequestBuilder _builder;

  QuickSyncUploader({String clientId = 'flutter-client'})
    : _builder = SyncUploadRequestBuilder(clientId: clientId);

  /// Ajouter rapidement un élève modifié
  void updateEleve(Map<String, dynamic> eleveData) {
    _builder.addUpdate('eleves', eleveData);
  }

  /// Ajouter rapidement un nouvel élève
  void insertEleve(Map<String, dynamic> eleveData) {
    _builder.addInsert('eleves', eleveData);
  }

  /// Supprimer un élève
  void deleteEleve(int eleveId) {
    _builder.addDelete('eleves', {'id': eleveId});
  }

  /// Construire et obtenir la requête
  SyncUploadRequest build() => _builder.build();

  /// Statistiques
  Map<String, int> get stats => _builder.changeStats;

  /// Aperçu des changements
  void printSummary() {
    final stats = _builder.changeStats;
    print('Résumé des changements:');
    print('- Insertions: ${stats['insert'] ?? 0}');
    print('- Modifications: ${stats['update'] ?? 0}');
    print('- Suppressions: ${stats['delete'] ?? 0}');
    print('- Total: ${_builder.changeCount}');
  }
}

/// Exemple d'utilisation rapide
void exempleUtilisationRapide() {
  final uploader = QuickSyncUploader();

  // Ajouter des changements
  uploader.updateEleve({
    "id": 71,
    "nom": "Kalombo Updated",
    // ... autres champs
  });

  uploader.insertEleve({
    "id": 75,
    "nom": "Nouvel Élève",
    // ... autres champs
  });

  // Voir le résumé
  uploader.printSummary();

  // Construire la requête finale
  final request = uploader.build();

  // Envoyer via le service
  // await syncService.uploadChanges(request);
}
