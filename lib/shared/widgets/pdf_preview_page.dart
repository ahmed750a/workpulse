import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfPreviewPage extends StatelessWidget {
  final Uint8List bytes;
  final String title;
  final String fileName;

  const PdfPreviewPage({
    super.key,
    required this.bytes,
    required this.title,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'طباعة / مشاركة',
            icon: const Icon(Icons.print_rounded),
            onPressed: () async {
              await Printing.layoutPdf(
                onLayout: (_) async => bytes,
                name: fileName,
              );
            },
          ),
        ],
      ),
      body: SfPdfViewer.memory(
        bytes,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        pageLayoutMode: PdfPageLayoutMode.continuous,
        interactionMode: PdfInteractionMode.pan,
      ),
    );
  }
}