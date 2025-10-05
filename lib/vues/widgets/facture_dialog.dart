import 'package:flutter/material.dart';
import '../../models/entities/eleve.dart';
import '../../models/frais_details.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../theme/ayanna_theme.dart';

class FactureDialog extends StatelessWidget {
  final Eleve eleve;
  final FraisDetails fraisDetails;

  const FactureDialog({
    super.key,
    required this.eleve,
    required this.fraisDetails,
  });

  @override
  Widget build(BuildContext context) {
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
            final pdf = pw.Document();
            pdf.addPage(
              pw.Page(
                build: (pw.Context ctx) => pw.Container(
                  padding: const pw.EdgeInsets.all(24),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F4F4F4'), // Gris Clair (Fond)
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(12),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Facture',
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex(
                            '#FFA500',
                          ), // Orange Principal
                        ),
                      ),
                      pw.SizedBox(height: 18),
                      pw.Text(
                        'Élève : ${eleve.prenom} ${eleve.nom}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColor.fromHex('#333333'),
                        ),
                      ),
                      if (eleve.matricule != null)
                        pw.Text(
                          'Matricule : ${eleve.matricule!}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColor.fromHex('#333333'),
                          ),
                        ),
                      pw.Divider(),
                      pw.Text(
                        'Frais : ${fraisDetails.frais.nom}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#333333'),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Montant total : ${fraisDetails.frais.montant.toStringAsFixed(0)} FCFA',
                        style: pw.TextStyle(color: PdfColor.fromHex('#333333')),
                      ),
                      pw.Text(
                        'Payé : ${fraisDetails.montantPaye.toStringAsFixed(0)} FCFA',
                        style: pw.TextStyle(color: PdfColor.fromHex('#28A745')),
                      ),
                      pw.Text(
                        'Reste à payer : ${fraisDetails.resteAPayer.toStringAsFixed(0)} FCFA',
                        style: pw.TextStyle(color: PdfColor.fromHex('#FFA500')),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Date : ${DateTime.now().toIso8601String().substring(0, 10)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor.fromHex('#333333'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            await Printing.layoutPdf(onLayout: (format) async => pdf.save());
          },
        ),
      ],
    );
  }
}
