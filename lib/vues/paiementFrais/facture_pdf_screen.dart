import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class FacturePdfScreen extends StatelessWidget {
  final String pdfPath;
  const FacturePdfScreen({Key? key, required this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Facture PDF')),
      body: PDFView(
        filePath: pdfPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onError: (error) => Center(child: Text('Erreur PDF: $error')),
        onPageError: (page, error) =>
            Center(child: Text('Erreur page $page: $error')),
      ),
    );
  }
}
