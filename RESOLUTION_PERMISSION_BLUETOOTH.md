# 🔧 Résolution d'erreur: MissingPluginException - Permission Handler

## ❌ Erreur rencontrée

```
Exception has occurred.
MissingPluginException (MissingPluginException(No implementation found for method requestPermissions on channel flutter.baseflow.com/permissions/methods))
```

## 🔍 Cause du problème

Le plugin `permission_handler` nécessite une configuration native dans le fichier `AndroidManifest.xml` pour fonctionner correctement. Sans cette configuration, Flutter ne peut pas accéder aux méthodes natives pour demander les permissions Bluetooth.

## ✅ Solution appliquée

### 1. Ajout des permissions dans AndroidManifest.xml

**Fichier**: `/android/app/src/main/AndroidManifest.xml`

Ajout des permissions Bluetooth nécessaires :

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

### 2. Explication des permissions

| Permission | API Level | Description |
|------------|-----------|-------------|
| `BLUETOOTH` | ≤30 | Permission Bluetooth de base pour anciennes versions Android |
| `BLUETOOTH_ADMIN` | ≤30 | Administration Bluetooth pour anciennes versions |
| `BLUETOOTH_SCAN` | ≥31 | Scanner les appareils Bluetooth (Android 12+) |
| `BLUETOOTH_CONNECT` | ≥31 | Se connecter aux appareils Bluetooth (Android 12+) |
| `ACCESS_FINE_LOCATION` | Toutes | Localisation précise (requise pour Bluetooth scan) |
| `ACCESS_COARSE_LOCATION` | Toutes | Localisation approximative |

#### Attributs importants

- `android:maxSdkVersion="30"` : Permission uniquement pour Android 11 et inférieur
- `android:usesPermissionFlags="neverForLocation"` : Indique que le scan Bluetooth n'est pas utilisé pour la localisation
- `android:required="false"` : L'app peut fonctionner sans Bluetooth (non bloquant)

### 3. Rebuild du projet

Après modification du `AndroidManifest.xml`, il est **OBLIGATOIRE** de faire :

```bash
flutter clean
flutter pub get
flutter run
```

Ou depuis Android Studio / VS Code : **Clean & Rebuild**

## 🎯 Permissions demandées dans le code

Dans les fichiers modifiés, nous demandons ces permissions :

```dart
Future<void> _requestBluetoothPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetooth,        // Bluetooth de base
    Permission.bluetoothConnect, // Connexion Bluetooth
    Permission.bluetoothScan,    // Scan d'appareils
    Permission.location,         // Localisation (requis pour scan)
  ].request();

  bool allGranted = statuses.values.every((status) => status.isGranted);
  
  if (allGranted) {
    _startScan();
  } else {
    // Message d'erreur à l'utilisateur
  }
}
```

## 📱 Comportement selon la version Android

### Android 11 et inférieur (API ≤30)
- Demande : `BLUETOOTH`, `BLUETOOTH_ADMIN`, `ACCESS_FINE_LOCATION`
- L'utilisateur doit accepter la localisation pour utiliser Bluetooth

### Android 12 et supérieur (API ≥31)
- Demande : `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`
- Permissions Bluetooth séparées de la localisation
- Flag `neverForLocation` permet de ne pas demander la localisation si non nécessaire

## 🧪 Test des permissions

### Étape 1 : Premier lancement
1. Lancer l'application après rebuild
2. Naviguer vers un écran avec impression (paiement_frais, classe_eleve_details, facture_dialog)
3. ✅ Vérifier l'apparition de dialogues de permissions

### Étape 2 : Acceptation
1. Accepter toutes les permissions demandées
2. ✅ Vérifier que le scan d'imprimantes démarre automatiquement

### Étape 3 : Refus
1. Refuser une ou plusieurs permissions
2. ✅ Vérifier l'affichage du message "Permissions Bluetooth requises..."
3. Aller dans Paramètres Android > Apps > Ayanna School > Permissions
4. Activer les permissions manuellement
5. Redémarrer l'écran
6. ✅ Vérifier que le scan fonctionne

## 🛠️ Débogage

### Si l'erreur persiste après rebuild

1. **Supprimer l'app du téléphone** :
   ```bash
   adb uninstall com.example.ayanna_school
   ```

2. **Clean complet** :
   ```bash
   flutter clean
   rm -rf build/
   flutter pub get
   ```

3. **Rebuild Android** :
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter run
   ```

4. **Vérifier les logs** :
   ```bash
   flutter run -v
   ```
   Chercher : `"permission"` ou `"bluetooth"` dans les logs

### Vérifier les permissions dans l'app installée

```bash
adb shell dumpsys package com.example.ayanna_school | grep permission
```

Devrait afficher :
```
android.permission.BLUETOOTH: granted=true
android.permission.BLUETOOTH_CONNECT: granted=true
android.permission.BLUETOOTH_SCAN: granted=true
android.permission.ACCESS_FINE_LOCATION: granted=true
```

## 📋 Checklist de résolution

- [✅] Permissions ajoutées dans `AndroidManifest.xml`
- [✅] `flutter clean` exécuté
- [✅] `flutter pub get` exécuté
- [✅] Application désinstallée et réinstallée
- [✅] Permissions acceptées lors du premier lancement
- [✅] Scan d'imprimantes fonctionne

## 🚨 Erreurs communes

### 1. "Permission denied" après acceptation
**Cause** : L'app n'a pas été reconstruite après modification du manifest
**Solution** : `flutter clean && flutter run`

### 2. Pas de dialogue de permission
**Cause** : Permissions déjà refusées dans une version précédente
**Solution** : Désinstaller l'app et réinstaller

### 3. "Bluetooth not available"
**Cause** : Bluetooth désactivé sur l'appareil
**Solution** : Activer Bluetooth dans les paramètres

## 📚 Ressources

- [Documentation permission_handler](https://pub.dev/packages/permission_handler)
- [Android Bluetooth permissions](https://developer.android.com/guide/topics/connectivity/bluetooth/permissions)
- [Flutter platform channels](https://docs.flutter.dev/development/platform-integration/platform-channels)

## ✅ Résultat final

Après application de cette solution :
1. ✅ Permissions Bluetooth correctement configurées
2. ✅ Demande de permissions au démarrage de l'écran
3. ✅ Scan automatique après acceptation
4. ✅ Message d'erreur clair en cas de refus
5. ✅ Impression thermique fonctionnelle

---

**Date de résolution** : 5 octobre 2025  
**Version Flutter** : Compatible avec toutes versions  
**Version Android** : API 21+ (Android 5.0+)
