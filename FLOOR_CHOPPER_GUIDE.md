# Intégration Floor et Chopper - Documentation

## Vue d'ensemble

Ce projet utilise **Floor** pour la base de données locale et **Chopper** pour les appels API. Chaque entité dispose de colonnes `server_id` et `is_sync` pour gérer la synchronisation.

## Architecture

### 1. Entités (Models)
- Toutes les entités héritent de la structure de base avec :
  - `id` : Clé primaire locale
  - `server_id` : ID sur le serveur distant
  - `is_sync` : Indicateur de synchronisation
  - Colonnes métier spécifiques
  - `date_creation`, `date_modification`, `updated_at`

### 2. Base de données locale (Floor)
- **AppDatabase** : Base de données principale
- **DAOs** : Interface d'accès aux données
- **Convertisseurs** : Conversion DateTime <-> int

### 3. API (Chopper)
- **Services API** : Définition des endpoints
- **Client API** : Configuration centralisée
- **Intercepteurs** : Authentification, logging

### 4. Synchronisation
- **SyncService** : Logique de synchronisation bidirectionnelle
- Upload des données locales non synchronisées
- Download et mise à jour depuis le serveur

## Utilisation

### 1. Installation des dépendances

```bash
flutter pub get
```

### 2. Génération du code

```bash
dart run build_runner build
```

### 3. Initialisation dans main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final database = await AppDatabase.create();
  final apiClient = ApiClient();
  final syncService = SyncService(database, apiClient);
  
  runApp(MyApp());
}
```

### 4. Utilisation avec Provider

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => EntrepriseService()..initialize()),
  ],
  child: MyApp(),
)
```

### 5. Dans les widgets

```dart
Consumer<EntrepriseService>(
  builder: (context, service, child) {
    if (service.isLoading) {
      return CircularProgressIndicator();
    }
    
    return ListView.builder(
      itemCount: service.entreprises.length,
      itemBuilder: (context, index) {
        final entreprise = service.entreprises[index];
        return ListTile(
          title: Text(entreprise.nom),
          subtitle: Text(entreprise.email ?? ''),
          trailing: entreprise.isSync 
            ? Icon(Icons.cloud_done, color: Colors.green)
            : Icon(Icons.cloud_off, color: Colors.orange),
        );
      },
    );
  },
)
```

## Structure des fichiers

```
lib/
├── models/
│   ├── entities/           # Entités Floor
│   │   ├── entreprise.dart
│   │   ├── utilisateur.dart
│   │   └── ...
│   ├── dao/               # Data Access Objects
│   │   ├── entreprise_dao.dart
│   │   └── ...
│   ├── converters/        # Convertisseurs de types
│   │   └── datetime_converter.dart
│   └── app_database.dart  # Configuration DB
├── services/
│   ├── api/              # Services Chopper
│   │   ├── api_client.dart
│   │   ├── entreprise_service.dart
│   │   └── ...
│   ├── sync_service.dart # Synchronisation
│   └── entreprise_service.dart # Service métier
└── ...
```

## Commandes utiles

### Générer le code
```bash
dart run build_runner build
```

### Nettoyer et régénérer
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Watch mode (développement)
```bash
dart run build_runner watch
```

## Configuration API

Modifiez `lib/services/api/api_client.dart` pour configurer l'URL de base de votre API :

```dart
static const String baseUrl = 'https://votre-api.com/api';
```

## Sécurité

L'authentification est gérée via l'intercepteur `AuthInterceptor`. Implémentez la méthode `_getAuthToken()` selon votre système d'authentification.

## Synchronisation

La synchronisation est bidirectionnelle :
1. **Upload** : Envoie les données locales non synchronisées vers le serveur
2. **Download** : Récupère et met à jour depuis le serveur
3. **Gestion des conflits** : Les données serveur ont priorité

## Gestion hors-ligne

L'application fonctionne entièrement hors-ligne. La synchronisation se fait automatiquement lors de la connexion au réseau.
