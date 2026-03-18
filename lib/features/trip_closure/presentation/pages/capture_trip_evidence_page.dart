import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/trip_closure/presentation/pages/pdf_preview_page.dart';
import '../viewmodels/trip_closure_viewmodel.dart';

class CaptureTripEvidencePage extends StatefulWidget {
  const CaptureTripEvidencePage({super.key});

  @override
  State<CaptureTripEvidencePage> createState() =>
      _CaptureTripEvidencePageState();
}

class _CaptureTripEvidencePageState extends State<CaptureTripEvidencePage> {
  final Color primaryGreen = const Color(0xFF2C522A);
  late TripClosureViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<TripClosureViewModel>();

    // 🚩 Senior Tip: Escucha los errores de forma reactiva y única para evitar duplicados en la UI
    _viewModel.addListener(_errorListener);
  }

  void _errorListener() {
    if (_viewModel.status == TripClosureStatus.error &&
        _viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      // Limpia el estado de error en el VM después de mostrar el SnackBar
      _viewModel.clearError();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_errorListener);
    // Limpieza de caché de imágenes para evitar fugas de memoria (RAM)
    PaintingBinding.instance.imageCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos cambios del ViewModel para redibujar la Grid
    final vm = context.watch<TripClosureViewModel>();
    final size = MediaQuery.of(context).size;
    final responsiveFontSize = size.width * 0.035;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Captura de Evidencias',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            Text('Remisión: ${vm.serviceId}',
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Contador visual de capturas en el AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${vm.images.length}/5',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: vm.images.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        // 🚩 Optimization: SliverGridDelegateWithFixedCrossAxisCount para mejor rendimiento
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: vm.images.length,
                        itemBuilder: (context, index) {
                          final imagePath = vm.images[index];
                          return _EvidenceCard(
                            key: ValueKey(imagePath),
                            path: imagePath,
                            onRemove: () => vm.removeImage(index),
                          );
                        },
                      ),
              ),

              // Indicador de carga sutil si se está procesando el scanner
              if (vm.status == TripClosureStatus.loading)
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

  Widget _buildActionButtons(TripClosureViewModel vm, double fontSize) {
    final canAddMore = vm.images.length < 5;
    final isLoading = vm.status == TripClosureStatus.loading;

    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: canAddMore ? "Escanear" : "Límite Alcanzado",
            icon: Icons.document_scanner,
            color: Colors.orangeAccent,
            onPressed: (canAddMore && !isLoading) ? vm.captureImage : null,
            fontSize: fontSize,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: "Continuar",
            icon: Icons.arrow_forward,
            color: primaryGreen,
            onPressed: (vm.images.isNotEmpty && !isLoading)
                ? () => _navigateToPreview(vm)
                : null,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  void _navigateToPreview(TripClosureViewModel vm) {
    // Aquí puedes disparar la generación del PDF antes de navegar
    vm.preparePdf().then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PdfPreviewPage(),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_enhance_outlined,
              size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No tienes evidencias capturadas",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 16)),
          const Text("Escanea los documentos para poder generar el reporte PDF",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

/// 🚩 COMPONENTIZACIÓN: Card de evidencia extraído para legibilidad y reusabilidad
class _EvidenceCard extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;

  const _EvidenceCard({super.key, required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(path),
              fit: BoxFit.cover,
              cacheWidth:
                  400, // 🚩 Optimization: Reduce el uso de RAM al redimensionar la imagen en caché
              errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey)),
            ),
            // Botón de eliminar con diseño minimalista
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.black45, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
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
      label: Text(label, style: TextStyle(fontSize: fontSize)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    );
  }
}
