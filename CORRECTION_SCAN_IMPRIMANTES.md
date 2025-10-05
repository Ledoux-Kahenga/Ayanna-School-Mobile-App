# Correction du scan des imprimantes thermiques Bluetooth

## Problème
L'erreur "Aucune imprimante trouvée" apparaissait même avec une imprimante Bluetooth connectée et fonctionnelle.

## Cause
Le code écoutait uniquement le `devicesStream` sans jamais lancer la découverte des imprimantes via la méthode `getPrinters()`.

## Solution appliquée

### Fichiers modifiés
1. `lib/vues/classes/classe_eleve_details_screen.dart`
2. `lib/vues/widgets/facture_dialog.dart`
3. `lib/vues/gestions frais/paiement_frais.dart`

### Code corrigé
```dart
void _startScan() async {
  // D'abord écouter le stream
  _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream.listen((devices) {
    if (mounted) {
      setState(() {
        printers = devices;
        print('Imprimantes trouvées: ${devices.length}');
        for (var printer in devices) {
          print('- ${printer.name} (${printer.address})');
        }
      });
    }
  });
  
  // Puis lancer la découverte des imprimantes Bluetooth
  await _flutterThermalPrinterPlugin.getPrinters(
    refreshDuration: const Duration(seconds: 2),
    connectionTypes: [thermal.ConnectionType.BLE],
  );
}
```

## Fonctionnement

### Étape 1 : Configuration du stream
Le code commence par s'abonner au `devicesStream` qui recevra les imprimantes découvertes.

### Étape 2 : Lancement du scan
La méthode `getPrinters()` est appelée avec :
- `refreshDuration`: Durée entre chaque refresh du scan (2 secondes)
- `connectionTypes`: Types de connexion recherchés (BLE pour Bluetooth Low Energy)

### Étape 3 : Réception des résultats
Chaque fois qu'une imprimante est découverte, le stream est déclenché et la liste `printers` est mise à jour.

## Résultat
- ✅ Les imprimantes Bluetooth sont maintenant correctement détectées
- ✅ La liste se rafraîchit automatiquement toutes les 2 secondes
- ✅ Des logs sont affichés dans la console pour le débogage

## Test
Pour tester la correction :
1. Assurez-vous que le Bluetooth est activé
2. Vérifiez que l'imprimante thermique est allumée et visible
3. Ouvrez l'un des écrans avec impression
4. Les imprimantes devraient apparaître automatiquement
5. Vérifiez les logs dans la console : "Imprimantes trouvées: X"

## Documentation du plugin
- Package : `flutter_thermal_printer: ^1.2.4`
- GitHub : https://github.com/SunilDevX/flutter_thermal_printer
- Pub.dev : https://pub.dev/packages/flutter_thermal_printer

## Types de connexion supportés
- `ConnectionType.BLE` : Bluetooth Low Energy
- `ConnectionType.USB` : Imprimantes USB (Android, Windows, macOS)
- `ConnectionType.NETWORK` : Imprimantes réseau WiFi

Date de correction : 5 octobre 2025
