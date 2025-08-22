import 'package:flutter/material.dart';
import '../models/journal_comptable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class JournalComptableScreen extends StatefulWidget {
  const JournalComptableScreen({Key? key}) : super(key: key);

  @override
  State<JournalComptableScreen> createState() => _JournalComptableScreenState();
}

class _JournalComptableScreenState extends State<JournalComptableScreen> {
  DateTime? dateDebut;
  DateTime? dateFin;
  List<JournalComptable> journalFrais = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJournal();
  }

  Future<void> _loadJournal() async {
    setState(() {
      isLoading = true;
    });
    final dbPath = join(await getDatabasesPath(), 'ayanna_school.db');
    final db = await openDatabase(dbPath);
    String whereClause = '';
    List<dynamic> whereArgs = [];
    if (dateDebut != null && dateFin != null) {
      whereClause =
          'WHERE date(date_operation) >= ? AND date(date_operation) <= ?';
      whereArgs = [
        dateDebut!.toIso8601String().substring(0, 10),
        dateFin!.toIso8601String().substring(0, 10),
      ];
    }
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT id, date_operation, libelle, montant, type_operation FROM journaux_comptables $whereClause ORDER BY date_operation DESC',
      whereArgs,
    );
    setState(() {
      journalFrais = result.map((e) => JournalComptable.fromMap(e)).toList();
      isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isDebut) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2020);
    DateTime lastDate = DateTime(2100);

    if (isDebut && dateFin != null) {
      lastDate = dateFin!;
      if (dateDebut != null) {
        initialDate = dateDebut!;
      } else {
        initialDate = dateFin!;
      }
    } else if (!isDebut && dateDebut != null) {
      firstDate = dateDebut!;
      if (dateFin != null) {
        initialDate = dateFin!;
      } else {
        initialDate = dateDebut!;
      }
    } else {
      if (isDebut && dateDebut != null) initialDate = dateDebut!;
      if (!isDebut && dateFin != null) initialDate = dateFin!;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        if (isDebut) {
          dateDebut = picked;
          if (dateFin != null && picked.isAfter(dateFin!)) {
            dateFin = picked;
          }
        } else {
          dateFin = picked;
          if (dateDebut != null && picked.isBefore(dateDebut!)) {
            dateDebut = picked;
          }
        }
      });
      await _loadJournal();
    }
  }

  Future<void> _exportPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Journal Comptable',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text(
                        'Date',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Libellé',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Montant',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Type',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  ...journalFrais.map(
                    (e) => pw.TableRow(
                      children: [
                        pw.Text('${e.date.day}/${e.date.month}/${e.date.year}'),
                        pw.Text(e.libelle),
                        pw.Text('${e.montant} Fc'),
                        pw.Text(e.type),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal comptable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: isLoading || journalFrais.isEmpty ? null : _exportPDF,
            tooltip: 'Exporter en PDF',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Journal quotidien',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      dateDebut == null
                          ? 'Date début'
                          : '${dateDebut!.day}/${dateDebut!.month}/${dateDebut!.year}',
                    ),
                    onPressed: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      dateFin == null
                          ? 'Date fin'
                          : '${dateFin!.day}/${dateFin!.month}/${dateFin!.year}',
                    ),
                    onPressed: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (journalFrais.isEmpty) {
                        return const Center(
                          child: Text(
                            'Aucune opération comptable trouvée pour la période sélectionnée.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          child: DataTable(
                            columnSpacing: 16,
                            headingRowHeight: 40,
                            dataRowHeight: 48,
                            columns: const [
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Libellé')),
                              DataColumn(label: Text('Montant')),
                              DataColumn(label: Text('Type')),
                            ],
                            rows: journalFrais
                                .map(
                                  (e) => DataRow(
                                    cells: [
                                      DataCell(
                                        Center(
                                          child: Text(
                                            '${e.date.day}/${e.date.month}/${e.date.year}',
                                          ),
                                        ),
                                      ),
                                      DataCell(Center(child: Text(e.libelle))),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            '${e.montant} Fc',
                                            style: TextStyle(
                                              color: e.type == 'Entrée'
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            e.type,
                                            style: TextStyle(
                                              color: e.type == 'Entrée'
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
