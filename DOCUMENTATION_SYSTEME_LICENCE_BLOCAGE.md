# Système de Gestion de Licence avec Réactivation Automatique

## Vue d'ensemble

Ce système implémente un contrôle de licence qui:

1. **Bloque l'application** si la licence est expirée ou inactive
2. **Vérifie automatiquement** le statut de la licence via l'API serveur
3. **Débloque automatiquement** l'application dès que la licence est réactivée côté serveur
4. **Ne nécessite aucune interaction utilisateur** après la première tentative

## Architecture

### Composants principaux

#### 1. `LicenceValidationState` & Provider (`lib/services/licence/licence_validator.dart`)

**Provider: `licenceValidationProvider`**

- Vérifie la validité de la licence à la demande
- Retourne un `LicenceValidationState` avec:
  - `licence`: L'objet Licence trouvé (ou null)
  - `isValid`: Booléen indiquant si la licence est valide
  - `reason`: Raison de l'invalidité (si applicable)
  - `shouldBlockApp`: Indicateur pour bloquer l'application

**Logique de validation:**

```dart
// Une licence est VALIDE si:
// 1. active == true (dans la DB locale)
// 2. dateActivation <= maintenant <= dateExpiration
final isValid = (licence.active == true) && 
                now.isAfter(licence.dateActivation) && 
                now.isBefore(licence.dateExpiration);

// Si expirée mais marquée active, désactive automatiquement
if (!isWithinDates && licence.active == true) {
  await dao.desactiverLicence(licence.id!);
}
```

#### 2. `LicenceGuard` Widget (`lib/widgets/licence_guard.dart`)

Widget wrapper qui enveloppe les écrans protégés et:

- Écoute le provider `licenceValidationProvider`
- Affiche l'écran de réactivation si `shouldBlockApp == true`
- Permet l'accès normal si la licence est valide

**Utilisation:**

```dart
// Dans main.dart ou routes
'/home': (context) => LicenceGuard(
  child: PaiementDesFrais(),
),
```

#### 3. `LicenceReactivationScreen` (`lib/vues/licence_reactivation_screen.dart`)

Écran de blocage avec fonctionnalités:

**A. Affichage des informations:**

- Type de licence
- Clé de licence
- Date d'expiration
- Nombre de jours depuis expiration

**B. Vérification manuelle:**

- Bouton "Vérifier la Licence"
- Interroge l'API via `licenceService.getLicence(id)`
- Met à jour la DB locale si réactivée

**C. Polling automatique (Fonctionnalité clé):**

- Démarre automatiquement après 5 secondes
- Intervalle: toutes les 30 secondes
- Compte à rebours visible pour l'utilisateur
- Vérification silencieuse en arrière-plan
- Déblocage automatique dès détection de `active = 1`

**Flux de vérification:**

```
1. Démarrage → Attendre 5s
2. Lancer Timer(30s) + Countdown(1s)
3. Chaque 30s:
   └─> Appel API: GET /licences/{id}
       └─> Si active=1 ET dates valides:
           └─> Mettre à jour DB locale
           └─> Arrêter polling
           └─> Callback onLicenceReactivated()
           └─> Retour à l'application
       └─> Sinon:
           └─> Afficher message + countdown
           └─> Continuer polling
```

## API Utilisée

**Endpoint:** `GET /licences/{id}`

**Service Chopper:** `LicenceService` (`lib/services/api/licence_service.dart`)

**Méthodes disponibles:**

```dart
// Récupérer une licence par ID
Future<Response<Map<String, dynamic>>> getLicence(@Path() int id);

// Activer/désactiver côté serveur (admin)
Future<Response<Map<String, dynamic>>> activerLicence(@Path() int id);
Future<Response<Map<String, dynamic>>> desactiverLicence(@Path() int id);
```

## Intégration dans l'Application

### 1. Point d'entrée (`main.dart`)

```dart
import 'widgets/licence_guard.dart';

class MainApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      routes: {
        '/home': (context) => LicenceGuard(
          child: PaiementDesFrais(),
        ),
        '/paiement-frais': (context) => LicenceGuard(
          child: PaiementDesFrais(),
        ),
        // ... autres routes protégées
      },
      home: const AuthScreen(),
    );
  }
}
```

### 2. Protection des Routes

**Routes protégées (avec `LicenceGuard`):**

- `/home` - Page d'accueil
- `/paiement-frais` - Paiement des frais
- `/add-eleve` - Ajout d'élève
- Toutes les fonctionnalités métier critiques

**Routes non protégées:**

- `/login` - Écran de connexion
- Écrans de configuration initiaux

## Comportement Utilisateur

### Scénario 1: Licence Valide

1. L'utilisateur se connecte
2. `LicenceGuard` vérifie la licence
3. Licence valide → Accès normal à l'application
4. Aucun blocage

### Scénario 2: Licence Expirée

1. L'utilisateur se connecte
2. `LicenceGuard` détecte licence expirée
3. **Blocage:** Affichage de `LicenceReactivationScreen`
4. Polling automatique démarre (30s)
5. **Option A (Manuelle):**
   - Utilisateur clique "Vérifier la Licence"
   - Vérification immédiate
6. **Option B (Automatique - Recommandée):**
   - Utilisateur attend
   - Polling détecte réactivation automatiquement
   - Débloquage sans interaction
7. Une fois réactivée → Retour automatique à l'application

### Scénario 3: Réactivation par l'Administrateur

**Côté Administrateur (Serveur):**

```sql
-- Activer une licence expirée
UPDATE licence 
SET active = 1, 
    date_expiration = '2026-12-31'
WHERE id = 123;
```

**Côté Application Mobile:**

- Polling détecte changement (max 30s de délai)
- DB locale mise à jour automatiquement
- Application débloquée sans redémarrage
- L'utilisateur peut continuer immédiatement

## Configuration et Personnalisation

### Modifier l'intervalle de polling

Dans `LicenceReactivationScreen`:

```dart
// Ligne 25
static const int _pollingIntervalSeconds = 30; // Changer ici
```

**Recommandations:**

- Minimum: 10 secondes (éviter surcharge serveur)
- Défaut: 30 secondes (bon équilibre)
- Maximum: 60 secondes (si trafic élevé)

### Modifier le délai avant démarrage automatique

Dans `LicenceReactivationScreen.initState()`:

```dart
// Ligne 42
Future.delayed(const Duration(seconds: 5), () { // Changer ici
  if (mounted) {
    _startPolling();
  }
});
```

### Désactiver le polling automatique

Si vous voulez forcer la vérification manuelle uniquement:

```dart
// Dans initState(), commenter:
// Future.delayed(const Duration(seconds: 5), () {
//   if (mounted) {
//     _startPolling();
//   }
// });
```

## Base de Données Locale

### Table: `licence`

**Colonnes importantes:**

- `id` (INTEGER PRIMARY KEY)
- `server_id` (INTEGER) - ID côté serveur
- `active` (INTEGER) - 0 ou 1
- `date_activation` (INTEGER - timestamp)
- `date_expiration` (INTEGER - timestamp)
- `cle` (TEXT) - Clé de licence
- `type` (TEXT) - Type de licence
- `entreprise_id` (INTEGER) - FK vers entreprises

**DAO: `LicenceDao`**

Méthodes utilisées:

```dart
// Récupérer licences par entreprise
Future<List<Licence>> getLicencesByEntreprise(int entrepriseId);

// Activer/désactiver localement
Future<void> activerLicence(int id);
Future<void> desactiverLicence(int id);

// Mettre à jour
Future<void> updateLicence(Licence licence);
```

## Gestion des Erreurs

### Erreur de connexion API

**Comportement:**

- Message: "Erreur de connexion. Nouvelle tentative dans X s..."
- Le polling continue automatiquement
- L'utilisateur peut réessayer manuellement

### Licence introuvable

**Comportement:**

- Affichage du message d'erreur
- Possibilité de vérifier manuellement
- Le polling peut continuer (si activé)

### Erreur base de données

**Comportement:**

- Provider retourne `LicenceValidationState.error()`
- Widget affiche écran d'erreur
- L'utilisateur doit redémarrer l'application

## Tests et Débogage

### Tester le blocage

1. **Désactiver manuellement une licence:**

```dart
final dao = ref.read(licenceDaoProvider);
await dao.desactiverLicence(licenceId);
```

2. **Expirer une licence:**

```dart
final dao = ref.read(licenceDaoProvider);
final licence = await dao.getLicenceById(id);
final expired = licence.copyWith(
  dateExpiration: DateTime.now().subtract(Duration(days: 1)),
);
await dao.updateLicence(expired);
```

3. **Redémarrer l'application:**

```bash
flutter run
```

### Tester la réactivation

1. **Côté Serveur (API/DB):**

```sql
UPDATE licence SET active = 1 WHERE id = X;
```

2. **Observer:**

- Countdown visible (30s)
- Message "Vérification automatique active"
- Débloquage automatique après détection

### Logs de débogage

Dans `LicenceReactivationScreen`:

```dart
// Ajouter des prints pour suivre le polling
print('🔍 Polling: Vérification de la licence $serverId');
print('✅ Licence réactivée! active=${updatedLicence.active}');
print('❌ Toujours inactive, retry dans ${_secondsUntilNextCheck}s');
```

## Considérations de Performance

### Impact réseau

- **Polling 30s:** ~120 requêtes/heure par utilisateur bloqué
- **Taille requête:** ~1KB (GET /licences/{id})
- **Réponse:** ~2KB (JSON licence)

**Recommandation:** Acceptable pour <100 utilisateurs bloqués simultanément

### Impact batterie (Mobile)

- Timer léger (1s countdown)
- Requête réseau toutes les 30s
- **Impact:** Négligeable (<1% batterie/heure)

### Optimisations possibles

1. **Polling adaptatif:**

```dart
// Augmenter l'intervalle après X tentatives
if (_attemptCount > 5) {
  _pollingIntervalSeconds = 60; // Passer à 1 minute
}
```

2. **WebSocket (Avancé):**

```dart
// Remplacer polling par push notification
final socket = io('https://api.example.com');
socket.on('licence:activated', (data) {
  if (data['licenceId'] == widget.licence.id) {
    _onLicenceReactivated();
  }
});
```

## Sécurité

### Points de sécurité implémentés

1. **Vérification double:**
   - API serveur (source de vérité)
   - DB locale (cache + performance)

2. **Désactivation automatique:**
   - Licence expirée = `active` forcé à 0 en local

3. **Pas de bypass:**
   - Le `LicenceGuard` bloque toutes les routes protégées
   - Pas de navigation manuelle possible

### Améliorations de sécurité recommandées

1. **Signature de licence:**

```dart
// Vérifier la signature lors de la mise à jour
final isSignatureValid = _verifySignature(
  updatedLicence.cle,
  updatedLicence.signature,
  serverPublicKey,
);
if (!isSignatureValid) {
  throw Exception('Signature invalide');
}
```

2. **Token d'authentification:**

```dart
// Toujours vérifier que l'utilisateur est authentifié
final authState = ref.read(authStateProvider);
if (!authState.isAuthenticated) {
  throw Exception('Non authentifié');
}
```

## Support et Maintenance

### Mises à jour futures

**Version actuelle:** 1.0.0

**Roadmap:**

- [ ] Polling adaptatif (v1.1)
- [ ] Notifications push pour réactivation (v1.2)
- [ ] Cache de licences multiples (v1.3)
- [ ] Mode hors ligne gracieux (v1.4)

### Bugs connus

Aucun bug critique connu à ce jour.

### Contact

Pour toute question ou amélioration, contacter l'équipe de développement.

---

**Dernière mise à jour:** 23 octobre 2025  
**Auteur:** Ayanna School Development Team
