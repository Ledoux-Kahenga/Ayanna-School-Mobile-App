import 'dart:io';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter/material.dart';

// Fichier de test pour explorer les méthodes disponibles de print_bluetooth_thermal
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Test Bluetooth Methods')),
        body: BluetoothTestWidget(),
      ),
    );
  }
}

class BluetoothTestWidget extends StatefulWidget {
  @override
  _BluetoothTestWidgetState createState() => _BluetoothTestWidgetState();
}

class _BluetoothTestWidgetState extends State<BluetoothTestWidget> {
  List<String> _logs = [];

  void _addLog(String log) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: $log');
    });
    print(log);
  }

  // Test des différentes méthodes de découverte Bluetooth
  Future<void> _testBluetoothMethods() async {
    _addLog('=== DÉBUT DES TESTS BLUETOOTH ===');

    try {
      // 1. Vérifier l'état du Bluetooth
      _addLog('Test 1: Vérification de l\'état Bluetooth...');
      final isEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      _addLog('Bluetooth activé: $isEnabled');

      if (!isEnabled) {
        _addLog('❌ Bluetooth non activé - arrêt des tests');
        return;
      }

      // 2. Test pairedBluetooths (méthode actuelle)
      _addLog('\nTest 2: pairedBluetooths (méthode actuelle)...');
      final pairedDevices = await PrintBluetoothThermal.pairedBluetooths;
      _addLog('Appareils appairés trouvés: ${pairedDevices.length}');
      for (final device in pairedDevices) {
        _addLog('  - ${device.name} (${device.macAdress})');
      }

      // 3. Exploration des méthodes statiques disponibles
      _addLog('\nTest 3: Exploration des méthodes disponibles...');

      // Test si d'autres méthodes existent (à adapter selon la documentation)
      try {
        // Cette méthode peut ne pas exister - test exploratoire
        // final availableDevices = await PrintBluetoothThermal.availableBluetooths;
        _addLog('availableBluetooths: Non disponible ou non implémentée');
      } catch (e) {
        _addLog('availableBluetooths: Méthode non trouvée ($e)');
      }

      // 4. Test des propriétés de statut
      _addLog('\nTest 4: Statuts de connexion...');
      try {
        final connectionStatus = await PrintBluetoothThermal.connectionStatus;
        _addLog('Statut de connexion: $connectionStatus');
      } catch (e) {
        _addLog('Erreur statut connexion: $e');
      }

      // 5. Test d'information sur la plateforme
      _addLog('\nTest 5: Informations plateforme...');
      _addLog('Plateforme: ${Platform.operatingSystem}');
    } catch (e) {
      _addLog('❌ Erreur globale: $e');
    }

    _addLog('\n=== FIN DES TESTS ===');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: _testBluetoothMethods,
            child: Text('Tester les méthodes Bluetooth'),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _logs
                      .map(
                        (log) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
