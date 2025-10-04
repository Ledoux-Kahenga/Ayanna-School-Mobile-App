# Système de Synchronisation Ayanna School

## Vue d'ensemble

Le système de synchronisation permet de maintenir les données locales à jour avec le serveur distant. Il utilise SharedPreferences pour stocker l'état de synchronisation et éviter les synchronisations inutiles.

## Architecture

### Composants principaux

1. **SyncService** (`lib/services/api/sync_service.dart`)
   - Service API utilisant Chopper pour communiquer avec le serveur
   - Gère l'authentification Bearer token
   - Endpoints: `/sync/download` et `/sync/upload`

2. **SyncProvider** (`lib/services/providers/sync_provider_new.dart`)
   - Provider Riverpod gérant l'état de synchronisation
   - Orchestration des téléchargements et traitements
   - Intégration avec SharedPreferences

3. **SharedPreferencesProvider** (`lib/services/providers/shared_preferences_provider.dart`)
   - Stockage persistant des dates de synchronisation
   - Gestion des informations utilisateur
   - Utilitaires pour vérifier si une sync est nécessaire

4. **Widgets de synchronisation** (`lib/widgets/sync_widgets.dart`)
   - Composants UI réutilisables
   - Affichage de l'état et du progrès
   - Boutons d'action

## Utilisation

### 1. Configuration initiale

Assurez-vous que vos providers sont configurés dans votre application :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/providers/sync_provider_new.dart';
import 'services/providers/shared_preferences_provider.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 2. Utilisation basique

```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateNotifierProvider);
    
    return Column(
      children: [
        // Affichage du statut
        SyncStatusWidget(),
        
        // Bouton de synchronisation
        SyncButton(
          userEmail: 'user@example.com',
          child: Text('Synchroniser'),
        ),
      ],
    );
  }
}
```

### 3. Synchronisation programmatique

```dart
class SyncController {
  final WidgetRef ref;
  
  SyncController(this.ref);
  
  // Synchronisation normale (utilise la date de dernière sync)
  Future<void> performNormalSync(String userEmail) async {
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);
    await syncNotifier.performFullSync(userEmail);
  }
  
  // Synchronisation forcée (ignore la date de dernière sync)
  Future<void> performForcedSync(String userEmail) async {
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);
    await syncNotifier.performForcedSync(userEmail);
  }
  
  // Vérifier si une sync est nécessaire
  Future<bool> isSyncNeeded() async {
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);
    return await syncNotifier.isSyncNeeded();
  }
}
```

## États de synchronisation

### SyncStatus

- **idle**: Aucune synchronisation en cours
- **downloading**: Téléchargement des données depuis le serveur
- **uploading**: Upload des modifications locales
- **processing**: Traitement et insertion des données
- **error**: Erreur pendant la synchronisation

### SyncState

```dart
class SyncState {
  final SyncStatus status;
  final String? message;
  final String? error;
  final int? totalChanges;
  final int? processedChanges;
  
  // Calcul automatique du progrès
  double get progress => totalChanges != null && processedChanges != null
      ? processedChanges! / totalChanges!
      : 0.0;
}
```

## Persistance des données

### SharedPreferences

Le système stocke automatiquement :

- **lastSyncDate**: Date de la dernière synchronisation réussie
- **lastSyncUserEmail**: Email de l'utilisateur de la dernière sync

### Méthodes utilitaires

```dart
// Obtenir la date de dernière sync
final syncPrefs = ref.read(syncPreferencesNotifierProvider.notifier);
final lastSync = await syncPrefs.getLastSyncDate();

// Sauvegarder une nouvelle date de sync
await syncPrefs.saveLastSyncDate(DateTime.now(), 'user@email.com');

// Vérifier si une sync est nécessaire (plus de 1 heure)
final isNeeded = await syncPrefs.isSyncNeeded();

// Effacer les données de sync
await syncPrefs.clearSyncData();
```

## Gestion des erreurs

### Types d'erreurs

1. **Erreurs réseau**: Problèmes de connexion
2. **Erreurs d'authentification**: Token invalide
3. **Erreurs de données**: Problèmes de format JSON
4. **Erreurs de base de données**: Problèmes d'insertion

### Récupération d'erreurs

```dart
try {
  await syncNotifier.performFullSync(userEmail);
} catch (e) {
  if (e is NetworkException) {
    // Gérer les erreurs réseau
  } else if (e is AuthenticationException) {
    // Gérer les erreurs d'auth
  } else {
    // Autres erreurs
  }
}
```

## Optimisations

### Synchronisation intelligente

- **Vérification automatique**: Le système vérifie si une sync est nécessaire
- **Intervalle configurable**: Par défaut 1 heure entre les syncs
- **Sync forcée**: Bypass de la vérification temporelle

### Performance

- **Traitement par batch**: Les changements sont traités par groupes
- **Progrès en temps réel**: Affichage du pourcentage d'avancement
- **Gestion mémoire**: Libération des ressources après traitement

## Intégration dans l'UI

### Widgets disponibles

1. **SyncStatusWidget**: Affichage compact de l'état
2. **SyncButton**: Bouton d'action avec gestion d'état
3. **LastSyncDetailsWidget**: Détails de la dernière synchronisation

### Exemples d'intégration

Voir les fichiers d'exemple :
- `lib/examples/sync_example_screen.dart`: Écran complet de démonstration
- `lib/examples/home_page_with_sync.dart`: Intégration dans une page principale

## Configuration

### Variables d'environnement

```dart
// Configuration API dans api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://apischool.ayanna.cloud';
  static const String syncEndpoint = '/sync/download';
  static const String uploadEndpoint = '/sync/upload';
}
```

### Authentification

Le système utilise un Bearer token pour l'authentification. Assurez-vous de configurer le token avant d'utiliser le service.

## Tests

### Tests unitaires

```dart
// Exemple de test pour le sync provider
void main() {
  group('SyncProvider Tests', () {
    testWidgets('Should perform sync successfully', (tester) async {
      // Test implementation
    });
  });
}
```

### Tests d'intégration

```dart
// Test avec données réelles
void main() {
  group('Sync Integration Tests', () {
    test('Should sync with real API', () async {
      // Test avec l'API réelle
    });
  });
}
```

## Dépannage

### Problèmes courants

1. **Sync bloquée**: Redémarrer l'application ou forcer la sync
2. **Données manquantes**: Vérifier la connexion réseau
3. **Erreurs d'authentification**: Vérifier le token Bearer
4. **Performance lente**: Vérifier la taille des données

### Logs et débogage

Le système inclut des logs détaillés pour le débogage. Activez le mode debug pour voir les messages complets.

## Roadmap

### Améliorations futures

1. **Synchronisation incrémentale**: Sync seulement des modifications
2. **Résolution de conflits**: Gestion des modifications concurrentes
3. **Synchronisation en arrière-plan**: Sync automatique périodique
4. **Compression des données**: Réduction de la bande passante
5. **Synchronisation offline-first**: Gestion hors ligne avancée
