import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/evidence_old/presentation/viewmodel/evidence_flow_viewmodel.dart';

class PdfPreviewPage extends StatefulWidget {
  const PdfPreviewPage({super.key});

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  final Color primaryGreen = const Color(0xFF2C522A);
  late EvidenceFlowViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<EvidenceFlowViewModel>();
    _viewModel.addListener(_errorListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_viewModel.pdfBytes == null) _viewModel.buildPdf();
    });
  }

  void _errorListener() {
    if (_viewModel.status == EvidenceFlowStatus.error && mounted) {
      _showErrorDialog(_viewModel.errorMessage ?? "Error desconocido");
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_errorListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EvidenceFlowViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Confirmar Envío',
            style: TextStyle(color: Colors.white)),
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(EvidenceFlowViewModel vm) {
    if (vm.status == EvidenceFlowStatus.processing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Procesando documento..."),
          ],
        ),
      );
    }

    if (vm.pdfBytes == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () => vm.buildPdf(),
          child: const Text("Reintentar generar PDF"),
        ),
      );
    }

    return Column(
      children: [
        if (vm.pdfBytes!.lengthInBytes > 1024 * 1024 * 3)
          Container(
            color: Colors.amber[100],
            padding: const EdgeInsets.all(8),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                    child: Text(
                        "El archivo es un poco grande. Asegúrate de tener buena conexión.")),
              ],
            ),
          ),
        Expanded(
          child: PdfPreview(
            build: (format) async => vm.pdfBytes!,
            canChangePageFormat: false,
            allowPrinting: false,
            allowSharing: false,
            canDebug: false,
            canChangeOrientation: false,
          ),
        ),
        _buildActionFooter(vm),
      ],
    );
  }

  Widget _buildActionFooter(EvidenceFlowViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        //height: ,
        child: ElevatedButton(
          onPressed: vm.isSending ? null : () => _handleSend(vm),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          child: vm.isSending
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Enviar Reporte PDF',
                  style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Future<void> _handleSend(EvidenceFlowViewModel vm) async {
    final success = await vm.sendEvidences();

    if (!mounted) return;

    if (success) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          title: const Text("¡Éxito!"),
          content: const Text("Las evidencias se subieron correctamente."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text("Aceptar"),
            ),
          ],
        ),
      );

      Navigator.of(context)
        ..pop()
        ..pop()
        ..pop(true);
    } else {
      // 🔴 AQUÍ ESTABA TU FALTA
      await showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text("Error"),
          content: Text(vm.errorMessage ?? "Ocurrió un error inesperado"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text("Aceptar"),
            ),
          ],
        ),
      );
    }
  }

  void _showErrorDialog(String m) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Ha ocurrido un error"),
        content: Text(m),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text("Cerrar"))
        ],
      ),
    );
  }
}
