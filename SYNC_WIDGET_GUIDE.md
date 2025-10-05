# Widget de Synchronisation - Guide d'utilisation

## 📋 Vue d'ensemble

Trois nouveaux composants ont été créés pour faciliter la synchronisation dans toute l'application:

1. **SyncBottomSheet** - Un BottomSheet complet avec toutes les informations de synchronisation
2. **SyncFloatingActionButton** - Un bouton flottant avec badge indiquant les éléments en attente
3. **SyncStatusScreen** - Écran dédié amélioré avec statistiques détaillées

## 🚀 Comment utiliser

### Option 1: Bouton Flottant avec Badge (Recommandé)

Remplacez votre `FloatingActionButton` existant par le composant de synchronisation:

```dart
import '../widgets/sync_fab.dart';

class VotreScreen extends ConsumerStatefulWidget {
  // ... votre code
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(/* ... */),
      body: /* ... */,
      // Remplacez votre FAB par celui-ci
      floatingActionButton: const SyncFloatingActionButton(),
    );
  }
}
```

**Avantages:**
- Badge rouge indiquant le nombre d'éléments non synchronisés
- Animation de chargement pendant la synchronisation
- Désactivé automatiquement pendant la synchronisation
- Ouvre le BottomSheet complet au clic

### Option 2: Bouton dans AppBar

Ajoutez un bouton de synchronisation dans la barre d'application:

```dart
import '../widgets/sync_bottom_sheet.dart';

AppBar(
  title: const Text('Ma Vue'),
  actions: [
    // Bouton de synchronisation
    Consumer(
      builder: (context, ref, _) {
        final syncState = ref.watch(syncStateNotifierProvider);
        final isSyncing = syncState.status != SyncStatus.idle;
        
        return IconButton(
          icon: isSyncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.sync),
          onPressed: isSyncing ? null : () => showSyncBottomSheet(context),
          tooltip: 'Synchroniser',
        );
      },
    ),
  ],
),
```

### Option 3: Bouton autonome dans votre UI

Ajoutez un bouton n'importe où dans votre interface:

```dart
import '../widgets/sync_bottom_sheet.dart';

ElevatedButton.icon(
  onPressed: () => showSyncBottomSheet(context),
  icon: const Icon(Icons.sync),
  label: const Text('Synchroniser'),
  style: ElevatedButton.styleFrom(
    backgroundColor: AyannaColors.orange,
  ),
)
```

## 📊 Fonctionnalités du BottomSheet

Le BottomSheet de synchronisation affiche:

### 1. État Actuel
- **Icône de statut** avec code couleur:
  - 🔵 Bleu: Téléchargement en cours
  - 🟠 Orange: Envoi en cours
  - 🟣 Violet: Traitement
  - ⚫ Gris: Inactif
  - 🔴 Rouge: Erreur
- **Barre de progression** avec pourcentage
- **Message de statut** descriptif

### 2. Dernière Synchronisation
- Date et heure de la dernière synchronisation
- Format intelligent:
  - "Aujourd'hui à 14:30"
  - "Hier à 09:15"
  - "Il y a 3 jours"
  - "12/10/2024 à 16:45"

### 3. Statistiques Détaillées
Affiche le nombre d'éléments en attente de synchronisation par catégorie:
- 👨‍🎓 Élèves
- 🏫 Classes
- 👨‍🏫 Enseignants
- 👥 Responsables
- 💰 Paiements
- 📝 Écritures comptables
- **Total** avec badge orange

### 4. Actions
- **Bouton Télécharger** (bleu): Récupère les données du serveur
- **Bouton Envoyer** (orange): Envoie les modifications locales au serveur
- Désactivés automatiquement pendant une synchronisation

## 🎨 Personnalisation

### Modifier les couleurs

Dans `sync_bottom_sheet.dart`:

```dart
Container(
  decoration: BoxDecoration(
    color: AyannaColors.orange,  // Changez ici
    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  ),
  // ...
)
```

### Modifier la taille du BottomSheet

Dans `sync_bottom_sheet.dart`, fonction `showSyncBottomSheet`:

```dart
DraggableScrollableSheet(
  initialChildSize: 0.7,  // Taille initiale (70% de l'écran)
  minChildSize: 0.5,      // Taille minimum (50%)
  maxChildSize: 0.95,     // Taille maximum (95%)
  // ...
)
```

### Ajouter plus de statistiques

Dans `_getUnsyncedCounts()`, ajoutez vos entités:

```dart
final nouvelleEntite = await database.nouvelleEntiteDao.getUnsyncedItems();

return {
  'eleves': eleves.length,
  // ... autres
  'nouvelleEntite': nouvelleEntite.length,  // Ajoutez ici
};
```

Puis dans `_buildSyncStatsCard()`:

```dart
if (counts['nouvelleEntite']! > 0)
  _buildCompactStatRow('Nouvelle Entité', counts['nouvelleEntite']!),
```

## 📱 Exemples d'intégration complète

### Exemple 1: Écran des Élèves

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/ayanna_appbar.dart';
import '../widgets/ayanna_drawer.dart';
import '../widgets/sync_fab.dart';  // ← Import

class ElevesScreen extends ConsumerStatefulWidget {
  const ElevesScreen({super.key});

  @override
  ConsumerState<ElevesScreen> createState() => _ElevesScreenState();
}

class _ElevesScreenState extends ConsumerState<ElevesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AyannaAppBar(title: 'Élèves'),
      drawer: const AyannaDrawer(selectedIndex: 0),
      body: /* votre contenu */,
      floatingActionButton: const SyncFloatingActionButton(),  // ← Ajoutez ici
    );
  }
}
```

### Exemple 2: Écran avec 2 FABs (Ajout + Sync)

```dart
import 'package:flutter/material.dart';
import '../widgets/sync_bottom_sheet.dart';

class MonEcran extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Écran')),
      body: /* votre contenu */,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bouton de synchronisation
          FloatingActionButton(
            heroTag: 'sync',
            onPressed: () => showSyncBottomSheet(context),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.sync),
          ),
          const SizedBox(height: 16),
          // Bouton d'ajout
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () {/* ajouter */},
            backgroundColor: Colors.orange,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
```

## 🔧 Dépendances requises

Assurez-vous d'avoir ces imports:

```dart
import '../../services/providers/sync_provider_new.dart';
import '../../services/providers/shared_preferences_provider.dart';
import '../../services/providers/auth_provider.dart';
import '../../services/providers/database_provider.dart';
import '../../theme/ayanna_theme.dart';
```

## 📝 Notes importantes

1. **Authentification**: L'utilisateur doit être connecté pour synchroniser
2. **Connexion**: Vérifiez la connexion internet avant la synchronisation
3. **Performance**: Les statistiques sont calculées de manière asynchrone
4. **État**: Le statut de synchronisation est géré globalement via Riverpod

## 🐛 Debugging

Si le BottomSheet ne s'affiche pas:

```dart
// Vérifiez que vous utilisez bien le bon contexte
showSyncBottomSheet(context);

// Si vous êtes dans un Builder, utilisez le context du Builder
Builder(
  builder: (context) => IconButton(
    icon: const Icon(Icons.sync),
    onPressed: () => showSyncBottomSheet(context),
  ),
)
```

Si les statistiques ne s'affichent pas:

```dart
// Vérifiez que vos DAOs ont bien les méthodes getUnsynced...()
// Exemple:
@Query('SELECT * FROM eleves WHERE is_sync = 0')
Future<List<Eleve>> getUnsyncedEleves();
```

## 🎯 Bonnes pratiques

1. **Utilisez SyncFloatingActionButton** sur les écrans principaux (Élèves, Classes, etc.)
2. **Utilisez un bouton dans AppBar** sur les écrans secondaires
3. **Testez la synchronisation** régulièrement pendant le développement
4. **Gérez les erreurs** avec des SnackBars informatifs
5. **Évitez les synchronisations simultanées** (géré automatiquement par le système)

## 📚 Ressources

- **SyncBottomSheet**: `/lib/vues/widgets/sync_bottom_sheet.dart`
- **SyncFloatingActionButton**: `/lib/vues/widgets/sync_fab.dart`
- **SyncStatusScreen**: `/lib/vues/synchronisation/sync_status_screen.dart`
- **Providers**: `/lib/services/providers/sync_provider_new.dart`
