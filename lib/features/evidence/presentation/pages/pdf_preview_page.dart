import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/evidence/presentation/viewmodel/evidence_flow_viewmodel.dart';
import 'package:segadi/repo/api_status.dart';

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

    // 🚩 Senior Tip: Escuchar errores de forma centralizada
    _viewModel.addListener(_errorListener);

    // Disparamos la generación del PDF solo si no existe uno previo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_viewModel.pdfBytes == null) {
        _viewModel.buildPdf();
      }
    });
  }

  void _errorListener() {
    if (_viewModel.status == EvidenceFlowStatus.error &&
        _viewModel.errorMessage != null &&
        mounted) {
      _showErrorDialog(_viewModel.errorMessage!);
      _viewModel.clearError();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_errorListener);
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Atención'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos watch para reaccionar a los cambios de pdfBytes y status
    final vm = context.watch<EvidenceFlowViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Vista previa',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryGreen,
        elevation: 0,
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(EvidenceFlowViewModel vm) {
    // 1. Estado de carga (Mientras se genera el PDF)
    if (vm.pdfBytes == null && vm.status == EvidenceFlowStatus.scanning) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Si no hay PDF y no está cargando, algo falló
    if (vm.pdfBytes == null) {
      return const Center(
          child: Text(
              "No se pudo generar el PDF. Intenta capturar las fotos de nuevo."));
    }

    // 3. Contenido Principal
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: PdfPreview(
              // Usamos directamente los bytes del VM
              build: (format) async => vm.pdfBytes!,
              canChangePageFormat: false,
              canChangeOrientation: false,
              allowPrinting: false,
              allowSharing: false,
              // Optimización: No mostrar controles innecesarios
              maxPageWidth: 700,
            ),
          ),
          _buildActionFooter(vm),
        ],
      ),
    );
  }

  Widget _buildActionFooter(EvidenceFlowViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: vm.isSending ? null : () => _handleSend(vm),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)),
          ),
          child: vm.isSending
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('Enviar reporte final',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Future<void> _handleSend(EvidenceFlowViewModel vm) async {
    final success = await vm.sendEvidences();

    if (success && mounted) {
      Navigator.of(context)
        ..pop()
        ..pop()
        ..pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Evidencias enviadas con éxito")),
      );
    }
  }
}
