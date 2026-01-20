import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/trip_closure/presentation/pages/pdf_preview_page.dart';
import '../viewmodels/trip_closure_viewmodel.dart';

class CaptureTripEvidencePage extends StatelessWidget {
  const CaptureTripEvidencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TripClosureViewModel>();

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Cierre de viaje ${vm.serviceId}'),
      // ),

      appBar: AppBar(
        title: Text(
          'Cierre de viaje ${vm.serviceId}',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // COLUMNA PRINCIPAL
            Column(
              children: [
                // GRID DE IMÁGENES
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: vm.images.length,
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        vm.images[i],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // BOTÓN GENERAR PDF - pegado al fondo
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.images.isEmpty
                      ? null
                      : () async {
                          final pdf = await vm.generatePdf();
                          if (!context.mounted) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: context.read<TripClosureViewModel>(),
                                child: PdfPreviewPage(),
                              ),
                            ),
                          );
                        },
                  child: const Text('Continuar '),
                ),
              ),
            ),

            // FAB CENTRADO SOBRE EL BOTÓN DE PDF
            Positioned(
              bottom: 80, // Ajusta la distancia sobre el botón de PDF
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  onPressed: () async {
                    await vm.captureImage();
                  },
                  child: const Icon(Icons.document_scanner),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
