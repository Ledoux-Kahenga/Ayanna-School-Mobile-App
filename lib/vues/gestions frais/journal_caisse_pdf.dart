import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:ayanna_school/models/models.dart';

Future<void> generateAndPrintJournalPdf(
  List<JournalComptable> entries,
  DateTime date,
  double totalEntrees,
  double totalSorties,
  double solde,
) async {
  final pdf = pw.Document();
  final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'fr_FR');
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FC', decimalDigits: 2);

  // Définir les styles de texte pour le PDF
  final headerStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12);
  final dataStyle = const pw.TextStyle(fontSize: 10);

  // Convertir les données du journal en une liste de listes pour le tableau
  final tableData = [
    ['Heure', 'Libellé', 'Montant', 'Type'],
    ...entries.map((entry) => [
      DateFormat('HH:mm').format(entry.dateOperation),
      entry.libelle,
      currencyFormat.format(entry.montant),
      entry.typeOperation,
    ]),
  ];

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Journal de Caisse - ${dateFormat.format(date)}',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 18,
                color: PdfColors.deepOrange,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Heure', 'Libellé', 'Montant', 'Type'],
              data: tableData.sublist(1),
              headerStyle: headerStyle,
              cellStyle: dataStyle,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              border: pw.TableBorder.all(color: PdfColors.grey400),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 1, color: PdfColors.grey),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total des entrées:', style: headerStyle),
                pw.Text(currencyFormat.format(totalEntrees), style: headerStyle.copyWith(color: PdfColors.green)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total des sorties:', style: headerStyle),
                pw.Text(currencyFormat.format(totalSorties), style: headerStyle.copyWith(color: PdfColors.red)),
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Solde du jour:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.Text(
                  currencyFormat.format(solde),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                    color: solde >= 0 ? PdfColors.blue : PdfColors.red,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  // Utilisez le package 'printing' pour générer le PDF
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}