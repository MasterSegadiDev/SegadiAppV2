import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class TripPdfGenerator {
  static Future<Uint8List> generate(List<Uint8List> images) async {
    final pdf = pw.Document(
      compress: true, // 🚩 Paso 1: Activar compresión nativa de PDF
    );

    for (final img in images) {
      // Creamos la imagen del PDF
      final pdfImage = pw.MemoryImage(img);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                pdfImage,
                // 🚩 Paso 2: Limitar el renderizado al contenedor para no forzar la memoria
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );
    }

    // 🚩 Paso 3: Guardar y retornar.
    // pdf.save() retorna los bytes finales y libera los objetos internos del pw.Document
    final bytes = await pdf.save();

    return bytes;
  }
}
