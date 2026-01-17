import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class TripPdfGenerator {
  static Future<Uint8List> generate(List<Uint8List> images) async {
    final pdf = pw.Document();

    for (final img in images) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (_) => pw.Center(
            child: pw.Image(
              pw.MemoryImage(img),
              fit: pw.BoxFit.contain,
            ),
          ),
        ),
      );
    }

    return pdf.save();
  }
}
