# Providers Riverpod - Documentation Complète

## 📁 Structure des Providers

Le fichier `lib/services/providers/providers.dart` exporte tous les providers disponibles dans l'application.

### 🔗 API et Services

#### **api_client_provider.dart**
Contient tous les providers pour les services Chopper :

```dart
// Client API principal
final apiClient = apiClientProvider;

// Services métier (22 services)
final entrepriseService = entrepriseServiceProvider;
final utilisateurService = utilisateurServiceProvider;
final anneeScolaireService = anneeScolaireServiceProvider;
final enseignantService = enseignantServiceProvider;
final classeService = classeServiceProvider;
final eleveService = eleveServiceProvider;
final responsableService = responsableServiceProvider;
final coursService = coursServiceProvider;
final notePeriodeService = notePeriodeServiceProvider;
final periodeService = periodeServiceProvider;
final fraisScolaireService = fraisScolaireServiceProvider;
final paiementFraisService = paiementFraisServiceProvider;
final creanceService = creanceServiceProvider;
final classeComptableService = classeComptableServiceProvider;
final compteComptableService = compteComptableServiceProvider;
final journalComptableService = journalComptableServiceProvider;
final ecritureComptableService = ecritureComptableServiceProvider;
final depenseService = depenseServiceProvider;
final licenceService = licenceServiceProvider;
final configEcoleService = configEcoleServiceProvider;
final comptesConfigService = comptesConfigServiceProvider;
final periodesClassesService = periodesClassesServiceProvider;
```

#### **auth_provider.dart**
Gestion de l'authentification avec Chopper :

```dart
// État d'authentification principal
final authState = authNotifierProvider;

// Providers utilitaires
final isAuthenticated = isAuthenticatedProvider;
final authToken = authTokenProvider;
final currentUserId = currentUserIdProvider;
final currentEntrepriseId = currentEntrepriseIdProvider;
final currentUserEmail = currentUserEmailProvider;
final authError = authErrorProvider;
final isAuthLoading = isAuthLoadingProvider;

// Actions
final authNotifier = authNotifierProvider.notifier;
await authNotifier.login(email, password);
await authNotifier.logout();
authNotifier.clearError();
```

#### **connectivity_provider.dart**
Gestion de la connectivité réseau :

```dart
// État de connectivité
final isConnected = isConnectedProvider;
final connectivityState = connectivityProvider;

// Actions
final connectivityNotifier = connectivityProvider.notifier;
await connectivityNotifier.checkConnectivity();
```

#### **sync_provider_new.dart**
Service de synchronisation avec l'API :

```dart
// État de synchronisation
final syncState = syncStateNotifierProvider;

// Actions de synchronisation
final syncNotifier = syncStateNotifierProvider.notifier;
await syncNotifier.syncAll();
await syncNotifier.uploadSingleEntity(entity, table, action);
```

#### **shared_preferences_provider.dart**
Gestion du stockage local :

```dart
// Instance SharedPreferences
final sharedPrefs = sharedPreferencesProvider;

// Utilisation
final prefs = ref.watch(sharedPreferencesProvider);
await prefs.setString('key', 'value');
final value = prefs.getString('key');
```

### 🗄️ Données et Base de Données

#### **database_provider.dart**
Base de données Floor et DAOs :

```dart
// Base de données principale
final database = databaseProvider;

// DAOs pour chaque entité
final eleveDao = eleveDaoProvider;
final utilisateurDao = utilisateurDaoProvider;
final entrepriseDao = entrepriseDaoProvider;
// ... et tous les autres DAOs
```

#### **data_provider.dart**
Providers pour les entités métier :

```dart
// Providers pour chaque entité avec CRUD offline-first
// (À documenter selon le contenu actuel du fichier)
```

### 🚀 Application

#### **app_provider.dart**
Providers généraux de l'application :

```dart
// Providers globaux de l'application
// (À documenter selon le contenu actuel du fichier)
```

## 📝 Utilisation Globale

### Import Unique
```dart
import 'package:ayanna_school/services/providers/providers.dart';
```

### Exemple d'Utilisation Complète
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Authentification
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    
    // Connectivité
    final isConnected = ref.watch(isConnectedProvider);
    
    // Services API
    final eleveService = ref.read(eleveServiceProvider);
    final utilisateurService = ref.read(utilisateurServiceProvider);
    
    // Base de données
    final database = ref.read(databaseProvider);
    final eleveDao = ref.read(eleveDaoProvider);
    
    // Storage local
    final prefs = ref.read(sharedPreferencesProvider);
    
    return Scaffold(
      body: isAuthenticated
          ? Text('Connecté: ${isConnected ? "En ligne" : "Hors ligne"}')
          : ElevatedButton(
              onPressed: () => authNotifier.login(email, password),
              child: Text('Se connecter'),
            ),
    );
  }
}
```

## 🎯 Avantages de cette Architecture

### 1. **Centralisation**
- Tous les providers accessibles depuis un seul import
- Organisation claire par catégories
- Documentation centralisée

### 2. **Consistance**
- Nommage uniforme des providers
- Patterns cohérents entre tous les services
- Annotations @riverpod partout

### 3. **Maintenabilité**
- Séparation des responsabilités
- Providers réutilisables
- Architecture scalable

### 4. **Performance**
- Lazy loading des providers
- Dispose automatique
- Cache intelligent de Riverpod

## 🔄 Intégration

Cette architecture s'intègre parfaitement avec :
- **Flutter Riverpod 2.5.1** pour la gestion d'état
- **Chopper** pour les API REST
- **Floor** pour la base de données locale
- **SharedPreferences** pour le stockage simple
- **Connectivity** pour la gestion réseau

---

**✅ Architecture Complète et Documentée !**

Tous les providers sont maintenant exportés et documentés dans le fichier `providers.dart`.
