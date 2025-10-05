import 'package:flutter/material.dart';
import '../../models/entities/eleve.dart';
import '../../models/frais_details.dart';
import '../../theme/ayanna_theme.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart' as thermal;
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class FactureDialog extends StatefulWidget {
  final Eleve eleve;
  final FraisDetails fraisDetails;

  const FactureDialog({
    super.key,
    required this.eleve,
    required this.fraisDetails,
  });

  @override
  State<FactureDialog> createState() => _FactureDialogState();
}

class _FactureDialogState extends State<FactureDialog> {
  final _flutherThermalPrinterPlugin = FlutterThermalPrinter.instance;
  List<thermal.Printer> printers = [];
  StreamSubscription<List<thermal.Printer>>? _devicesStreamSubscription;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    print('📍 [FactureDialog] initState appelé');
    print('📍 [FactureDialog] Appel de _requestBluetoothPermissions()');
    _requestBluetoothPermissions();
  }

  @override
  void dispose() {
    print('📍 [FactureDialog] dispose appelé, annulation du stream');
    _devicesStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _requestBluetoothPermissions() async {
    print('📍 [FactureDialog] Début de la demande de permissions Bluetooth...');

    // Sur Android 12+ (API 31+), on utilise bluetoothConnect et bluetoothScan
    // Sur Android < 12, on utilise bluetooth et location
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    print('📍 [FactureDialog] Statuts des permissions:');
    statuses.forEach((permission, status) {
      print('   - ${permission.toString()}: ${status.toString()}');
    });

    // Vérifier les permissions essentielles selon la version Android
    bool bluetoothConnectGranted =
        statuses[Permission.bluetoothConnect]?.isGranted ?? false;
    bool bluetoothScanGranted =
        statuses[Permission.bluetoothScan]?.isGranted ?? false;
    bool locationGranted = statuses[Permission.location]?.isGranted ?? false;

    // Sur Android 12+, on a besoin de bluetoothConnect et bluetoothScan
    // La location est optionnelle si on utilise neverForLocation
    bool permissionsOk = bluetoothConnectGranted && bluetoothScanGranted;

    print('📍 [FactureDialog] Analyse des permissions:');
    print('   - bluetoothConnect: $bluetoothConnectGranted');
    print('   - bluetoothScan: $bluetoothScanGranted');
    print('   - location: $locationGranted');
    print('   - Permissions OK: $permissionsOk');

    if (permissionsOk) {
      print(
        '✅ [FactureDialog] Permissions essentielles accordées, lancement du scan...',
      );
      _startScan();
    } else {
      print('❌ [FactureDialog] Permissions essentielles refusées');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permissions Bluetooth requises pour l\'impression thermique',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _startScan() async {
    print('📍 [FactureDialog] Début du scan des imprimantes...');

    setState(() {
      _isScanning = true;
    });

    try {
      // D'abord écouter le stream
      print('📍 [FactureDialog] Configuration du listener devicesStream...');
      _devicesStreamSubscription = _flutherThermalPrinterPlugin.devicesStream.listen(
        (devices) {
          print(
            '📡 [FactureDialog] Stream déclenché avec ${devices.length} imprimante(s)',
          );
          if (mounted) {
            setState(() {
              printers = devices;
              print(
                '✅ [FactureDialog] Liste mise à jour: ${devices.length} imprimante(s)',
              );
              for (var printer in devices) {
                print(
                  '   🖨️  ${printer.name} (${printer.address}) - Type: ${printer.connectionType}',
                );
              }
            });
          } else {
            print('⚠️ [FactureDialog] Widget non monté, mise à jour ignorée');
          }
        },
        onError: (error) {
          print('❌ [FactureDialog] Erreur dans le stream: $error');
        },
        cancelOnError: false,
      );

      print(
        '📍 [FactureDialog] Listener configuré, lancement de getPrinters()...',
      );

      // Puis lancer la découverte des imprimantes Bluetooth
      await _flutherThermalPrinterPlugin.getPrinters(
        refreshDuration: const Duration(seconds: 2),
        connectionTypes: [thermal.ConnectionType.BLE],
      );

      print(
        '✅ [FactureDialog] getPrinters() terminé, attente des résultats dans le stream...',
      );

      // Attendre 8 secondes pour laisser le temps au scan de trouver les imprimantes
      await Future.delayed(const Duration(seconds: 8));

      print(
        '⏹️ [FactureDialog] Fin de l\'attente du scan, ${printers.length} imprimante(s) trouvée(s)',
      );

      _flutherThermalPrinterPlugin.stopScan();

      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    } catch (e) {
      print('❌ [FactureDialog] Erreur lors du scan: $e');
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _showReceiptWidget(
    Eleve eleve,
    FraisDetails fraisDetails,
  ) async {
    print('📍 [FactureDialog] _showReceiptWidget appelé');
    print(
      '📍 [FactureDialog] Nombre d\'imprimantes disponibles: ${printers.length}',
    );
    print('📍 [FactureDialog] Scan en cours: $_isScanning');

    // Si le scan est en cours, afficher un message et attendre
    if (_isScanning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⏳ Recherche d\'imprimantes en cours, veuillez patienter...',
          ),
          duration: Duration(seconds: 2),
        ),
      );
      print(
        '⚠️ [FactureDialog] Scan en cours, impression refusée temporairement',
      );
      return;
    }

    if (printers.isEmpty) {
      print('❌ [FactureDialog] Aucune imprimante dans la liste');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aucune imprimante trouvée. Assurez-vous que l\'imprimante est allumée et à portée.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    print('✅ [FactureDialog] Imprimantes disponibles:');
    for (var p in printers) {
      print('   🖨️  ${p.name} (${p.address})');
    }

    // Si plusieurs imprimantes, afficher un dialogue de sélection
    thermal.Printer? selectedPrinter;
    if (printers.length > 1) {
      print(
        '📍 [FactureDialog] Plusieurs imprimantes, affichage du dialogue de sélection...',
      );
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
                    leading: const Icon(
                      Icons.print,
                      color: AyannaColors.orange,
                    ),
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

      if (selectedPrinter == null) {
        print('⚠️ [FactureDialog] Sélection annulée par l\'utilisateur');
        return; // L'utilisateur a annulé
      }
      print(
        '✅ [FactureDialog] Imprimante sélectionnée: ${selectedPrinter.name}',
      );
    } else {
      selectedPrinter = printers[0];
      print(
        '✅ [FactureDialog] Une seule imprimante, sélection automatique: ${selectedPrinter.name}',
      );
    }

    print(
      '📍 [FactureDialog] Début de l\'impression sur ${selectedPrinter.name}...',
    );
    print('📍 [FactureDialog] Adresse: ${selectedPrinter.address}');
    print('📍 [FactureDialog] Type: ${selectedPrinter.connectionType}');
    print('📍 [FactureDialog] isConnected: ${selectedPrinter.isConnected}');

    try {
      // Vérifier si l'imprimante est déjà connectée
      if (selectedPrinter.isConnected != true) {
        print(
          '📍 [FactureDialog] Imprimante non connectée, connexion en cours...',
        );

        // Connecter à l'imprimante
        final isConnected = await _flutherThermalPrinterPlugin.connect(
          selectedPrinter,
        );
        print('📍 [FactureDialog] Résultat de la connexion: $isConnected');

        if (!isConnected) {
          print('❌ [FactureDialog] Échec de la connexion à l\'imprimante');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Impossible de se connecter à l\'imprimante'),
              ),
            );
          }
          return;
        }
        print('✅ [FactureDialog] Connexion réussie à l\'imprimante');
      } else {
        print('✅ [FactureDialog] Imprimante déjà connectée');
      }

      print('📍 [FactureDialog] Génération du widget de reçu...');
      final receiptWidget = FactureReceiptWidget(
        eleve: eleve,
        fraisDetails: fraisDetails,
      );
      print('✅ [FactureDialog] Widget de reçu généré');

      print('📍 [FactureDialog] Envoi à l\'imprimante...');
      await _flutherThermalPrinterPlugin.printWidget(
        context,
        printer: selectedPrinter,
        widget: receiptWidget,
      );
      print('✅ [FactureDialog] Impression terminée avec succès');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impression en cours...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ [FactureDialog] Erreur lors de l\'impression: $e');
      print('❌ [FactureDialog] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur d\'impression: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eleve = widget.eleve;
    final fraisDetails = widget.fraisDetails;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.receipt_long, color: AyannaColors.orange, size: 28),
          const SizedBox(width: 8),
          Text(
            'Facture',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AyannaColors.darkGrey,
            ),
          ),
        ],
      ),
      content: Card(
        color: AyannaColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    color: AyannaColors.selectionBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${eleve.prenom} ${eleve.nom}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AyannaColors.darkGrey,
                    ),
                  ),
                ],
              ),
              if (eleve.matricule != null)
                Padding(
                  padding: const EdgeInsets.only(left: 26.0, top: 2),
                  child: Text(
                    'Matricule : ${eleve.matricule!}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AyannaColors.darkGrey,
                    ),
                  ),
                ),
              const Divider(height: 18, thickness: 1),
              Row(
                children: [
                  const Icon(
                    Icons.school,
                    color: AyannaColors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      fraisDetails.frais.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AyannaColors.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    color: AyannaColors.successGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Montant total : ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AyannaColors.darkGrey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${fraisDetails.frais.montant.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AyannaColors.darkGrey,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AyannaColors.selectionBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Payé : ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AyannaColors.darkGrey,
                    ),
                  ),
                  Text(
                    '${fraisDetails.montantPaye.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AyannaColors.darkGrey,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: AyannaColors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Reste à payer : ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AyannaColors.darkGrey,
                    ),
                  ),
                  Text(
                    '${fraisDetails.resteAPayer.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AyannaColors.darkGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: AyannaColors.selectionBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Date : ${DateTime.now().toIso8601String().substring(0, 10)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AyannaColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.print),
          label: const Text('Imprimer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AyannaColors.orange,
            foregroundColor: AyannaColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            await _showReceiptWidget(eleve, fraisDetails);
          },
        ),
      ],
    );
  }
}

class FactureReceiptWidget extends StatelessWidget {
  final Eleve eleve;
  final FraisDetails fraisDetails;

  const FactureReceiptWidget({
    Key? key,
    required this.eleve,
    required this.fraisDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format date simple SANS locale lourde
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return SizedBox(
      width: 384,
      child: Material(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // En-tête simple
              const Text(
                'Ayanna School',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              const Text(
                'RECU DE PAIEMENT',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Infos élève (alignées à gauche)
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eleve: ${eleve.nomPostnomMaj} ${eleve.prenomCapitalized}',
                      style: const TextStyle(fontSize: 8),
                    ),
                    Text(
                      'Classe: ${eleve.classeNom ?? "-"}',
                      style: const TextStyle(fontSize: 8),
                    ),
                    Text(
                      'Frais: ${fraisDetails.frais.nom}',
                      style: const TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Titre paiements
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Paiements:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                ),
              ),
              const SizedBox(height: 4),

              // En-têtes SANS Container/Colors.grey
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Text(
                        'Montant',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        'Agent',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lignes SIMPLIFIÉES
              ...fraisDetails.historiquePaiements.map((p) {
                final pDate = p.datePaiement;
                final pDateStr =
                    '${pDate.day.toString().padLeft(2, '0')}/${pDate.month.toString().padLeft(2, '0')}/${pDate.year}';
                final montant = p.montantPaye.toStringAsFixed(0);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          pDateStr,
                          style: const TextStyle(fontSize: 7),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          '$montant CDF',
                          style: const TextStyle(fontSize: 7),
                        ),
                      ),
                      const SizedBox(
                        width: 80,
                        child: Text('Admin', style: TextStyle(fontSize: 7)),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),

              // Totaux SIMPLIFIÉS
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statut: ${fraisDetails.statut.replaceAll('_', ' ').toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total Paye: ${fraisDetails.montantPaye.toStringAsFixed(0)} CDF',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Reste a Payer: ${fraisDetails.resteAPayer.toStringAsFixed(0)} CDF',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Footer
              const Text(
                'Merci pour votre paiement.',
                style: TextStyle(fontSize: 7),
              ),
              const SizedBox(height: 4),
              Text(
                'Genere par Ayanna School - $dateStr',
                style: const TextStyle(fontSize: 6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
