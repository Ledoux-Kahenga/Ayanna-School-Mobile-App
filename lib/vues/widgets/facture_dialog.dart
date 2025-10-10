import 'package:flutter/material.dart';
import '../../models/entities/eleve.dart';
import '../../models/frais_details.dart';
import '../../theme/ayanna_theme.dart';
import '../../services/bluetooth_print_service.dart';
import 'bluetooth_printer_selector.dart';

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
  final BluetoothPrintService _bluetoothService = BluetoothPrintService();

  @override
  void initState() {
    super.initState();
    print('📍 [FactureDialog] initState appelé');
  }

  @override
  void dispose() {
    print('📍 [FactureDialog] dispose appelé');
    super.dispose();
  }

  Future<void> _showPrinterSelector() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: BluetoothPrinterSelector(
            onPrinterSelected: (macAddress) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Imprimante connectée! Vous pouvez maintenant imprimer.',
                  ),
                  backgroundColor: AyannaColors.successGreen,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _printReceipt() async {
    try {
      // Vérifier d'abord si une imprimante est connectée
      final isConnected = await _bluetoothService.isConnected();

      if (!isConnected) {
        // Afficher le sélecteur d'imprimante
        await _showPrinterSelector();
        return;
      }

      // Préparer les données des paiements
      final paiements = widget.fraisDetails.historiquePaiements
          .map(
            (p) => {
              'date':
                  '${p.datePaiement.day.toString().padLeft(2, '0')}/'
                  '${p.datePaiement.month.toString().padLeft(2, '0')}/'
                  '${p.datePaiement.year.toString().substring(2)}',
              'montant': p.montantPaye.toStringAsFixed(0),
            },
          )
          .toList();

      // Imprimer avec le service Bluetooth
      final success = await _bluetoothService.printReceipt(
        schoolName: 'AYANNA SCHOOL',
        schoolAddress: '14 Av. Bunduki, Q. Plateau, C. Annexe',
        schoolPhone: 'Tél : +243997554905',
        eleveName:
            '${widget.eleve.prenomCapitalized} ${widget.eleve.nomPostnomMaj}',
        classe: 'Classe', // TODO: récupérer le nom de la classe
        matricule: widget.eleve.matricule ?? '',
        fraisName: widget.fraisDetails.frais.nom,
        paiements: paiements,
        montantTotal: widget.fraisDetails.montant,
        totalPaye: widget.fraisDetails.montantPaye,
        resteAPayer: widget.fraisDetails.resteAPayer,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Reçu envoyé à l\'imprimante'
                  : 'Erreur lors de l\'impression',
            ),
            backgroundColor: success ? AyannaColors.successGreen : Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur impression: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
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
            await _printReceipt();
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
