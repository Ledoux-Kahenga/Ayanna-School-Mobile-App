import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPrintService {
  static final BluetoothPrintService _instance =
      BluetoothPrintService._internal();
  factory BluetoothPrintService() => _instance;
  BluetoothPrintService._internal();

  // Cache des appareils découverts pour persister même après déconnexion
  final List<BluetoothInfo> _cachedDevices = [];
  final Set<String> _knownMacAddresses = {};

  /// Vérifie et demande les permissions Bluetooth
  Future<bool> checkPermissions() async {
    try {
      // Demander les permissions nécessaires pour le Bluetooth
      List<Permission> permissions = [];

      // Sur Android 12+ (API 31+), utiliser les nouvelles permissions
      permissions.add(Permission.bluetoothScan);
      permissions.add(Permission.bluetoothConnect);

      // Permission de localisation nécessaire pour le scan Bluetooth
      permissions.add(Permission.locationWhenInUse);

      debugPrint('🔵 Demande des permissions Bluetooth...');

      // Demander toutes les permissions
      Map<Permission, PermissionStatus> statuses = await permissions.request();

      // Vérifier si les permissions essentielles sont accordées
      bool bluetoothScanGranted =
          statuses[Permission.bluetoothScan]?.isGranted ?? false;
      bool bluetoothConnectGranted =
          statuses[Permission.bluetoothConnect]?.isGranted ?? false;
      bool locationGranted =
          statuses[Permission.locationWhenInUse]?.isGranted ?? false;

      debugPrint('📍 Permissions accordées:');
      debugPrint('  - Bluetooth Scan: $bluetoothScanGranted');
      debugPrint('  - Bluetooth Connect: $bluetoothConnectGranted');
      debugPrint('  - Location: $locationGranted');

      // Les permissions Bluetooth scan et connect sont essentielles
      if (!bluetoothScanGranted || !bluetoothConnectGranted) {
        debugPrint('❌ Permissions Bluetooth essentielles refusées');
        return false;
      }

      // Vérifier que le Bluetooth est activé
      final isEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      debugPrint('📶 Bluetooth activé: $isEnabled');

      return isEnabled;
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification des permissions: $e');
      return false;
    }
  }

  /// Vérifie si Bluetooth est disponible et activé
  Future<bool> isBluetoothAvailable() async {
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (e) {
      debugPrint('Erreur lors de la vérification Bluetooth: $e');
      return false;
    }
  }

  /// Scanne les appareils Bluetooth disponibles (appairés + cache)
  Future<List<BluetoothInfo>> scanDevices() async {
    try {
      final hasPermissions = await checkPermissions();
      if (!hasPermissions) {
        throw Exception('Permissions Bluetooth non accordées');
      }

      final isEnabled = await isBluetoothAvailable();
      if (!isEnabled) {
        throw Exception('Bluetooth non activé');
      }

      // Récupérer les appareils actuellement appairés
      final pairedDevices = await PrintBluetoothThermal.pairedBluetooths;

      // Mettre à jour le cache avec les nouveaux appareils
      for (final device in pairedDevices) {
        if (!_knownMacAddresses.contains(device.macAdress)) {
          _knownMacAddresses.add(device.macAdress);
          _cachedDevices.add(device);
          debugPrint(
            'Nouvel appareil ajouté au cache: ${device.name} (${device.macAdress})',
          );
        }
      }

      // Retourner une liste combinée (cache + appareils actuels)
      final Map<String, BluetoothInfo> allDevicesMap = {};

      // D'abord ajouter les appareils du cache
      for (final device in _cachedDevices) {
        allDevicesMap[device.macAdress] = device;
      }

      // Puis mettre à jour avec les appareils actuellement appairés (priorité)
      for (final device in pairedDevices) {
        allDevicesMap[device.macAdress] = device;
      }

      final combinedDevices = allDevicesMap.values.toList();
      debugPrint(
        'Scan terminé: ${pairedDevices.length} appairés, ${combinedDevices.length} total (avec cache)',
      );

      return combinedDevices;
    } catch (e) {
      debugPrint('Erreur lors du scan des appareils: $e');
      rethrow;
    }
  }

  /// Vide le cache des appareils
  void clearDeviceCache() {
    _cachedDevices.clear();
    _knownMacAddresses.clear();
    debugPrint('Cache des appareils vidé');
  }

  /// Ajoute manuellement un appareil au cache
  void addDeviceToCache(BluetoothInfo device) {
    if (!_knownMacAddresses.contains(device.macAdress)) {
      _knownMacAddresses.add(device.macAdress);
      _cachedDevices.add(device);
      debugPrint('Appareil ajouté manuellement au cache: ${device.name}');
    }
  }

  /// Scan périodique avec cache persistant
  Future<List<BluetoothInfo>> scanDevicesWithCache({Duration? timeout}) async {
    const maxAttempts = 3;
    const delayBetweenAttempts = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        debugPrint('Tentative de scan $attempt/$maxAttempts...');

        final devices = await scanDevices();

        if (devices.isNotEmpty) {
          debugPrint('Scan réussi: ${devices.length} appareils trouvés');
          return devices;
        }

        if (attempt < maxAttempts) {
          debugPrint(
            'Aucun appareil trouvé, nouvelle tentative dans ${delayBetweenAttempts.inSeconds}s...',
          );
          await Future.delayed(delayBetweenAttempts);
        }
      } catch (e) {
        debugPrint('Erreur tentative $attempt: $e');
        if (attempt == maxAttempts) rethrow;
        await Future.delayed(delayBetweenAttempts);
      }
    }

    // Si aucun appareil trouvé après toutes les tentatives, retourner le cache
    debugPrint(
      'Scan échoué, retour du cache: ${_cachedDevices.length} appareils',
    );
    return List.from(_cachedDevices);
  }

  /// Créer un appareil Bluetooth personnalisé (pour les appareils connus)
  BluetoothInfo createCustomDevice(String name, String macAddress) {
    return BluetoothInfo(name: name, macAdress: macAddress);
  }

  /// Se connecte à un appareil Bluetooth
  Future<bool> connectToDevice(String macAddress) async {
    try {
      return await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
    } catch (e) {
      debugPrint('Erreur lors de la connexion à $macAddress: $e');
      return false;
    }
  }

  /// Vérifie l'état de la connexion
  Future<bool> isConnected() async {
    try {
      return await PrintBluetoothThermal.connectionStatus;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de connexion: $e');
      return false;
    }
  }

  /// Se déconnecte de l'appareil
  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    }
  }

  /// Imprime un reçu de paiement
  Future<bool> printReceipt({
    required String schoolName,
    required String schoolAddress,
    required String schoolPhone,
    required String eleveName,
    required String classe,
    required String matricule,
    required String fraisName,
    required List<Map<String, dynamic>> paiements,
    required double montantTotal,
    required double totalPaye,
    required double resteAPayer,
  }) async {
    try {
      final connected = await isConnected();
      if (!connected) {
        throw Exception('Aucune imprimante connectée');
      }

      // Configuration du profil d'impression (58mm)
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      // En-tête
      bytes += generator.setGlobalCodeTable('CP1252');
      bytes += generator.reset();
      bytes += generator.text(
        schoolName,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
        ),
      );
      bytes += generator.text(
        schoolAddress,
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        schoolPhone,
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr();

      // Titre du reçu
      bytes += generator.text(
        'RECU DE PAIEMENT',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
        ),
      );
      bytes += generator.emptyLines(1);

      // Informations élève
      bytes += generator.text('Eleve: $eleveName');
      bytes += generator.text('Classe: $classe');
      if (matricule.isNotEmpty) {
        bytes += generator.text('Matricule: $matricule');
      }
      bytes += generator.text('Frais: $fraisName');
      bytes += generator.hr();

      // Détails des paiements
      bytes += generator.text(
        'DETAIL DES VERSEMENTS',
        styles: const PosStyles(bold: true),
      );
      bytes += generator.emptyLines(1);

      for (final paiement in paiements) {
        bytes += generator.row([
          PosColumn(
            text: paiement['date'] ?? '',
            width: 6,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: '${paiement['montant']} CDF',
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      bytes += generator.hr();

      // Résumé financier
      bytes += generator.row([
        PosColumn(
          text: 'Montant Total:',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '${montantTotal.toStringAsFixed(0)} CDF',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'Total Paye:',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '${totalPaye.toStringAsFixed(0)} CDF',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'Reste a Payer:',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: '${resteAPayer.toStringAsFixed(0)} CDF',
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);

      bytes += generator.hr();

      // Footer
      bytes += generator.text(
        'Merci de votre confiance !',
        styles: const PosStyles(align: PosAlign.center),
      );

      final now = DateTime.now();
      final dateStr =
          '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}/'
          '${now.year} ${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';

      bytes += generator.text(
        'Genere le $dateStr',
        styles: const PosStyles(align: PosAlign.center),
      );

      bytes += generator.text(
        'Ayanna School System',
        styles: const PosStyles(align: PosAlign.center),
      );

      // Coupe du papier
      bytes += generator.cut();

      // Envoi à l'imprimante
      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      debugPrint('Erreur lors de l\'impression: $e');
      return false;
    }
  }

  /// Imprime un test
  Future<bool> printTest() async {
    try {
      final connected = await isConnected();
      if (!connected) {
        throw Exception('Aucune imprimante connectée');
      }

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      bytes += generator.setGlobalCodeTable('CP1252');
      bytes += generator.reset();
      bytes += generator.text(
        'TEST D\'IMPRESSION',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
        ),
      );
      bytes += generator.emptyLines(2);
      bytes += generator.text(
        'Ayanna School System',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        DateTime.now().toString(),
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.emptyLines(3);
      bytes += generator.cut();

      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      debugPrint('Erreur lors du test d\'impression: $e');
      return false;
    }
  }
}
