# Structure d'Upload pour Synchronisation Ayanna School

## Vue d'ensemble

Le système d'upload permet d'envoyer les modifications locales vers le serveur avec une structure JSON standardisée. Voici comment utiliser cette fonctionnalité.

## Structure de la requête d'upload

### Format JSON attendu par le serveur :

```json
{
    "client_id": "flutter-client",
    "changes": [
        {
            "table": "eleves",
            "operation": "update",
            "action": "modifié",
            "data": {
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
                "updated_at": "2025-09-12T16:31:24.000000+00:00"
            }
        },
        {
            "table": "eleves",
            "operation": "insert",
            "action": "ajout",
            "data": {
                "id": 75,
                "nom": "Akili",
                "postnom": "Mali",
                "prenom": "Chrispin",
                // ... autres champs
            }
        }
    ],
    "timestamp": "2025-10-04T12:00:00.000Z"
}
```

## Modèles Dart créés

### 1. SyncUploadRequest
Modèle principal pour la requête d'upload.

### 2. SyncChangeUpload  
Modèle pour chaque changement individuel.

### 3. SyncUploadRequestBuilder
Builder pour construire facilement les requêtes.

## Types d'opérations

| Operation | Action | Description |
|-----------|--------|-------------|
| `insert` | `ajout` | Nouveau record |
| `update` | `modifié` | Record existant modifié |
| `delete` | `supprimé` | Record supprimé |

## Utilisation

### 1. Utilisation basique avec le Builder

```dart
import '../models/sync_upload_request.dart';

// Créer un builder
final builder = SyncUploadRequestBuilder(clientId: 'flutter-client');

// Ajouter des changements
builder.addUpdate('eleves', {
  "id": 71,
  "nom": "Kalombo",
  "postnom": "Kante",
  // ... autres champs
});

builder.addInsert('eleves', {
  "id": 75, 
  "nom": "Nouvel Élève",
  // ... autres champs
});

// Construire la requête
final uploadRequest = builder.build();

// Envoyer via le service
final syncService = SyncService.create();
final response = await syncService.uploadChanges(uploadRequest);
```

### 2. Avec le helper spécialisé

```dart
import '../services/helpers/sync_upload_helper.dart';

final helper = SyncUploadHelper(clientId: 'flutter-client');

// Ajouter un élève modifié
helper.addEleve(eleve, operation: SyncOperation.update);

// Ajouter plusieurs élèves
helper.addEleves(listeEleves, operation: SyncOperation.insert);

// Construire et envoyer
final request = helper.build();
await syncService.uploadChanges(request);
```

### 3. Utilisation rapide

```dart
final uploader = QuickSyncUploader();

// Modifications simples
uploader.updateEleve(eleveData);
uploader.insertEleve(nouvelEleveData);
uploader.deleteEleve(eleveId);

// Voir les statistiques
uploader.printSummary();

// Envoyer
final request = uploader.build();
await syncService.uploadChanges(request);
```

## Intégration avec les entités existantes

### Préparation des données d'entité

```dart
// Partir d'un objet Eleve
final eleve = Eleve(...);

// Convertir en JSON et nettoyer
final eleveData = eleve.toJson();
eleveData.remove('id'); // Retirer l'ID local
eleveData.remove('is_sync'); // Retirer le statut sync

// Ajouter au builder
builder.addUpdate('eleves', eleveData);
```

### Collecte automatique des changements non synchronisés

```dart
Future<SyncUploadRequest> collecterChangementsLocaux() async {
  final builder = SyncUploadRequestBuilder();
  
  // Élèves non synchronisés
  final elevesNonSync = await database.eleveDao.getUnsyncedEleves();
  for (final eleve in elevesNonSync) {
    final data = eleve.toJson();
    data.remove('id');
    data.remove('is_sync');
    
    if (eleve.serverId != null) {
      builder.addUpdate('eleves', data);
    } else {
      builder.addInsert('eleves', data);
    }
  }
  
  // Ajouter d'autres entités...
  
  return builder.build();
}
```

## Service API mis à jour

Le `SyncService` a été modifié pour accepter `SyncUploadRequest` :

```dart
@Post(path: '/upload')
Future<Response<SyncUploadResponse>> uploadChanges(
  @Body() SyncUploadRequest uploadRequest, {
  @Query('client_id') String? clientId,
});
```

## Gestion des erreurs

```dart
try {
  final response = await syncService.uploadChanges(uploadRequest);
  
  if (response.isSuccessful && response.body != null) {
    print('Upload réussi: ${response.body}');
    // Marquer les éléments comme synchronisés
  } else {
    print('Erreur upload: ${response.error}');
  }
} catch (e) {
  print('Exception upload: $e');
}
```

## Bonnes pratiques

### 1. Nettoyage des données
- Toujours retirer les champs `id` (ID local) et `is_sync`
- Le serveur utilise `server_id` comme identifiant principal

### 2. Gestion des opérations
- `insert` : Pour les nouveaux records (pas de `server_id`)
- `update` : Pour les records existants (avec `server_id`)
- `delete` : Envoyer seulement l'ID serveur

### 3. Batching
- Grouper plusieurs changements dans une seule requête
- Éviter les requêtes trop grandes (limiter à ~100 changements)

### 4. Timestamps
- Le timestamp est automatiquement généré
- Utilisé par le serveur pour l'ordre des opérations

## Statistiques et monitoring

```dart
final builder = SyncUploadRequestBuilder();
// ... ajouter des changements ...

// Statistiques
print('Changements: ${builder.changeCount}');
print('Par opération: ${builder.changeStats}');
print('Par table: ${builder.changesByTable}');
```

## Exemples complets

Voir les fichiers :
- `lib/examples/sync_upload_example.dart` : Exemples pratiques
- `lib/services/helpers/sync_upload_helper.dart` : Helper avancé
- `lib/models/sync_upload_request.dart` : Modèles de base

## Intégration avec le provider de sync

Pour intégrer dans votre `SyncProvider` existant :

```dart
Future<void> uploadLocalChanges() async {
  // 1. Collecter les changements
  final builder = SyncUploadRequestBuilder();
  await _collectAllUnsyncedChanges(builder);
  
  // 2. Construire la requête
  final request = builder.build();
  
  // 3. Envoyer
  final response = await uploadChanges(request);
  
  // 4. Traiter la réponse
  if (response != null) {
    // Marquer comme synchronisé
    await _markAsSynced(builder.changesByTable);
  }
}
```

Cette structure vous permet de maintenir une parfaite compatibilité avec l'API serveur tout en offrant une interface Dart typée et facile à utiliser.
