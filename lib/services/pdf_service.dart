import 'dart:typed_data';
import 'package:ayanna_school/models/entities/eleve.dart';
import 'package:ayanna_school/models/frais_details.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static Future<Uint8List> generateRecuPdf(
    FraisDetails fraisDetail,
    Eleve eleve, {
    String? entrepriseNom,
    String? devise,
  }) async {
    final doc = pw.Document();
    // Valeurs par défaut si non fournies
    final entrepriseNomFinal = entrepriseNom ?? 'Ayanna School';
    final deviseFinal = devise ?? 'CDF';
    final dateFormat = DateFormat('dd/MM/yyyy');

    // J'ai ajouté ces couleurs pour un style plus professionnel
    final PdfColor primaryColor = PdfColors.orange;
    final PdfColor accentColor = PdfColors.grey500;
    final PdfColor successColor = PdfColors.green;
    final PdfColor warningColor = PdfColors.orange;
    final PdfColor dangerColor = PdfColors.red;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo simple
              pw.Center(
                child: pw.Container(
                  width: 50,
                  height: 50,
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.orange,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'Logo',
                      style: pw.TextStyle(
                        color: PdfColors.white,

                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 8),

              // En-tête de l'école
              pw.Text(
                entrepriseNomFinal,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              pw.Divider(thickness: 2, height: 20, color: accentColor),

              // Titre
              pw.Center(
                child: pw.Text(
                  'RECU DE PAIEMENT',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Infos Eleve et Frais
              pw.Text(
                'Eleve : ${eleve.nomPostnomMaj} ${eleve.prenomCapitalized}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Classe : ${eleve.classeNom ?? "-"}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Frais concerne : ${fraisDetail.frais.nom}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 16),

              // Historique des paiements
              pw.Text(
                'Details des paiements :',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                cellAlignment: pw.Alignment.centerLeft,
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(color: primaryColor),
                headers: ['Date', 'Montant Paye', 'Caissier'],
                data: fraisDetail.historiquePaiements
                    .map(
                      (p) => [
                        p.datePaiement,
                        '${NumberFormat("#,##0", "fr_FR").format(p.montantPaye)} $deviseFinal',
                        'Admin',
                      ],
                    )
                    .toList(),
              ),
              pw.Divider(height: 20),

              // Totaux et statut
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Statut : ${fraisDetail.statut.replaceAll('_', ' ').toUpperCase()}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: fraisDetail.statut == 'en_ordre'
                          ? successColor
                          : fraisDetail.statut == 'partiellement_paye'
                          ? warningColor
                          : dangerColor,
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Total Paye : ${NumberFormat("#,##0", "fr_FR").format(fraisDetail.montantPaye)} $deviseFinal',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Reste a Payer : ${NumberFormat("#,##0", "fr_FR").format(fraisDetail.resteAPayer)} $deviseFinal',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Message de remerciement
              pw.Center(
                child: pw.Text(
                  'Merci pour votre paiement.',
                  style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey,
                  ),
                ),
              ),

              // Pied de page
              pw.Spacer(),
              pw.Divider(color: accentColor),
              pw.Center(
                child: pw.Text(
                  'Genere par Ayanna School - ${dateFormat.format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
    return doc.save();
  }
}
