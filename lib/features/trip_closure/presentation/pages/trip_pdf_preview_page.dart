import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/evidence/presentation/pages/pdf_preview_page.dart';
import 'package:segadi/features/trip_closure/presentation/viewmodels/trip_closure_viewmodel.dart';

class TripPdfPreviewPage extends StatefulWidget {
  final int id;
  final String serviceId;

  const TripPdfPreviewPage({
    super.key,
    required this.id,
    required this.serviceId,
  });

  @override
  State<TripPdfPreviewPage> createState() => _TripPdfPreviewPageState();
}

class _TripPdfPreviewPageState extends State<TripPdfPreviewPage> {
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    final vm = context.read<TripClosureViewModel>();

    final bytes = await vm.generatePdf();

    setState(() => _pdfBytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TripClosureViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Vista previa PDF')),
      body: _pdfBytes == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: PdfPreviewPage(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: vm.isSending
                        ? null
                        : () async {
                            final ok = await vm.sendTripClosure(
                              pdfBytes: _pdfBytes!,
                              id: widget.id,
                            );

                            if (ok && context.mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                    child: const Text('Enviar evidencias'),
                  ),
                ),
              ],
            ),
    );
  }
}
