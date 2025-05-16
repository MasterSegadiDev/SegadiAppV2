import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/services_operator/trip_closure.dart';

class TripClosureScreen extends StatefulWidget {
  final int id;
  final String serviceId;

  const TripClosureScreen({Key? key, required this.id, required this.serviceId})
      : super(key: key);

  @override
  State<TripClosureScreen> createState() => _TripClosureScreenState();
}

class _TripClosureScreenState extends State<TripClosureScreen> {
  TripClosureViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= Provider.of<TripClosureViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    _viewModel?.deleteCapturedImage(notify: false);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel = Provider.of<TripClosureViewModel>(context, listen: false);
      _viewModel?.initialize(widget.id, widget.serviceId);
      _viewModel?.loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TripClosureViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cierre del viaje', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF2C522A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              if (viewModel.image != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.file(
                      viewModel.image!,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Puedes capturar máximo ${viewModel.numberTotalEvidentias} evidencias para cerrar el viaje.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 30),

              // Botón Guardar captura con confirmación
              if (viewModel.showSaveButton)
                Center(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.save, color: Colors.white),
                    label: Text("Guardar captura",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      final closeTrip = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('¿Deseas cerrar el viaje?'),
                          content: Text(
                            '¿Vas a capturar más evidencias o deseas cerrar la remisión con esta imagen?',
                          ),
                          actions: [
                            // TextButton(
                            //   onPressed: () => Navigator.of(context).pop(false),
                            //   child: Text('Agregar más evidencias'),
                            // ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Agregar mas evidencias'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Cerrar remisión'),
                            ),
                          ],
                        ),
                      );

                      if (closeTrip != null) {
                        final wasClosed = await viewModel.saveImage(closeTrip);
                        if (wasClosed && context.mounted) {
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Viaje cerrado'),
                              content: Text(
                                  'Tu viaje ha sido cerrado correctamente.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context)
                                      .pop(), // cerrar diálogo
                                  child: Text('Aceptar'),
                                ),
                              ],
                            ),
                          );

                          if (context.mounted) {
                            Navigator.of(context)
                                .pop(true); // salir de pantalla actual
                          }
                        }
                      }
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // Botón Capturar Imagen
              if (viewModel.showCaptureButton)
                Center(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    label: Text('Capturar Imagen',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: viewModel.captureImage,
                  ),
                ),

              const SizedBox(height: 20),

              // Botón Eliminar Imagen
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.delete, color: Colors.white),
                  label: Text('Eliminar Imagen',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: viewModel.deleteCapturedImage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
