import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/evidence/domain/evidence_entity.dart';
import 'package:segadi/features/evidence/presentation/pages/pdf_preview_page.dart';
import 'package:segadi/features/evidence/presentation/viewmodel/evidence_flow_viewmodel.dart';

class CaptureEvidencePage extends StatefulWidget {
  const CaptureEvidencePage({super.key});

  @override
  State<CaptureEvidencePage> createState() => _CaptureEvidencePageState();
}

class _CaptureEvidencePageState extends State<CaptureEvidencePage> {
  final Color primaryGreen = const Color(0xFF2C522A);
  late EvidenceFlowViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<EvidenceFlowViewModel>();

    // 🚩 Senior Tip: Escucha los errores de forma reactiva y única
    _viewModel.addListener(_errorListener);
  }

  void _errorListener() {
    if (_viewModel.status == EvidenceFlowStatus.error &&
        _viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Es vital limpiar el error en el VM después de mostrarlo para que no se repita
      _viewModel.clearError();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_errorListener); // No olvides removerlo
    // Resetear el flujo al salir es buena práctica de limpieza
    _viewModel.initCaptureFlow(notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos cambios para la UI
    final vm = context.watch<EvidenceFlowViewModel>();
    final size = MediaQuery.of(context).size;
    final responsiveFontSize = size.width * 0.035;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Enviar Evidencias',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: vm.evidences.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        // 🚩 Optimization: Usar fixed size para que el scroll sea suave
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: vm.evidences.length,
                        itemBuilder: (context, index) {
                          final evidence = vm.evidences[index];

                          // 🚩 Senior Tip: Usar ValueKey ayuda a Flutter a reciclar widgets correctamente
                          return _EvidenceCard(
                            key: ValueKey(evidence.path),
                            evidence: evidence,
                            onRemove: () => vm.removeEvidence(index),
                          );
                        },
                      ),
              ),
              if (vm.status == EvidenceFlowStatus.scanning)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              const SizedBox(height: 16),
              _buildActionButtons(vm, responsiveFontSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(EvidenceFlowViewModel vm, double fontSize) {
    final isScanning = vm.status == EvidenceFlowStatus.scanning;

    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: vm.canScanMore ? "Escanear" : "Límite Máximo",
            icon: Icons.document_scanner,
            color: Colors.orangeAccent,
            onPressed:
                (vm.canScanMore && !isScanning) ? vm.scanFromCamera : null,
            fontSize: fontSize,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: "Continuar",
            icon: Icons.arrow_forward,
            color: primaryGreen,
            // 🚩 Lógica: Solo continuar si hay evidencias y no se está escaneando
            onPressed: (vm.hasEvidences && !isScanning)
                ? () => _navigateToPreview(vm)
                : null,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  void _navigateToPreview(EvidenceFlowViewModel vm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const PdfPreviewPage(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      // Añadido Center para mejor alineación
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_enhance_outlined,
              size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Sin evidencias",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text("Escanea tus documentos para el reporte",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

/// 🚩 COMPONENTIZACIÓN: Un Senior extrae widgets complejos para legibilidad
class _EvidenceCard extends StatelessWidget {
  final EvidenceEntity evidence;
  final VoidCallback onRemove;

  const _EvidenceCard(
      {super.key, required this.evidence, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(evidence.path),
            fit: BoxFit.cover,
            cacheWidth: 350, // Optimización de RAM
            // Manejo de error si el archivo fue borrado
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.cancel, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final double fontSize;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: fontSize + 4),
      label: Text(label,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
