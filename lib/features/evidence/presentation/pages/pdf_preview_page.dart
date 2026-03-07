import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/evidence/presentation/viewmodel/evidence_flow_viewmodel.dart';

class PdfPreviewPage extends StatefulWidget {
  const PdfPreviewPage({super.key});

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  final Color primaryGreen = const Color(0xFF2C522A);

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
      final vm = context.read<EvidenceFlowViewModel>();

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
    final vm = context.watch<EvidenceFlowViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Vista previa del PDF a enviar',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryGreen,
        elevation: 0,
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
                            // onPressed: vm.isSending
                            //     ? null
                            //     : () async {
                            //         final ok =
                            //             await vm.sendEvidences(_pdfBytes!);

                            //         if (ok && context.mounted) {
                            //           // 1. Limpiamos el stack hasta llegar al 'nombre' que pusimos
                            //           // Esto te va a dejar en la pantalla de Confirmación (Firma)
                            //           Navigator.of(context).popUntil(
                            //               ModalRoute.withName(
                            //                   '/detail_service'));

                            //           // 2. HACEMOS UN POP EXTRA
                            //           // Como ya estamos en la "base" del flujo de evidencia,
                            //           // este último pop nos saca de ahí y nos mete al Detalle.
                            //           if (context.mounted) {
                            //             Navigator.of(context).pop();
                            //           }
                            //         }
                            //       },
                            onPressed: vm.isSending
                                ? null
                                : () async {
                                    final ok =
                                        await vm.sendEvidences(_pdfBytes!);

                                    if (ok && context.mounted) {
                                      // ... tu lógica de Navigator.popUntil ...
                                      Navigator.of(context).popUntil(
                                          ModalRoute.withName(
                                              '/detail_service'));
                                    } else if (!ok && context.mounted) {
                                      // MOSTRAR EL ERROR REAL DEL API
                                      // ScaffoldMessenger.of(context)
                                      //     .showSnackBar(
                                      //   SnackBar(
                                      //     content: Text(vm.errorMessage ??
                                      //         'Error al enviar'),
                                      //     backgroundColor: Colors.red,
                                      //     behavior: SnackBarBehavior.floating,
                                      //     duration: const Duration(
                                      //         seconds:
                                      //             5), // Más tiempo para que lean
                                      //   ),
                                      // );
                                      showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                          titlePadding: const EdgeInsets.only(
                                              top: 24, left: 24, right: 24),
                                          title: Row(
                                            children: [
                                              Icon(Icons.error_outline,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error),
                                              const SizedBox(width: 12),
                                              const Text(
                                                  'Error al enviar las evidencias',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  )),
                                            ],
                                          ),
                                          content: Text(
                                            vm.errorMessage ??
                                                'Ha ocurrido un error inesperado al enviar las evidencias.',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          actionsPadding:
                                              const EdgeInsets.all(16),
                                          actions: [
                                            FilledButton.tonal(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cerrar'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: vm.isSending
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('Enviar evidencias',
                                    style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
