import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/trip_closure_viewmodel.dart';

class CaptureTripEvidencePage extends StatelessWidget {
  const CaptureTripEvidencePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el ViewModel global
    final vm = context.watch<TripClosureViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Evidencias EIR - ${vm.serviceId}'),
        backgroundColor: const Color(0xFF2C522A),
      ),
      body: Column(
        children: [
          // 1. Grid de imágenes con scroll
          Expanded(
            child: vm.images.isEmpty ? _buildEmptyState() : _ImagesGrid(vm: vm),
          ),

          // 2. Panel de control inferior
          _BottomPanel(vm: vm),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.camera_enhance_outlined, size: 70, color: Colors.grey),
          SizedBox(height: 16),
          Text("No has capturado evidencias",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ImagesGrid extends StatelessWidget {
  final TripClosureViewModel vm;
  const _ImagesGrid({required this.vm});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: vm.images.length,
      itemBuilder: (_, i) => Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(vm.images[i], fit: BoxFit.cover),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: vm.isSending ? null : () => vm.removeImage(i),
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.remove_circle, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final TripClosureViewModel vm;
  const _BottomPanel({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          // Botón Escanear
          Expanded(
            child: OutlinedButton.icon(
              onPressed: vm.isSending ? null : () => vm.captureImage(),
              icon: vm.isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.document_scanner),
              label: const Text("Escanear"),
            ),
          ),
          const SizedBox(width: 12),
          // Botón Continuar
          Expanded(
            child: ElevatedButton(
              onPressed: (vm.images.isEmpty || vm.isSending)
                  ? null
                  : () async {
                      await vm.preparePdf();
                      if (context.mounted) {
                        Navigator.pushNamed(context, '/pdf_preview');
                      }
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C522A)),
              child: const Text("Vista Previa",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
