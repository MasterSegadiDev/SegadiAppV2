import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/trip_closure/presentation/viewmodels/trip_closure_viewmodel.dart';

class PdfPreviewPage extends StatelessWidget {
  const PdfPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TripClosureViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirmar Documento',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      body: Column(
        children: [
          // Visualizador de PDF
          Expanded(
            child: vm.pdfBytes == null
                ? const Center(child: CircularProgressIndicator())
                : PdfPreview(
                    build: (_) => vm.pdfBytes!,
                    allowPrinting: false,
                    allowSharing: false,
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    maxPageWidth: 700,
                  ),
          ),

          // Botón de Envío Final
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: vm.isSending ? null : () => _handleSend(context, vm),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C522A)),
                child: vm.isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Finalizar y Enviar",
                        style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSend(
      BuildContext context, TripClosureViewModel vm) async {
    // 1. Mostrar un diálogo de carga que NO se pueda cerrar con "atrás"
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF2C522A)),
              SizedBox(height: 16),
              Text("Enviando reporte...",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Esto puede tardar unos segundos",
                  style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );

    final success = await vm.sendTripClosure();

    if (!context.mounted) return;

    // 2. Quitar el diálogo de carga
    Navigator.of(context).pop();

    if (success) {
      // 3. Feedback positivo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Documento enviado con éxito."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 4. Navegación: Salir de PdfPreview y de CaptureEvidence
      Navigator.of(context).pop(); // Cierra Preview
      Navigator.of(context)
          .pop(true); // Regresa a Remisiones con señal de éxito

      // 5. LIMPIEZA FINAL: Esperamos a que las pantallas se destruyan
      Future.delayed(const Duration(milliseconds: 300), () {
        vm.reset();
      });
    } else {
      // 6. Manejo de error si falla el envío
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text("Error de Envío"),
            ],
          ),
          content:
              Text(vm.errorMessage ?? "Error desconocido al subir el PDF."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Reintentar",
                  style: TextStyle(color: Color(0xFF2C522A))),
            ),
          ],
        ),
      );
    }
  }
}
