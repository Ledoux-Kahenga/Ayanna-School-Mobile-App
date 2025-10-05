# 📄 Guide d'Impression Thermique - Ayanna School

## 🎯 Vue d'ensemble

L'impression thermique a été implémentée dans trois écrans de l'application pour permettre l'impression de reçus de paiement via des imprimantes thermiques Bluetooth.

## 📁 Fichiers modifiés

### 1. **facture_dialog.dart**
- Widget: `FactureDialog` → Dialog avec impression thermique
- Widget reçu: `FactureReceiptWidget`
- Localisation: `/lib/vues/widgets/facture_dialog.dart`

### 2. **classe_eleve_details_screen.dart**
- Widget: `ClasseEleveDetailsScreen` → Détails d'un élève avec impression
- Widget reçu: `FactureReceiptWidget`
- Localisation: `/lib/vues/classes/classe_eleve_details_screen.dart`

### 3. **paiement_frais.dart**
- Widget: `PaiementDesFrais` → Gestion des paiements avec impression
- Widget reçu: `FactureReceiptWidgetPaiement`
- Localisation: `/lib/vues/gestions frais/paiement_frais.dart`

---

## 🔧 Fonctionnalités implémentées

### ✅ Demande de permissions Bluetooth
```dart
Future<void> _requestBluetoothPermissions() async {
  // Demander les permissions Bluetooth nécessaires
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.location,
  ].request();

  // Vérifier si toutes les permissions sont accordées
  bool allGranted = statuses.values.every((status) => status.isGranted);
  
  if (allGranted) {
    _startScan();
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissions Bluetooth requises pour l\'impression'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
```
- Demande automatique au démarrage de l'écran
- Permissions requises : bluetooth, bluetoothConnect, bluetoothScan, location
- Message d'erreur si permissions refusées

### ✅ Découverte automatique des imprimantes
```dart
void _startScan() {
  _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream.listen((devices) {
    if (mounted) {
      setState(() {
        printers = devices;
      });
    }
  });
}
```
- Scan automatique après obtention des permissions
- Mise à jour en temps réel de la liste des imprimantes
- Gestion du cycle de vie (dispose du stream)

### ✅ Sélection intelligente de l'imprimante

#### Cas 1: Aucune imprimante
- Affiche un message d'erreur
- "Aucune imprimante trouvée. Assurez-vous que l'imprimante est connectée."

#### Cas 2: Une seule imprimante
- Sélection automatique
- Impression directe sans dialogue

#### Cas 3: Plusieurs imprimantes
- Affiche un dialogue de sélection
- Liste toutes les imprimantes disponibles
- Affiche le nom et l'adresse de chaque imprimante
- Permet l'annulation

```dart
if (printers.length > 1) {
  selectedPrinter = await showDialog<thermal.Printer>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Sélectionner une imprimante'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: printers.map((printer) {
              return ListTile(
                leading: const Icon(Icons.print, color: AyannaColors.orange),
                title: Text(printer.name ?? 'Imprimante inconnue'),
                subtitle: Text(printer.address ?? ''),
                onTap: () {
                  Navigator.of(context).pop(printer);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
```

---

## 📄 Structure du reçu imprimé

Le format du reçu est identique à celui de `pdf_service.dart`:

```
┌─────────────────────────────────────┐
│           [Logo Orange]             │
│         Ayanna School               │
├─────────────────────────────────────┤
│      RECU DE PAIEMENT              │
├─────────────────────────────────────┤
│ Eleve: [Nom Prénom]                │
│ Classe: [Nom Classe]               │
│ Frais concerné: [Nom Frais]       │
├─────────────────────────────────────┤
│ Details des paiements:             │
│ ┌────────┬────────────┬──────────┐ │
│ │  Date  │ Montant    │ Caissier │ │
│ ├────────┼────────────┼──────────┤ │
│ │ [Date] │ [Montant]  │  Admin   │ │
│ └────────┴────────────┴──────────┘ │
├─────────────────────────────────────┤
│ Statut: [EN ORDRE/PARTIELLEMENT]  │
│ Total Payé: [Montant] CDF          │
│ Reste à Payer: [Montant] CDF       │
├─────────────────────────────────────┤
│   Merci pour votre paiement.       │
├─────────────────────────────────────┤
│ Généré par Ayanna School - [Date]  │
└─────────────────────────────────────┘
```

---

## 🎨 Éléments de design

### Couleurs utilisées
- **Orange Principal**: `AyannaColors.orange` - Logo, en-têtes de tableau
- **Blanc**: `AyannaColors.white` - Texte sur fond orange
- **Gris Foncé**: `AyannaColors.darkGrey` - Texte principal
- **Gris Clair**: `AyannaColors.lightGrey` - Bordures de tableau
- **Vert Succès**: `AyannaColors.successGreen` - Statut "En ordre"
- **Rouge**: `Colors.red` - Statut "Pas en ordre"

### Formatage
- **Dates**: Format `dd/MM/yyyy` via `DateFormat('dd/MM/yyyy')`
- **Montants**: Format `#,##0` (séparateur de milliers) via `NumberFormat("#,##0", "fr_FR")`
- **Devise**: CDF (Franc Congolais)

---

## 🔌 Dépendances requises

```yaml
dependencies:
  flutter_thermal_printer: ^1.2.4  # Impression thermique
  intl: ^0.20.2                     # Formatage dates/nombres
  permission_handler: ^12.0.1       # Gestion des permissions Bluetooth
```

---

## 🚀 Utilisation

### Dans facture_dialog.dart
```dart
// Ouvrir le dialogue de facture
showDialog(
  context: context,
  builder: (context) => FactureDialog(
    eleve: monEleve,
    fraisDetails: mesFraisDetails,
  ),
);
// L'utilisateur clique sur "Imprimer" → Sélection automatique/manuelle → Impression
```

### Dans classe_eleve_details_screen.dart
```dart
// Bouton "Imprimer le reçu"
ElevatedButton.icon(
  icon: const Icon(Icons.print),
  label: const Text('Imprimer'),
  onPressed: () async {
    await _showReceiptWidget(widget.eleve, fraisDetail);
  },
)
```

### Dans paiement_frais.dart
```dart
// Bouton "Imprimer le reçu" dans la carte de frais
TextButton.icon(
  icon: const Icon(Icons.print),
  label: const Text('Imprimer le reçu'),
  onPressed: () async {
    await _showReceiptWidget(_selectedEleve!, fd);
  },
)
```

---

## 🔍 Gestion des erreurs

### Aucune imprimante trouvée
```dart
if (printers.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Aucune imprimante trouvée. Assurez-vous que l\'imprimante est connectée.')
    ),
  );
  return;
}
```

### Annulation de sélection
```dart
if (selectedPrinter == null) {
  return; // L'utilisateur a annulé, pas d'impression
}
```

---

## 🧪 Tests recommandés

### Test 0: Permissions Bluetooth
1. Premier lancement de l'écran
2. ✅ Vérifier l'affichage de la demande de permissions
3. Accepter les permissions
4. ✅ Vérifier que le scan démarre automatiquement
5. Refuser les permissions
6. ✅ Vérifier l'affichage du message "Permissions Bluetooth requises..."

### Test 1: Aucune imprimante
1. Désactiver Bluetooth ou déconnecter toutes les imprimantes
2. Cliquer sur "Imprimer"
3. ✅ Vérifier l'affichage du message d'erreur

### Test 2: Une imprimante
1. Connecter une imprimante thermique
2. Cliquer sur "Imprimer"
3. ✅ Vérifier l'impression directe (pas de dialogue)

### Test 3: Plusieurs imprimantes
1. Connecter 2+ imprimantes thermiques
2. Cliquer sur "Imprimer"
3. ✅ Vérifier l'affichage du dialogue de sélection
4. Sélectionner une imprimante
5. ✅ Vérifier l'impression sur l'imprimante choisie

### Test 4: Annulation
1. Avoir plusieurs imprimantes
2. Cliquer sur "Imprimer"
3. Cliquer sur "Annuler" dans le dialogue
4. ✅ Vérifier qu'aucune impression n'a lieu

---

## 📊 Cycle de vie

```
Initialisation (initState)
    ↓
Demande permissions (_requestBluetoothPermissions)
    ↓
┌─────────────────────────────────────┐
│ Permissions accordées?              │
│   ✅ Oui → _startScan()            │
│   ❌ Non → Message SnackBar        │
└─────────────────────────────────────┘
    ↓
Démarrage du scan (_startScan)
    ↓
Écoute du stream (devicesStream)
    ↓
Mise à jour de la liste (setState)
    ↓
Utilisateur clique "Imprimer"
    ↓
Vérification des imprimantes
    ↓
┌─────────────────────────────┐
│ Aucune? → Message d'erreur  │
│ Une? → Impression directe   │
│ Plusieurs? → Dialogue choix │
└─────────────────────────────┘
    ↓
Impression (printWidget)
    ↓
Fermeture (dispose)
    ↓
Annulation du stream
```

---

## 🎯 Avantages de cette implémentation

✅ **Découverte automatique** - Pas besoin de rechercher manuellement  
✅ **Sélection intelligente** - Automatique si une seule imprimante  
✅ **Multi-imprimantes** - Dialogue de sélection si plusieurs  
✅ **Gestion des erreurs** - Messages clairs pour l'utilisateur  
✅ **Design cohérent** - Même format que pdf_service.dart  
✅ **Pas de modifications visuelles** - UI inchangée  
✅ **Cycle de vie propre** - Dispose correct des streams  

---

## 📝 Notes importantes

1. **Bluetooth requis**: L'imprimante doit être appairée via Bluetooth système
2. **Permissions**: Permissions Bluetooth configurées dans `AndroidManifest.xml`
3. **Format**: Largeur fixe de 550px pour compatibilité thermique
4. **Stream**: Écoute continue pour détecter connexions/déconnexions
5. **Langue**: Interface en français
6. **Rebuild obligatoire**: Après modifications du manifest, faire `flutter clean && flutter run`

### ⚠️ Configuration Android requise

Les permissions suivantes sont configurées dans `/android/app/src/main/AndroidManifest.xml` :

```xml
<!-- Permissions pour Bluetooth et impression thermique -->
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<uses-feature android:name="android.hardware.bluetooth" android:required="false" />
<uses-feature android:name="android.hardware.bluetooth_le" android:required="false" />
```

**Important** : Si vous rencontrez l'erreur `MissingPluginException`, consultez le fichier [RESOLUTION_PERMISSION_BLUETOOTH.md](RESOLUTION_PERMISSION_BLUETOOTH.md)

---

## 🛠️ Maintenance future

### Pour ajouter une nouvelle page avec impression:

1. **Imports nécessaires**:
```dart
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart' as thermal;
import 'dart:async';
import 'package:intl/intl.dart';
```

2. **Variables de classe**:
```dart
final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;
List<thermal.Printer> printers = [];
StreamSubscription<List<thermal.Printer>>? _devicesStreamSubscription;
```

3. **Méthodes à copier**:
- `_startScan()`
- `_showReceiptWidget()`
- `dispose()` avec annulation du stream

4. **Widget de reçu**:
- Copier `FactureReceiptWidget`
- Adapter les données à afficher

---

**Date de création**: 5 octobre 2025  
**Version**: 1.0  
**Auteur**: Système d'impression thermique Ayanna School
