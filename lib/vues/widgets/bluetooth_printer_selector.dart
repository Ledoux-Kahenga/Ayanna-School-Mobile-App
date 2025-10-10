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
      final devices = await _printService.scanDevices();
      setState(() {
        _devices = devices;
      });
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

        widget.onPrinterSelected?.call(device.macAdress);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connecté à ${device.name}'),
              backgroundColor: AyannaColors.successGreen,
            ),
          );
        }
      } else {
        throw Exception('Échec de la connexion');
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

  Future<void> _disconnect() async {
    await _printService.disconnect();
    setState(() {
      _connectedDevice = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Déconnecté'),
          backgroundColor: AyannaColors.orange,
        ),
      );
    }
  }

  Future<void> _testPrint() async {
    final success = await _printService.printTest();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Test envoyé' : 'Échec du test'),
          backgroundColor: success ? AyannaColors.successGreen : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.print, color: AyannaColors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Imprimante Bluetooth',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_connectedDevice != null) ...[
                  IconButton(
                    onPressed: _testPrint,
                    icon: const Icon(Icons.print_outlined),
                    tooltip: 'Test d\'impression',
                  ),
                  IconButton(
                    onPressed: _disconnect,
                    icon: const Icon(Icons.bluetooth_disabled),
                    tooltip: 'Déconnecter',
                  ),
                ],
                IconButton(
                  onPressed: _isScanning ? null : _scanDevices,
                  icon: _isScanning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  tooltip: 'Scanner les appareils',
                ),
              ],
            ),

            if (_connectedDevice != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AyannaColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AyannaColors.successGreen),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bluetooth_connected,
                      color: AyannaColors.successGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Connecté: $_connectedDevice',
                        style: const TextStyle(
                          color: AyannaColors.successGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            if (_devices.isEmpty && !_isScanning)
              const Text(
                'Aucun appareil Bluetooth trouvé.\nAssurez-vous que votre imprimante est allumée et en mode appairage.',
                textAlign: TextAlign.center,
              )
            else
              ..._devices
                  .map(
                    (device) => ListTile(
                      leading: const Icon(
                        Icons.print,
                        color: AyannaColors.orange,
                      ),
                      title: Text(
                        device.name.isNotEmpty
                            ? device.name
                            : 'Appareil inconnu',
                      ),
                      subtitle: Text(device.macAdress),
                      trailing: _isConnecting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : _connectedDevice == device.name
                          ? const Icon(
                              Icons.check_circle,
                              color: AyannaColors.successGreen,
                            )
                          : const Icon(Icons.bluetooth),
                      onTap: _connectedDevice == device.name || _isConnecting
                          ? null
                          : () => _connectToDevice(device),
                    ),
                  )
                  .toList(),
          ],
        ),
      ),
    );
  }
}
