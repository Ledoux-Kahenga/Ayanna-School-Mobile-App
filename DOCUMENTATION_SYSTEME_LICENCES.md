# 📜 Système de Gestion des Licences - Ayanna School

**Date:** 15 octobre 2025  
**Application:** Ayanna School Mobile  
**Objectif:** Documentation complète du système de licences

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Structure de la base de données](#structure-de-la-base-de-données)
3. [Fonctionnalités disponibles](#fonctionnalités-disponibles)
4. [Implémentation](#implémentation)
5. [Validation de licence](#validation-de-licence)
6. [Gestion des expirations](#gestion-des-expirations)
7. [Interface utilisateur](#interface-utilisateur)
8. [Sécurité](#sécurité)
9. [Tests](#tests)

---

## 🎯 Vue d'Ensemble

### Qu'est-ce qu'une Licence ?

Une licence dans Ayanna School est un **système de contrôle d'accès** qui permet de :

- ✅ Autoriser l'utilisation de l'application pour une entreprise
- ⏱️ Définir une période de validité (date d'activation et d'expiration)
- 🔐 Protéger l'application contre l'utilisation non autorisée
- 💼 Gérer différents types de licences (gratuit, standard, premium, etc.)
- 🔑 Vérifier l'authenticité via une signature

---

## 🗄️ Structure de la Base de Données

### Table `licence`

```sql
CREATE TABLE licence (
    id INTEGER PRIMARY KEY,
    server_id INTEGER UNIQUE,
    is_sync BOOLEAN DEFAULT 1,
    cle TEXT NOT NULL,
    type TEXT NOT NULL,
    date_activation DATETIME NOT NULL,
    date_expiration DATETIME NOT NULL,
    signature TEXT NOT NULL,
    actif BOOLEAN,
    entreprise_id INTEGER,
    date_creation DATETIME NOT NULL,
    date_modification DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    FOREIGN KEY (entreprise_id) REFERENCES entreprise(id)
);
```

### Champs de la Table

| Champ | Type | Description | Obligatoire |
|-------|------|-------------|-------------|
| `id` | INTEGER | ID local de la licence | ✅ (auto) |
| `server_id` | INTEGER | ID serveur (unique) | ⚪ |
| `is_sync` | BOOLEAN | État de synchronisation | ✅ |
| `cle` | TEXT | Clé de licence unique | ✅ |
| `type` | TEXT | Type de licence | ✅ |
| `date_activation` | DATETIME | Date de début | ✅ |
| `date_expiration` | DATETIME | Date de fin | ✅ |
| `signature` | TEXT | Signature de sécurité | ✅ |
| `actif` | BOOLEAN | Licence active/inactive | ⚪ |
| `entreprise_id` | INTEGER | ID de l'entreprise | ⚪ |
| `date_creation` | DATETIME | Date de création | ✅ |
| `date_modification` | DATETIME | Date de modification | ✅ |
| `updated_at` | DATETIME | Dernière mise à jour | ✅ |

### Types de Licences Possibles

```dart
enum TypeLicence {
  GRATUIT,      // Licence gratuite (limitée)
  ESSAI,        // Période d'essai (30 jours)
  STANDARD,     // Licence standard (1 an)
  PREMIUM,      // Licence premium (illimitée)
  ENTREPRISE,   // Licence entreprise (multiple écoles)
  EDUCATION,    // Licence éducation (réduction)
}
```

---

## ⚙️ Fonctionnalités Disponibles

### DAO (Data Access Object)

Le `LicenceDao` fournit les méthodes suivantes :

#### 1. Récupération des Licences

```dart
// Toutes les licences
Future<List<Licence>> getAllLicences()

// Par ID
Future<Licence?> getLicenceById(int id)
Future<Licence?> getLicenceByServerId(int serverId)

// Par clé
Future<Licence?> getLicenceByCle(String cle)

// Par entreprise
Future<List<Licence>> getLicencesByEntreprise(int entrepriseId)

// Par type
Future<List<Licence>> getLicencesByType(String type, int entrepriseId)

// Licences actives
Future<List<Licence>> getLicencesActives(int entrepriseId)

// Licences valides (non expirées)
Future<List<Licence>> getLicencesValides(DateTime date)

// Licences expirées
Future<List<Licence>> getLicencesExpirees(DateTime date)
```

#### 2. Gestion des Licences

```dart
// Insertion
Future<int> insertLicence(Licence licence)
Future<List<int>> insertLicences(List<Licence> licences)

// Mise à jour
Future<void> updateLicence(Licence licence)
Future<void> updateLicences(List<Licence> licences)

// Suppression
Future<void> deleteLicence(Licence licence)
Future<void> deleteAllLicences()
Future<void> deleteLicencesByEntreprise(int entrepriseId)
```

#### 3. Actions Spécifiques

```dart
// Activation/Désactivation
Future<void> activerLicence(int id)
Future<void> desactiverLicence(int id)

// Synchronisation
Future<void> markAsSynced(int id)
Future<void> updateServerIdAndSync(int id, int serverId)
Future<List<Licence>> getUnsyncedLicences()
```

### API (Service REST)

Le `LicenceService` fournit les endpoints suivants :

```dart
// Récupération
GET /licences
GET /licences/{id}
GET /licences/by-cle/{cle}
GET /licences/by-entreprise/{entrepriseId}
GET /licences/by-type/{type}
GET /licences/actives
GET /licences/expirees
GET /licences/bientot-expirees?jours=30

// Gestion
POST /licences
PUT /licences/{id}
DELETE /licences/{id}

// Actions
PUT /licences/{id}/activer
PUT /licences/{id}/desactiver
PUT /licences/{id}/renouveler
GET /licences/valider/{cle}
POST /licences/sync
```

---

## 🔨 Implémentation

### 1. Service de Gestion de Licence

Créez un fichier `lib/services/licence_manager.dart` :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/entities/licence.dart';
import '../models/dao/licence_dao.dart';
import 'providers/database_provider.dart';

/// Provider pour le gestionnaire de licences
final licenceManagerProvider = Provider<LicenceManager>((ref) {
  final dao = ref.watch(licenceDaoProvider);
  return LicenceManager(dao);
});

class LicenceManager {
  final LicenceDao _dao;

  LicenceManager(this._dao);

  /// Vérifier si une licence est valide
  Future<LicenceValidationResult> verifierLicence(int entrepriseId) async {
    try {
      // Récupérer la licence active de l'entreprise
      final licences = await _dao.getLicencesActives(entrepriseId);
      
      if (licences.isEmpty) {
        return LicenceValidationResult(
          valide: false,
          message: 'Aucune licence trouvée pour cette entreprise',
          raison: RaisonInvalidite.LICENCE_INTROUVABLE,
        );
      }

      final licence = licences.first;
      final maintenant = DateTime.now();

      // Vérifier l'activation
      if (maintenant.isBefore(licence.dateActivation)) {
        return LicenceValidationResult(
          valide: false,
          message: 'La licence n\'est pas encore active',
          raison: RaisonInvalidite.PAS_ENCORE_ACTIVE,
          dateActivation: licence.dateActivation,
        );
      }

      // Vérifier l'expiration
      if (maintenant.isAfter(licence.dateExpiration)) {
        return LicenceValidationResult(
          valide: false,
          message: 'La licence a expiré',
          raison: RaisonInvalidite.LICENCE_EXPIREE,
          dateExpiration: licence.dateExpiration,
        );
      }

      // Vérifier la signature
      if (!_verifierSignature(licence)) {
        return LicenceValidationResult(
          valide: false,
          message: 'Signature de licence invalide',
          raison: RaisonInvalidite.SIGNATURE_INVALIDE,
        );
      }

      // Vérifier si elle va bientôt expirer (30 jours)
      final joursRestants = licence.dateExpiration.difference(maintenant).inDays;
      final bientotExpiree = joursRestants <= 30;

      return LicenceValidationResult(
        valide: true,
        message: 'Licence valide',
        licence: licence,
        joursRestants: joursRestants,
        bientotExpiree: bientotExpiree,
      );
    } catch (e) {
      return LicenceValidationResult(
        valide: false,
        message: 'Erreur lors de la vérification: $e',
        raison: RaisonInvalidite.ERREUR_VERIFICATION,
      );
    }
  }

  /// Vérifier la signature de la licence
  bool _verifierSignature(Licence licence) {
    // Générer la signature attendue
    final donnees = '${licence.cle}:${licence.entrepriseId}:'
        '${licence.dateActivation.toIso8601String()}:'
        '${licence.dateExpiration.toIso8601String()}';
    
    final bytes = utf8.encode(donnees);
    final hash = sha256.convert(bytes);
    final signatureAttendue = hash.toString();

    return licence.signature == signatureAttendue;
  }

  /// Générer une signature pour une nouvelle licence
  String genererSignature(String cle, int entrepriseId, 
      DateTime dateActivation, DateTime dateExpiration) {
    final donnees = '$cle:$entrepriseId:'
        '${dateActivation.toIso8601String()}:'
        '${dateExpiration.toIso8601String()}';
    
    final bytes = utf8.encode(donnees);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Créer une nouvelle licence
  Future<Licence> creerLicence({
    required String type,
    required int entrepriseId,
    required DateTime dateActivation,
    required DateTime dateExpiration,
  }) async {
    // Générer une clé unique
    final cle = _genererCleLicence();
    
    // Générer la signature
    final signature = genererSignature(
      cle,
      entrepriseId,
      dateActivation,
      dateExpiration,
    );

    final maintenant = DateTime.now();
    final licence = Licence(
      cle: cle,
      type: type,
      dateActivation: dateActivation,
      dateExpiration: dateExpiration,
      signature: signature,
      active: true,
      entrepriseId: entrepriseId,
      dateCreation: maintenant,
      dateModification: maintenant,
      updatedAt: maintenant,
      isSync: false,
    );

    await _dao.insertLicence(licence);
    return licence;
  }

  /// Générer une clé de licence unique
  String _genererCleLicence() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    final donnees = '$timestamp:$random';
    final bytes = utf8.encode(donnees);
    final hash = sha256.convert(bytes);
    
    // Format: XXXX-XXXX-XXXX-XXXX
    final cle = hash.toString().substring(0, 16).toUpperCase();
    return '${cle.substring(0, 4)}-${cle.substring(4, 8)}-'
           '${cle.substring(8, 12)}-${cle.substring(12, 16)}';
  }

  /// Renouveler une licence
  Future<Licence> renouvelerLicence(Licence licence, int dureeJours) async {
    final nouvelleExpiration = licence.dateExpiration.add(
      Duration(days: dureeJours),
    );

    // Générer une nouvelle signature
    final nouvelleSignature = genererSignature(
      licence.cle,
      licence.entrepriseId!,
      licence.dateActivation,
      nouvelleExpiration,
    );

    final licenceRenouvelee = licence.copyWith(
      dateExpiration: nouvelleExpiration,
      signature: nouvelleSignature,
      dateModification: DateTime.now(),
      updatedAt: DateTime.now(),
      isSync: false,
    );

    await _dao.updateLicence(licenceRenouvelee);
    return licenceRenouvelee;
  }

  /// Activer une licence
  Future<void> activerLicence(int licenceId) async {
    await _dao.activerLicence(licenceId);
  }

  /// Désactiver une licence
  Future<void> desactiverLicence(int licenceId) async {
    await _dao.desactiverLicence(licenceId);
  }

  /// Obtenir les licences bientôt expirées (< 30 jours)
  Future<List<Licence>> getLicencesBientotExpirees() async {
    final maintenant = DateTime.now();
    final dans30Jours = maintenant.add(const Duration(days: 30));
    
    final toutesLicences = await _dao.getLicencesValides(maintenant);
    
    return toutesLicences.where((licence) => 
      licence.dateExpiration.isBefore(dans30Jours)
    ).toList();
  }
}

/// Résultat de validation de licence
class LicenceValidationResult {
  final bool valide;
  final String message;
  final Licence? licence;
  final RaisonInvalidite? raison;
  final int? joursRestants;
  final bool bientotExpiree;
  final DateTime? dateActivation;
  final DateTime? dateExpiration;

  LicenceValidationResult({
    required this.valide,
    required this.message,
    this.licence,
    this.raison,
    this.joursRestants,
    this.bientotExpiree = false,
    this.dateActivation,
    this.dateExpiration,
  });
}

/// Raisons d'invalidité de licence
enum RaisonInvalidite {
  LICENCE_INTROUVABLE,
  PAS_ENCORE_ACTIVE,
  LICENCE_EXPIREE,
  SIGNATURE_INVALIDE,
  ERREUR_VERIFICATION,
}
```

### 2. Widget de Statut de Licence

Créez `lib/vues/widgets/licence_status_widget.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/licence_manager.dart';
import '../../services/providers/providers.dart';
import '../../theme/ayanna_theme.dart';

class LicenceStatusWidget extends ConsumerWidget {
  const LicenceStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entreprises = ref.watch(entreprisesNotifierProvider);

    return entreprises.when(
      data: (entreprisesList) {
        if (entreprisesList.isEmpty) {
          return const SizedBox.shrink();
        }

        final entreprise = entreprisesList.first;
        final licenceManager = ref.watch(licenceManagerProvider);

        return FutureBuilder<LicenceValidationResult>(
          future: licenceManager.verifierLicence(entreprise.id!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final resultat = snapshot.data!;

            if (!resultat.valide) {
              return _buildInvalidLicenceBanner(context, resultat);
            }

            if (resultat.bientotExpiree) {
              return _buildExpirationWarning(context, resultat);
            }

            return const SizedBox.shrink();
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildInvalidLicenceBanner(
    BuildContext context,
    LicenceValidationResult resultat,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.red.shade100,
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Licence invalide',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                Text(
                  resultat.message,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Ouvrir l'écran de gestion des licences
              Navigator.pushNamed(context, '/licence');
            },
            child: const Text('Renouveler'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpirationWarning(
    BuildContext context,
    LicenceValidationResult resultat,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Votre licence expire dans ${resultat.joursRestants} jours',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/licence');
            },
            child: const Text('Renouveler'),
          ),
        ],
      ),
    );
  }
}
```

### 3. Écran de Gestion des Licences

Créez `lib/vues/licence/licence_screen.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/licence_manager.dart';
import '../../services/providers/providers.dart';
import '../../theme/ayanna_theme.dart';

class LicenceScreen extends ConsumerStatefulWidget {
  const LicenceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LicenceScreen> createState() => _LicenceScreenState();
}

class _LicenceScreenState extends ConsumerState<LicenceScreen> {
  LicenceValidationResult? _resultatValidation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _chargerLicence();
  }

  Future<void> _chargerLicence() async {
    setState(() => _loading = true);

    final entreprises = await ref.read(entreprisesNotifierProvider.future);
    if (entreprises.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    final entreprise = entreprises.first;
    final licenceManager = ref.read(licenceManagerProvider);
    final resultat = await licenceManager.verifierLicence(entreprise.id!);

    setState(() {
      _resultatValidation = resultat;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de Licence'),
        backgroundColor: AyannaColors.orange,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_resultatValidation == null) {
      return const Center(
        child: Text('Aucune information de licence disponible'),
      );
    }

    final resultat = _resultatValidation!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatutCard(resultat),
          const SizedBox(height: 20),
          if (resultat.valide) ...[
            _buildDetailsCard(resultat.licence!),
            const SizedBox(height: 20),
          ],
          _buildActionsCard(resultat),
        ],
      ),
    );
  }

  Widget _buildStatutCard(LicenceValidationResult resultat) {
    final Color couleur = resultat.valide ? Colors.green : Colors.red;
    final IconData icone = resultat.valide ? Icons.check_circle : Icons.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icone, size: 64, color: couleur),
            const SizedBox(height: 12),
            Text(
              resultat.valide ? 'Licence Valide' : 'Licence Invalide',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: couleur,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              resultat.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (resultat.joursRestants != null) ...[
              const SizedBox(height: 12),
              Text(
                '${resultat.joursRestants} jours restants',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: resultat.bientotExpiree ? Colors.orange : Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Licence licence) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détails de la Licence',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildDetailRow('Clé', licence.cle),
            _buildDetailRow('Type', licence.type.toUpperCase()),
            _buildDetailRow(
              'Date d\'activation',
              DateFormat('dd/MM/yyyy').format(licence.dateActivation),
            ),
            _buildDetailRow(
              'Date d\'expiration',
              DateFormat('dd/MM/yyyy').format(licence.dateExpiration),
            ),
            _buildDetailRow(
              'Statut',
              licence.active == true ? 'Active' : 'Inactive',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(valeur),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(LicenceValidationResult resultat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            if (!resultat.valide || resultat.bientotExpiree) ...[
              ElevatedButton.icon(
                onPressed: _renouvelerLicence,
                icon: const Icon(Icons.refresh),
                label: const Text('Renouveler la Licence'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AyannaColors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton.icon(
              onPressed: _contacterSupport,
              icon: const Icon(Icons.support_agent),
              label: const Text('Contacter le Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _chargerLicence,
              icon: const Icon(Icons.refresh),
              label: const Text('Rafraîchir'),
            ),
          ],
        ),
      ),
    );
  }

  void _renouvelerLicence() {
    // Implémenter la logique de renouvellement
    // (Rediriger vers formulaire de paiement ou contact support)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renouvellement de Licence'),
        content: const Text(
          'Pour renouveler votre licence, veuillez contacter notre support '
          'ou effectuer un paiement en ligne.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _contacterSupport();
            },
            child: const Text('Contacter'),
          ),
        ],
      ),
    );
  }

  void _contacterSupport() {
    // Implémenter la logique de contact support
    // (Email, téléphone, chat, etc.)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Support Ayanna School'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📧 Email: support@ayannaschool.com'),
            SizedBox(height: 8),
            Text('📞 Téléphone: +243 XX XXX XXXX'),
            SizedBox(height: 8),
            Text('🌐 Web: www.ayannaschool.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔐 Validation de Licence

### Quand Vérifier la Licence ?

1. **Au démarrage de l'application**

   ```dart
   // Dans main.dart ou auth_screen.dart
   Future<void> _verifierLicenceAuDemarrage() async {
     final entreprises = await ref.read(entreprisesNotifierProvider.future);
     if (entreprises.isEmpty) return;
     
     final entreprise = entreprises.first;
     final licenceManager = ref.read(licenceManagerProvider);
     final resultat = await licenceManager.verifierLicence(entreprise.id!);
     
     if (!resultat.valide) {
       // Afficher un avertissement ou bloquer l'application
       _afficherAlerteLicence(resultat);
     }
   }
   ```

2. **Périodiquement pendant l'utilisation**

   ```dart
   // Vérifier toutes les heures
   Timer.periodic(const Duration(hours: 1), (timer) async {
     await _verifierLicence();
   });
   ```

3. **Lors de certaines actions critiques**
   - Avant la synchronisation
   - Avant l'ajout de nouvelles données
   - Avant l'accès à des fonctionnalités premium

### Stratégies de Blocage

#### 1. Mode Lecture Seule

```dart
if (!resultatLicence.valide) {
  // Permettre la lecture mais bloquer les modifications
  return Scaffold(
    appBar: AppBar(
      title: const Text('Mode Lecture Seule'),
      backgroundColor: Colors.orange,
    ),
    body: Column(
      children: [
        LicenceStatusWidget(), // Affiche l'avertissement
        // Contenu en lecture seule
      ],
    ),
  );
}
```

#### 2. Blocage Complet

```dart
if (!resultatLicence.valide) {
  return LicenceExpiredScreen(); // Écran de blocage complet
}
```

#### 3. Période de Grâce

```dart
// Permettre l'utilisation 7 jours après expiration
if (resultatLicence.raison == RaisonInvalidite.LICENCE_EXPIREE) {
  final joursDepuisExpiration = DateTime.now()
      .difference(resultatLicence.dateExpiration!)
      .inDays;
  
  if (joursDepuisExpiration <= 7) {
    // Mode dégradé avec avertissements
    return AppWithWarnings();
  } else {
    // Blocage complet
    return LicenceExpiredScreen();
  }
}
```

---

## ⏱️ Gestion des Expirations

### Notifications d'Expiration

Créez `lib/services/licence_notification_service.dart` :

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/entities/licence.dart';

class LicenceNotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialiser() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notifications.initialize(initializationSettings);
  }

  Future<void> notifierExpirationProche(Licence licence) async {
    final joursRestants = licence.dateExpiration.difference(DateTime.now()).inDays;
    
    if (joursRestants <= 30 && joursRestants > 0) {
      await _notifications.show(
        0,
        'Licence Expiration Proche',
        'Votre licence expire dans $joursRestants jours. Renouvelez maintenant!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'licence_channel',
            'Notifications de Licence',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  Future<void> notifierLicenceExpiree() async {
    await _notifications.show(
      1,
      'Licence Expirée',
      'Votre licence a expiré. Veuillez la renouveler pour continuer à utiliser Ayanna School.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'licence_channel',
          'Notifications de Licence',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
    );
  }
}
```

### Vérification Automatique en Arrière-Plan

```dart
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'verifierLicence') {
      // Vérifier la licence
      // Envoyer notification si nécessaire
    }
    return Future.value(true);
  });
}

void initialiserVerificationLicence() {
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // Vérifier quotidiennement
  Workmanager().registerPeriodicTask(
    'verificationLicence',
    'verifierLicence',
    frequency: const Duration(hours: 24),
  );
}
```

---

## 🎨 Interface Utilisateur

### 1. Badge de Statut dans l'AppBar

```dart
AppBar(
  title: const Text('Ayanna School'),
  actions: [
    Consumer(
      builder: (context, ref, child) {
        final entreprises = ref.watch(entreprisesNotifierProvider);
        return entreprises.when(
          data: (entreprisesList) {
            if (entreprisesList.isEmpty) return const SizedBox.shrink();
            
            final entreprise = entreprisesList.first;
            final licenceManager = ref.watch(licenceManagerProvider);
            
            return FutureBuilder<LicenceValidationResult>(
              future: licenceManager.verifierLicence(entreprise.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                
                final resultat = snapshot.data!;
                final Color couleur = resultat.valide 
                    ? Colors.green 
                    : Colors.red;
                
                return IconButton(
                  icon: Icon(Icons.verified, color: couleur),
                  onPressed: () {
                    Navigator.pushNamed(context, '/licence');
                  },
                  tooltip: resultat.message,
                );
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    ),
  ],
)
```

### 2. Page d'Accueil avec Statut

```dart
// Dans la page d'accueil
Column(
  children: [
    LicenceStatusWidget(), // Banner en haut
    // Reste du contenu
  ],
)
```

---

## 🔒 Sécurité

### Bonnes Pratiques

1. **Ne jamais stocker la clé de génération de signature dans l'app**
   - Utiliser un serveur pour générer les licences
   - La clé secrète reste sur le serveur

2. **Vérifier la signature côté serveur également**

   ```dart
   // API: POST /licences/valider/{cle}
   // Retourne true/false après vérification serveur
   ```

3. **Chiffrer les données sensibles**

   ```dart
   import 'package:encrypt/encrypt.dart';
   
   // Chiffrer la clé de licence avant stockage
   String chiffrerCle(String cle) {
     final key = Key.fromUtf8('ma_cle_secrete_32_caracteres_!');
     final iv = IV.fromLength(16);
     final encrypter = Encrypter(AES(key));
     return encrypter.encrypt(cle, iv: iv).base64;
   }
   ```

4. **Limiter les tentatives de validation**

   ```dart
   int _nombreTentatives = 0;
   final int _maxTentatives = 5;
   
   Future<bool> validerLicenceAvecLimite(String cle) async {
     if (_nombreTentatives >= _maxTentatives) {
       throw Exception('Trop de tentatives de validation');
     }
     _nombreTentatives++;
     // Validation...
   }
   ```

5. **Logs d'audit**

   ```dart
   Future<void> loggerValidation(bool succes, String raison) async {
     await _dao.logAction(
       type: 'validation_licence',
       succes: succes,
       raison: raison,
       timestamp: DateTime.now(),
     );
   }
   ```

---

## 🧪 Tests

### Tests Unitaires

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LicenceManager', () {
    test('Validation licence valide', () async {
      final licence = Licence(
        cle: 'TEST-1234-5678-ABCD',
        type: 'STANDARD',
        dateActivation: DateTime.now().subtract(Duration(days: 10)),
        dateExpiration: DateTime.now().add(Duration(days: 350)),
        signature: 'signature_valide',
        active: true,
        entrepriseId: 1,
        dateCreation: DateTime.now(),
        dateModification: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Insérer dans la base de test
      await dao.insertLicence(licence);
      
      final resultat = await manager.verifierLicence(1);
      expect(resultat.valide, true);
    });

    test('Validation licence expirée', () async {
      final licence = Licence(
        cle: 'TEST-1234-5678-ABCD',
        type: 'STANDARD',
        dateActivation: DateTime.now().subtract(Duration(days: 400)),
        dateExpiration: DateTime.now().subtract(Duration(days: 10)),
        signature: 'signature_valide',
        active: true,
        entrepriseId: 1,
        dateCreation: DateTime.now(),
        dateModification: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await dao.insertLicence(licence);
      
      final resultat = await manager.verifierLicence(1);
      expect(resultat.valide, false);
      expect(resultat.raison, RaisonInvalidite.LICENCE_EXPIREE);
    });
  });
}
```

---

## ✅ Checklist d'Implémentation

### Phase 1: Infrastructure de Base

- [ ] Créer `licence_manager.dart`
- [ ] Ajouter dépendances (`crypto`, `encrypt`)
- [ ] Tester la génération de clés et signatures

### Phase 2: Interface Utilisateur

- [ ] Créer `licence_status_widget.dart`
- [ ] Créer `licence_screen.dart`
- [ ] Ajouter la route `/licence`
- [ ] Intégrer dans l'AppBar et pages principales

### Phase 3: Validation

- [ ] Implémenter la vérification au démarrage
- [ ] Ajouter la vérification périodique
- [ ] Gérer les cas d'expiration

### Phase 4: Notifications

- [ ] Configurer `flutter_local_notifications`
- [ ] Implémenter `licence_notification_service.dart`
- [ ] Tester les notifications

### Phase 5: API

- [ ] Implémenter les endpoints serveur
- [ ] Sécuriser la génération de licences
- [ ] Tester la synchronisation

### Phase 6: Sécurité

- [ ] Chiffrement des données sensibles
- [ ] Vérification double (client + serveur)
- [ ] Logs d'audit

### Phase 7: Tests

- [ ] Tests unitaires
- [ ] Tests d'intégration
- [ ] Tests de sécurité

---

## 📚 Dépendances Nécessaires

Ajoutez dans `pubspec.yaml` :

```yaml
dependencies:
  crypto: ^3.0.3
  encrypt: ^5.0.3
  flutter_local_notifications: ^16.3.0
  workmanager: ^0.5.2
```

---

## 📝 Exemple d'Utilisation Complète

```dart
// 1. Créer une licence
final manager = ref.read(licenceManagerProvider);
final licence = await manager.creerLicence(
  type: 'STANDARD',
  entrepriseId: 1,
  dateActivation: DateTime.now(),
  dateExpiration: DateTime.now().add(Duration(days: 365)),
);

print('Licence créée: ${licence.cle}');

// 2. Vérifier la licence
final resultat = await manager.verifierLicence(1);
if (resultat.valide) {
  print('✅ Licence valide pour ${resultat.joursRestants} jours');
} else {
  print('❌ Licence invalide: ${resultat.message}');
}

// 3. Renouveler la licence
if (resultat.bientotExpiree) {
  final licenceRenouvelee = await manager.renouvelerLicence(
    resultat.licence!,
    365, // 365 jours supplémentaires
  );
  print('Licence renouvelée jusqu\'au ${licenceRenouvelee.dateExpiration}');
}
```

---

## 🎉 Conclusion

Ce système de licences vous permet de :

- ✅ Contrôler l'accès à votre application
- ⏱️ Gérer les périodes d'essai et d'abonnement
- 💰 Monétiser votre application
- 🔐 Sécuriser votre code contre l'utilisation non autorisée
- 📊 Suivre l'utilisation et les renouvellements

**Next Steps:**

1. Implémenter le `LicenceManager`
2. Créer l'interface utilisateur
3. Intégrer dans le flux d'authentification
4. Tester en conditions réelles
5. Documenter pour les utilisateurs finaux

---

**Documentation créée le 15 octobre 2025**  
**Ayanna School - Système de Gestion Scolaire**
