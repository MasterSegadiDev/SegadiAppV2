import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/trip_closure/presentation/pages/pdf_preview_page.dart';
import '../viewmodels/trip_closure_viewmodel.dart';

class CaptureTripEvidencePage extends StatelessWidget {
  const CaptureTripEvidencePage({super.key});
  final Color primaryGreen = const Color(0xFF2C522A);

  @override
  Widget build(BuildContext context) {
    // Usamos TripClosureViewModel como en tu código original
    final vm = context.watch<TripClosureViewModel>();

    final width = MediaQuery.of(context).size.width;
    final responsiveFontSize = width * 0.030;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Cierre de viaje',
            style: const TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              /// 🔹 GRID DE IMÁGENES
              Expanded(
                child: vm.images.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: vm.images.length,
                        itemBuilder: (_, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(
                                  vm.images[index],
                                  fit: BoxFit.cover,
                                ),
                                // Botón para eliminar imagen
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () => vm.removeImage(
                                        index), // Asegúrate de tener este método en tu VM
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),

              /// 🔹 BOTONES HORIZONTALES
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    /// BOTÓN ESCANEAR (Naranja)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await vm.captureImage();
                        },
                        icon: Icon(
                          Icons.document_scanner,
                          size: responsiveFontSize + 4,
                        ),
                        label: Text(
                          "Escanear",
                          style: TextStyle(fontSize: responsiveFontSize),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    /// BOTÓN CONTINUAR (Verde)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: vm.images.isNotEmpty
                            ? () async {
                                await vm.generatePdf();
                                if (!context.mounted) return;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChangeNotifierProvider.value(
                                      value: vm,
                                      child: const PdfPreviewPage(),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        icon: Icon(
                          Icons.arrow_forward,
                          size: responsiveFontSize + 4,
                        ),
                        label: Text(
                          "Continuar",
                          style: TextStyle(fontSize: responsiveFontSize),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: vm.images.isNotEmpty
                              ? primaryGreen
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 ESTADO VACÍO
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.camera_alt_outlined,
          size: 70,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 10),
        const Text(
          "Sin evidencias de cierre",
          style: TextStyle(
              fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        const Text(
          "Captura las fotos necesarias para finalizar",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
