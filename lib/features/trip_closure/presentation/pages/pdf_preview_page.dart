import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/trip_closure/presentation/viewmodels/trip_closure_viewmodel.dart';

class PdfPreviewPage extends StatefulWidget {
  const PdfPreviewPage({super.key});

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    try {
      final vm = context.read<TripClosureViewModel>();

      final bytes = await vm.generatePdf();

      if (!mounted) return;

      setState(() {
        _pdfBytes = bytes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TripClosureViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista previa del PDF'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      /// 📄 PDF
                      Expanded(
                        child: PdfPreview(
                          build: (format) async => _pdfBytes!,
                          canChangePageFormat: false,
                          canChangeOrientation: false,
                          allowPrinting: false,
                          allowSharing: false,
                        ),
                      ),

                      /// 🚀 ENVIAR
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: vm.isSending
                                ? null
                                : () async {
                                    final ok = await vm.sendTripClosure(
                                        pdfBytes: _pdfBytes!, id: vm.id);

                                    if (ok && context.mounted) {
                                      Navigator.popUntil(
                                        context,
                                        (route) => route.isFirst,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: vm.isSending
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('Enviar PDF'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
