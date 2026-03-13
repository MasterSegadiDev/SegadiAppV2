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
        title: const Text('Confirmar Documento'),
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
                    : const Text("FINALIZAR Y ENVIAR",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSend(
      BuildContext context, TripClosureViewModel vm) async {
    final success = await vm.sendTripClosure();

    if (!context.mounted) return;

    if (success) {
      // Limpiamos el stack y volvemos al inicio (donde están las remisiones)
      Navigator.of(context).popUntil((route) => route.isFirst);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("✅ EIR enviado correctamente"),
            backgroundColor: Colors.green),
      );
    } else {
      // Mostrar error si falla
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text(vm.errorMessage ?? "Ocurrió un error inesperado"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"))
          ],
        ),
      );
    }
  }
}
