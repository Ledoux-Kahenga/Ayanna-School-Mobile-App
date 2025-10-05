import 'package:flutter/material.dart';
import '../../models/entities/eleve.dart';
import '../../models/frais_details.dart';
import '../../theme/ayanna_theme.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart' as thermal;
import 'dart:async';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    _requestBluetoothPermissions();
  }

  @override
  void dispose() {
    _devicesStreamSubscription?.cancel();
    super.dispose();
  }

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

  void _startScan() {
    _devicesStreamSubscription = _flutherThermalPrinterPlugin.devicesStream
        .listen((devices) {
          if (mounted) {
            setState(() {
              printers = devices;
            });
          }
        });
  }

  Future<void> _showReceiptWidget(
    Eleve eleve,
    FraisDetails fraisDetails,
  ) async {
    if (printers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aucune imprimante trouvée. Assurez-vous que l\'imprimante est connectée.',
          ),
        ),
      );
      return;
    }

    // Si plusieurs imprimantes, afficher un dialogue de sélection
    thermal.Printer? selectedPrinter;
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
        return; // L'utilisateur a annulé
      }
    } else {
      selectedPrinter = printers[0];
    }

    await _flutherThermalPrinterPlugin.printWidget(
      context,
      printer: selectedPrinter,
      widget: FactureReceiptWidget(eleve: eleve, fraisDetails: fraisDetails),
    );
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
    final dateFormat = DateFormat('dd/MM/yyyy');
    final numberFormat = NumberFormat("#,##0", "fr_FR");

    return SizedBox(
      width: 550,
      child: Material(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo simple
              Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AyannaColors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'Logo',
                      style: TextStyle(
                        color: AyannaColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // En-tête de l'école
              const Text(
                'Ayanna School',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Divider(thickness: 2, height: 20),

              // Titre
              const Center(
                child: Text(
                  'RECU DE PAIEMENT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AyannaColors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Infos Eleve et Frais
              Text(
                'Eleve : ${eleve.nomPostnomMaj} ${eleve.prenomCapitalized}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Classe : ${eleve.classeNom ?? "-"}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Frais concerne : ${fraisDetails.frais.nom}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Historique des paiements
              const Text(
                'Details des paiements :',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),

              // Table header
              Container(
                padding: const EdgeInsets.all(8),
                color: AyannaColors.orange,
                child: const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AyannaColors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Montant Paye',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AyannaColors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Caissier',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AyannaColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Table rows
              ...fraisDetails.historiquePaiements.map(
                (p) => Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AyannaColors.lightGrey),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(dateFormat.format(p.datePaiement)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${numberFormat.format(p.montantPaye)} FCFA',
                        ),
                      ),
                      const Expanded(child: Text('Admin')),
                    ],
                  ),
                ),
              ),

              const Divider(height: 20),

              // Totaux et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Statut : ${fraisDetails.statut.replaceAll('_', ' ').toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: fraisDetails.statut == 'en_ordre'
                          ? AyannaColors.successGreen
                          : fraisDetails.statut == 'partiellement_paye'
                          ? AyannaColors.orange
                          : Colors.red,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Paye : ${numberFormat.format(fraisDetails.montantPaye)} FCFA',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reste a Payer : ${numberFormat.format(fraisDetails.resteAPayer)} FCFA',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Message de remerciement
              const Center(
                child: Text(
                  'Merci pour votre paiement.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AyannaColors.darkGrey,
                  ),
                ),
              ),

              // Pied de page
              const SizedBox(height: 20),
              const Divider(),
              Center(
                child: Text(
                  'Genere par Ayanna School - ${dateFormat.format(DateTime.now())}',
                  style: const TextStyle(
                    fontSize: 8,
                    color: AyannaColors.darkGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
