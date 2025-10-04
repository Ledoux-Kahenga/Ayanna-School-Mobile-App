# Intégration Riverpod - Guide d'utilisation

## 🎯 Aperçu

Cette application utilise **Riverpod** comme solution de gestion d'état moderne, remplaçant l'ancienne architecture basée sur Provider. Riverpod offre une meilleure performance, une sécurité de type améliorée et une architecture plus maintenable.

## 📁 Structure des Providers

```
lib/services/providers/
├── api_client_provider.dart      # Providers pour les services API
├── database_provider.dart        # Providers pour la base de données
├── data_provider.dart            # Providers pour les données métier
├── app_provider.dart             # Providers globaux de l'application
└── providers.dart                # Export centralisé
```

## 🔧 Configuration

### 1. Dépendances ajoutées au pubspec.yaml

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  
dev_dependencies:
  riverpod_annotation: ^2.3.5
  riverpod_generator: ^2.4.0
  riverpod_lint: ^2.3.10
```

### 2. Initialisation dans main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... autres initialisations
  
  runApp(
    ProviderScope(  // ✅ Wrapper Riverpod
      child: MainApp(),
    ),
  );
}
```

## 🏗️ Architecture des Providers

### 1. Providers API (api_client_provider.dart)

- **apiClientProvider**: Client HTTP centralisé avec Chopper
- **Services individuels**: Un provider pour chaque service métier
  - `eleveServiceProvider`
  - `classeServiceProvider`
  - `enseignantServiceProvider`
  - etc.

```dart
@riverpod
ApiClient apiClient(ApiClientRef ref) {
  return ApiClient.create();
}

@riverpod
EleveService eleveService(EleveServiceRef ref) {
  final client = ref.watch(apiClientProvider);
  return client.eleveService;
}
```

### 2. Providers Base de Données (database_provider.dart)

- **databaseProvider**: Instance de la base de données Floor
- **DAO Providers**: Un provider pour chaque DAO
  - `eleveDaoProvider`
  - `classeDaoProvider`
  - `enseignantDaoProvider`
  - etc.

```dart
@riverpod
Future<AppDatabase> database(DatabaseRef ref) async {
  final database = await AppDatabase.create();
  ref.onDispose(() async {
    await database.close();
  });
  return database;
}
```

### 3. Providers de Données (data_provider.dart)

Providers métier avec logique de synchronisation API ↔ Base de données locale:

```dart
@riverpod
class ElevesNotifier extends _$ElevesNotifier {
  @override
  Future<List<Eleve>> build() async {
    final dao = await ref.watch(eleveDaoProvider.future);
    return await dao.findAllEleves();
  }

  // Méthodes CRUD avec synchronisation
  Future<void> addEleve(Eleve eleve) async { ... }
  Future<void> updateEleve(Eleve eleve) async { ... }
  Future<void> deleteEleve(int id) async { ... }
  Future<void> refresh() async { ... }
}
```

### 4. Providers Globaux (app_provider.dart)

- **AuthNotifier**: Gestion de l'authentification
- **AppSettingsNotifier**: Paramètres de l'application
- **SyncNotifier**: État de synchronisation
- **NetworkNotifier**: État de connectivité

## 🎨 Utilisation dans les Widgets

### ConsumerWidget Pattern

```dart
class ElevesListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elevesAsyncValue = ref.watch(elevesNotifierProvider);
    
    return elevesAsyncValue.when(
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Erreur: $error'),
      data: (eleves) => ListView.builder(
        itemCount: eleves.length,
        itemBuilder: (context, index) {
          final eleve = eleves[index];
          return ListTile(
            title: Text('${eleve.prenom} ${eleve.nom}'),
            onTap: () => _showDetails(eleve),
          );
        },
      ),
    );
  }
}
```

### Modification des Données

```dart
// Ajouter un élève
await ref.read(elevesNotifierProvider.notifier).addEleve(nouvelEleve);

// Mettre à jour un élève
await ref.read(elevesNotifierProvider.notifier).updateEleve(eleveModifie);

// Supprimer un élève
await ref.read(elevesNotifierProvider.notifier).deleteEleve(eleveId);

// Rafraîchir depuis l'API
await ref.read(elevesNotifierProvider.notifier).refresh();
```

## 🔄 Stratégie de Synchronisation

### 1. Offline-First

- Les données sont d'abord sauvegardées localement
- La synchronisation avec l'API se fait en arrière-plan
- L'application fonctionne même sans connexion

### 2. Gestion des Erreurs

```dart
try {
  // Tentative de synchronisation API
  final result = await apiService.createEleve(eleve);
  await dao.insertEleve(result);
} catch (e) {
  // Fallback: sauvegarde locale uniquement
  await dao.insertEleve(eleve);
  // Marquer pour synchronisation ultérieure
}
```

### 3. États de Chargement

Chaque provider de données gère automatiquement:
- ✅ **Loading**: Pendant le chargement initial
- ✅ **Error**: En cas d'erreur avec possibilité de retry
- ✅ **Data**: Données disponibles avec mise à jour automatique

## 🚀 Avantages de Riverpod

### 1. Performance
- Recalcul uniquement des widgets concernés
- Mise en cache intelligente des données
- Disposal automatique des ressources

### 2. Sécurité de Type
- Erreurs de compilation au lieu d'erreurs runtime
- IntelliSense complet
- Refactoring sûr

### 3. Testabilité
- Providers facilement mockables
- Tests isolés par fonctionnalité
- Injection de dépendances native

### 4. Maintenabilité
- Code plus lisible et organisé
- Séparation claire des responsabilités
- Architecture évolutive

## 📊 Comparaison avec l'Ancienne Architecture

| Aspect | Provider (Ancien) | Riverpod (Nouveau) |
|--------|------------------|-------------------|
| Performance | ⚠️ Moyen | ✅ Excellent |
| Sécurité Type | ❌ Runtime errors | ✅ Compile-time safety |
| DevTools | ⚠️ Basique | ✅ Avancé |
| Testing | ⚠️ Complexe | ✅ Simple |
| Boilerplate | ❌ Beaucoup | ✅ Minimal |

## 🛠️ Commandes de Développement

```bash
# Générer les fichiers .g.dart
dart run build_runner build

# Générer en mode watch (développement)
dart run build_runner watch

# Nettoyer et régénérer
dart run build_runner build --delete-conflicting-outputs

# Analyser le code
flutter analyze

# Lancer les tests
flutter test
```

## 📝 Exemple d'Implémentation

Voir le fichier `lib/widgets/eleves_list_riverpod.dart` pour un exemple complet d'utilisation des providers Riverpod dans un widget réel.

## 🔗 Ressources

- [Documentation officielle Riverpod](https://riverpod.dev/)
- [Migration depuis Provider](https://riverpod.dev/docs/from_provider)
- [Patterns et bonnes pratiques](https://riverpod.dev/docs/concepts/reading)
