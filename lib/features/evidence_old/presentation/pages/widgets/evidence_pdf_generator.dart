import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:segadi/features/evidence_old/domain/evidence_entity.dart';

class EvidencePdfGenerator {
  static Future<Uint8List> generate({
    required int serviceId,
    required List<EvidenceEntity> evidences,
    required String receiverName,
    required DateTime confirmationDate,
  }) async {
    final pdf = pw.Document();

    for (var page in await buildEvidencePages(evidences)) {
      pdf.addPage(page);
    }

    return pdf.save();
  }

  /// -----------------------------
  static pw.Widget _header(int serviceId) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Evidencias de Servicio',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text('Remisión: $serviceId'),
      ],
    );
  }

  /// -----------------------------
  static pw.Widget _receiverInfo(
    String name,
    DateTime date,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Receptor: $name'),
          pw.Text('Fecha: ${date.toIso8601String().substring(0, 16)}'),
        ],
      ),
    );
  }

  /// -----------------------------
  static Future<List<pw.Page>> buildEvidencePages(
      List<EvidenceEntity> evidences) async {
    List<pw.Page> pages = [];

    for (var e in evidences) {
      final file = File(e.path);

      if (await file.exists()) {
        // 1. Leemos los bytes del archivo temporal solo en este momento
        final bytes = await file.readAsBytes();
        final image = pw.MemoryImage(bytes);

        pages.add(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(24),
            build: (_) {
              return pw.Center(
                child: pw.Image(
                  image,
                  width: PdfPageFormat.a4.width - 48,
                  height: PdfPageFormat.a4.height - 48,
                  fit: pw.BoxFit.contain,
                ),
              );
            },
          ),
        );
      }
    }

    return pages;
  }
}
