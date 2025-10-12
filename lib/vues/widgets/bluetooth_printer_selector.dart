import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../services/bluetooth_print_service.dart';
import '../../theme/ayanna_theme.dart';

class BluetoothPrinterSelector extends StatefulWidget {
  final Function(String macAddress)? onPrinterSelected;

  const BluetoothPrinterSelector({Key? key, this.onPrinterSelected})
    : super(key: key);

  @override
  State<BluetoothPrinterSelector> createState() =>
      _BluetoothPrinterSelectorState();
}

class _BluetoothPrinterSelectorState extends State<BluetoothPrinterSelector> {
  final BluetoothPrintService _printService = BluetoothPrintService();
  List<BluetoothInfo> _devices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _connectedDevice;

  @override
  void initState() {
    super.initState();
    _scanDevices();
    _checkCurrentConnection();
  }

  Future<void> _checkCurrentConnection() async {
    final isConnected = await _printService.isConnected();
    if (isConnected) {
      // Si connecté, essayer de récupérer l'info du périphérique connecté
      setState(() {
        _connectedDevice = 'Imprimante connectée';
      });
    }
  }

  Future<void> _scanDevices() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final devices = await _printService.scanDevicesWithCache();
      setState(() {
        _devices = devices;
      });

      if (_devices.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Aucune imprimante trouvée. Vérifiez que l\'imprimante est allumée et appairée.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du scan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _connectToDevice(BluetoothInfo device) async {
    setState(() {
      _isConnecting = true;
    });

    try {
      final success = await _printService.connectToDevice(device.macAdress);

      if (success) {
        setState(() {
          _connectedDevice = device.name;
        });

        if (widget.onPrinterSelected != null) {
          widget.onPrinterSelected!(device.macAdress);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connecté à ${device.name}'),
              backgroundColor: AyannaColors.successGreen,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Échec de la connexion à ${device.name}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _testPrint() async {
    try {
      final success = await _printService.printTest();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Test d\'impression réussi' : 'Échec du test',
            ),
            backgroundColor: success ? AyannaColors.successGreen : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur test impression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    await _printService.disconnect();
    setState(() {
      _connectedDevice = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Déconnecté avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _clearCache() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vider le cache'),
          content: const Text(
            'Voulez-vous effacer toutes les imprimantes mémorisées ?\n\n'
            'Cette action supprimera les imprimantes ajoutées manuellement et celles précédemment découvertes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Vider'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _printService.clearDeviceCache();
      await _scanDevices();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache vidé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _addManualDevice() async {
    final nameController = TextEditingController();
    final macController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une imprimante manuellement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Si votre imprimante n\'apparaît pas dans la liste, vous pouvez l\'ajouter manuellement :',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'imprimante',
                  hintText: 'Ex: Mon Imprimante Thermique',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: macController,
                decoration: const InputDecoration(
                  labelText: 'Adresse MAC',
                  hintText: 'Ex: 00:11:22:33:44:55',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    macController.text.isNotEmpty) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );

    if (result == true &&
        nameController.text.isNotEmpty &&
        macController.text.isNotEmpty) {
      final customDevice = _printService.createCustomDevice(
        nameController.text.trim(),
        macController.text.trim().toUpperCase(),
      );

      _printService.addDeviceToCache(customDevice);

      // Rafraîchir la liste
      await _scanDevices();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imprimante "${nameController.text}" ajoutée'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget _buildDeviceCard(BluetoothInfo device) {
    final isConnected = _connectedDevice == device.name;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: isConnected || _isConnecting
            ? null
            : () => _connectToDevice(device),
        leading: Stack(
          children: [
            Icon(
              isConnected ? Icons.print : Icons.bluetooth,
              color: isConnected ? AyannaColors.successGreen : null,
            ),
            if (isConnected)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AyannaColors.successGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
        title: Text(
          device.name.isNotEmpty ? device.name : 'Appareil sans nom',
          style: TextStyle(
            fontWeight: isConnected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(device.macAdress),
            if (isConnected)
              const Text(
                'Connecté',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isConnected) ...[
              IconButton(
                onPressed: _testPrint,
                icon: const Icon(Icons.print_outlined, size: 20),
                tooltip: 'Test',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                onPressed: _disconnect,
                icon: const Icon(Icons.bluetooth_disabled, size: 20),
                tooltip: 'Déconnecter',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ] else
              IconButton(
                onPressed: _isConnecting
                    ? null
                    : () => _connectToDevice(device),
                icon: _isConnecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bluetooth, size: 20),
                tooltip: _isConnecting ? 'Connexion...' : 'Connecter',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec titre et boutons d'action
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Imprimante Bluetooth',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_connectedDevice != null)
                        Text(
                          'Connecté: $_connectedDevice',
                          style: TextStyle(
                            color: AyannaColors.successGreen,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _isScanning ? null : _scanDevices,
                  icon: _isScanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 20),
                  tooltip: _isScanning ? 'Recherche...' : 'Actualiser',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                IconButton(
                  onPressed: _isScanning ? null : _addManualDevice,
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: 'Ajouter manuellement',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'clear_cache',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all, size: 16),
                          SizedBox(width: 8),
                          Text('Vider le cache'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'clear_cache') {
                      _clearCache();
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // État et informations
            if (_isScanning)
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Recherche d\'imprimantes...'),
                ],
              )
            else if (_devices.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Aucune imprimante trouvée.\nVérifiez que l\'imprimante est allumée, appairée et à portée.',
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      return _buildDeviceCard(_devices[index]);
                    },
                  ),
                ),
              ),

            // Message d'aide déplacé en bas
            if (_devices.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AyannaColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AyannaColors.successGreen),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: AyannaColors.successGreen,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Connectez votre appareil à votre imprimante dans les paramètres Bluetooth du téléphone, puis votre périphérique devrait s\'afficher ici.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
