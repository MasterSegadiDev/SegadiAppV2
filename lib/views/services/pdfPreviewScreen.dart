import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatelessWidget {
  final List<int> pdfData;
  final void Function(BuildContext)? onClose;

  const PdfPreviewScreen({
    Key? key,
    required this.pdfData,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vista previa del PDF"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Confirmar envío",
            onPressed: () {
              Navigator.of(context).pop(true); // ✅ Confirmación
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: "Cancelar",
            onPressed: () {
              onClose?.call(context);
              Navigator.of(context).pop(false); // ❌ Cancelación
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) async => Uint8List.fromList(pdfData),
      ),
    );
  }
}
