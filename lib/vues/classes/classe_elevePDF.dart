// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:ayanna_school/models/models.dart';
// import 'package:intl/intl.dart';

// Future<void> generateFraisPdf(
//   Classe classe,
//   FraisScolaire frais,
//   List<Eleve> eleves,
//   int totalEleves,
//   int enOrdre,
//   int pasEnOrdre,
//   double totalAttendu,
//   double totalRecu,
// ) async {
//   final pdf = pw.Document();
//   final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FC', decimalDigits: 2);

//   // Styles de base
//   final headerStyle = pw.TextStyle(
//     fontWeight: pw.FontWeight.bold,
//     fontSize: 12,
//   );
//   final valueStyle = const pw.TextStyle(fontSize: 12);
//   final titleStyle = pw.TextStyle(
//     fontWeight: pw.FontWeight.bold,
//     fontSize: 18,
//     color: PdfColors.deepOrange,
//   );

//   // Construire le tableau des élèves
//   final eleveTableHeaders = ['Nom', 'Prénom', 'Matricule', 'Statut'];
//   final eleveTableData = eleves.map((e) {
//     // Vérifier si l'élève a payé pour ce frais
//     final statut = e.statut.any((fp) => fp.fraisScolaireId == frais.id)
//         ? 'En ordre'
//         : 'Pas en ordre';
//     return [
//       e.nom,
//       e.prenom ?? '',
//       e.matricule ?? 'N/A',
//       statut,
//     ];
//   }).toList();

//   pdf.addPage(
//     pw.Page(
//       pageFormat: PdfPageFormat.a4,
//       build: (pw.Context context) {
//         return pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             // Titre
//             pw.Text(
//               'Rapport des frais - ${frais.nom} (${classe.nom})',
//               style: titleStyle,
//             ),
//             pw.SizedBox(height: 20),

//             // Tableau de bord
//             pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text('Résumé', style: headerStyle),
//                 pw.Divider(),
//                 _buildSummaryRow(
//                     'Total élèves:', totalEleves.toString(), headerStyle, valueStyle),
//                 _buildSummaryRow(
//                     'En ordre:', enOrdre.toString(), headerStyle, valueStyle),
//                 _buildSummaryRow(
//                     'Pas en ordre:', pasEnOrdre.toString(), headerStyle, valueStyle),
//                 pw.SizedBox(height: 10),
//                 _buildSummaryRow(
//                     'Total attendu:', currencyFormat.format(totalAttendu), headerStyle, valueStyle),
//                 _buildSummaryRow(
//                     'Total reçu:', currencyFormat.format(totalRecu), headerStyle, valueStyle),
//                 _buildSummaryRow(
//                     'Reste à payer:', currencyFormat.format(totalAttendu - totalRecu), headerStyle, valueStyle),
//               ],
//             ),
//             pw.SizedBox(height: 20),
            
//             // Titre du tableau
//             pw.Text(
//               'Liste des élèves et leur statut de paiement',
//               style: headerStyle,
//             ),
//             pw.SizedBox(height: 10),
            
//             // Tableau des élèves
//             pw.Table.fromTextArray(
//               headers: eleveTableHeaders,
//               data: eleveTableData,
//               border: pw.TableBorder.all(color: PdfColors.grey),
//               headerStyle: headerStyle,
//               cellStyle: valueStyle,
//               cellAlignment: pw.Alignment.centerLeft,
//             ),
//           ],
//         );
//       },
//     ),
//   );

//   await Printing.layoutPdf(
//     onLayout: (PdfPageFormat format) async => pdf.save(),
//   );
// }

// // Fonction utilitaire pour construire les lignes du résumé
// pw.Row _buildSummaryRow(
//     String label, String value, pw.TextStyle labelStyle, pw.TextStyle valueStyle) {
//   return pw.Row(
//     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//     children: [
//       pw.Text(label, style: labelStyle),
//       pw.Text(value, style: valueStyle),
//     ],
//   );
// }