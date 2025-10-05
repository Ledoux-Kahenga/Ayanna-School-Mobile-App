# Correction des permissions Bluetooth pour impression thermique

## 🐛 Problème identifié

D'après les logs :
```
D/permissions_handler(30472): Bluetooth permission missing in manifest
I/flutter (30472):    - Permission.bluetooth: PermissionStatus.denied
I/flutter (30472): ❌ [ClasseEleveDetails] Permissions refusées
```

La permission `Permission.bluetooth` (ancienne API) était refusée, empêchant le scan des imprimantes.

## 🔍 Cause racine

Sur **Android 12+ (API 31+)**, la permission `Permission.bluetooth` est obsolète et remplacée par :
- `Permission.bluetoothConnect` - Pour se connecter aux appareils Bluetooth
- `Permission.bluetoothScan` - Pour scanner les appareils Bluetooth

L'ancien code demandait les 4 permissions et vérifiait que **toutes** soient accordées, ce qui échouait car `Permission.bluetooth` est automatiquement refusée sur Android 12+.

## ✅ Solution appliquée

### Modification du code de demande de permissions

**Avant :**
```dart
Map<Permission, PermissionStatus> statuses = await [
  Permission.bluetooth,        // ❌ Obsolète sur Android 12+
  Permission.bluetoothConnect,
  Permission.bluetoothScan,
  Permission.location,
].request();

bool allGranted = statuses.values.every((status) => status.isGranted);
```

**Après :**
```dart
Map<Permission, PermissionStatus> statuses = await [
  Permission.bluetoothConnect, // ✅ Nouvelle API
  Permission.bluetoothScan,    // ✅ Nouvelle API
  Permission.location,         // ✅ Optionnelle avec neverForLocation
].request();

// Vérifier uniquement les permissions essentielles
bool bluetoothConnectGranted = statuses[Permission.bluetoothConnect]?.isGranted ?? false;
bool bluetoothScanGranted = statuses[Permission.bluetoothScan]?.isGranted ?? false;
bool permissionsOk = bluetoothConnectGranted && bluetoothScanGranted;
```

### Logs améliorés

Ajout de logs détaillés pour chaque permission :
```dart
print('📍 [Widget] Analyse des permissions:');
print('   - bluetoothConnect: $bluetoothConnectGranted');
print('   - bluetoothScan: $bluetoothScanGranted');
print('   - location: $locationGranted');
print('   - Permissions OK: $permissionsOk');
```

## 📱 Compatibilité Android

### Android 12+ (API 31+)
- ✅ Utilise `bluetoothConnect` et `bluetoothScan`
- ✅ `neverForLocation` dans le manifest évite de demander la localisation
- ❌ `Permission.bluetooth` est automatiquement refusée (obsolète)

### Android < 12 (API ≤ 30)
- ✅ `bluetoothConnect` et `bluetoothScan` sont accordées automatiquement
- ✅ Compatible avec le nouveau code
- ℹ️ La permission `bluetooth` dans le manifest (avec `maxSdkVersion="30"`) est toujours nécessaire

## 📝 Fichiers modifiés

1. `lib/vues/classes/classe_eleve_details_screen.dart`
2. `lib/vues/widgets/facture_dialog.dart`
3. `lib/vues/gestions frais/paiement_frais.dart`

## 🧪 Test après correction

Après cette correction, les logs devraient afficher :

```
📍 [Widget] Début de la demande de permissions Bluetooth...
📍 [Widget] Statuts des permissions:
   - Permission.bluetoothConnect: PermissionStatus.granted
   - Permission.bluetoothScan: PermissionStatus.granted
   - Permission.location: PermissionStatus.granted
📍 [Widget] Analyse des permissions:
   - bluetoothConnect: true
   - bluetoothScan: true
   - location: true
   - Permissions OK: true
✅ [Widget] Permissions essentielles accordées, lancement du scan...
📍 [Widget] Début du scan des imprimantes...
```

## 🔗 Références

- [Android Bluetooth Permissions](https://developer.android.com/guide/topics/connectivity/bluetooth/permissions)
- [permission_handler plugin](https://pub.dev/packages/permission_handler)
- AndroidManifest.xml : Les permissions sont correctement configurées avec `neverForLocation`

## 📅 Date de correction

5 octobre 2025

---

## ⚡ Actions requises

1. **Relancez l'application** : `flutter run`
2. **Accordez les permissions** quand demandées
3. **Vérifiez les logs** pour confirmer le scan

### Logs attendus après correction

```
✅ [Widget] Permissions essentielles accordées, lancement du scan...
📍 [Widget] Début du scan des imprimantes...
📍 [Widget] Configuration du listener devicesStream...
📍 [Widget] Listener configuré, lancement de getPrinters()...
✅ [Widget] getPrinters() terminé, attente des résultats dans le stream...
📡 [Widget] Stream déclenché avec 1 imprimante(s)
✅ [Widget] Liste mise à jour: 1 imprimante(s)
   🖨️  Thermal Printer (XX:XX:XX:XX:XX:XX) - Type: ConnectionType.BLE
```

## 🚨 Si le problème persiste

1. **Vérifier les permissions manuellement** : Paramètres > Applications > Ayanna School > Permissions
2. **Vérifier le Bluetooth** : Assurez-vous qu'il est activé
3. **Réinstaller l'app** : Pour forcer une nouvelle demande de permissions
4. **Consulter** : `DEBUG_IMPRESSION_LOGS.md` pour l'interprétation complète des logs
