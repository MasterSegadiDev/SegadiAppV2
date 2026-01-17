import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/services_operator/send_evidences.dart';
import 'package:segadi/views/home/routes.dart';

class SendEvidenceScreenOld extends StatefulWidget {
  final int id;
  final String? serviceId;

  const SendEvidenceScreenOld({
    Key? key,
    required this.id,
    this.serviceId,
  }) : super(key: key);

  @override
  State<SendEvidenceScreenOld> createState() => _SendEvidenceScreenState();
}

class _SendEvidenceScreenState extends State<SendEvidenceScreenOld> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sendVM = context.watch<SendEvidenceViewModel>();

    final width = MediaQuery.of(context).size.width;
    final responsiveFontSize = width * 0.030;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Enviar Evidencias"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C522A),
        foregroundColor: Colors.white,
      ),

      // 🔹 SafeArea evita que botones queden detrás del sistema
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              // 🔹 Mensajes
              if (sendVM.errorMessage.isNotEmpty)
                _buildMessage(sendVM.errorMessage, Colors.red, Icons.error),
              if (sendVM.successMessage.isNotEmpty)
                _buildMessage(sendVM.successMessage, Colors.green, Icons.check),

              // 🔹 Evidencias (Scroll adaptable)
              Expanded(
                child: sendVM.images.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: sendVM.images.length,
                        itemBuilder: (_, index) {
                          final file = sendVM.images[index];
                          final exists = File(file.path).existsSync();
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                exists
                                    ? Image.file(
                                        File(file.path),
                                        fit: BoxFit.cover,
                                        key: ValueKey(file.path),
                                      )
                                    : const Center(
                                        child: Text("Archivo no encontrado"),
                                      ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () => sendVM.deleteImage(index),
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

              // 🔹 BOTONES (siempre visibles)
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 12), // <-- evita choque con barra inferior
                child: Row(
                  children: [
                    // Capturar
                    // Expanded(
                    //   child: ElevatedButton.icon(
                    //     onPressed: sendVM.images.length < 5
                    //         ? () => sendVM.captureImage()
                    //         : null,
                    //     icon: Icon(
                    //       Icons.camera_alt,
                    //       size: responsiveFontSize + 4,
                    //     ),
                    //     label: Text(
                    //       "Capturar",
                    //       style: TextStyle(fontSize: responsiveFontSize),
                    //     ),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: const Color(0xFF2C522A),
                    //       foregroundColor: Colors.white,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(100),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    const SizedBox(width: 10),

                    // Escanear
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: sendVM.images.length < 5
                            ? () async {
                                final error = await sendVM.scanDocument();
                                if (error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            : null,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Enviar / Generar PDF
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: sendVM.images.isNotEmpty
                            ? () async {
                                List<File> files = sendVM.images
                                    .map((xfile) => File(xfile.path))
                                    .toList();

                                final result = await Navigator.pushNamed(
                                  context,
                                  '/trip_confirmation',
                                  arguments: {
                                    'id': widget.id,
                                    'serviceId': widget.serviceId,
                                    'images': files,
                                    'type': '0'
                                  },
                                );

                                if (!mounted) return;

                                if (result == true) {
                                  Navigator.pop(context, true);
                                }
                              }
                            : null,
                        icon: Icon(
                          Icons.send,
                          size: responsiveFontSize + 4,
                        ),
                        label: Text(
                          "Generar PDF",
                          style: TextStyle(fontSize: responsiveFontSize),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sendVM.images.isNotEmpty
                              ? Colors.green
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
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

  // 🔹 Widget para mensajes
  Widget _buildMessage(String text, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      ),
    );
  }

  // 🔹 Estado vacío
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.photo_library_outlined,
            size: 70, color: Colors.grey.shade400),
        const SizedBox(height: 10),
        const Text("No se han capturado evidencias aún",
            style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 5),
        const Text("Agrega imágenes capturando o escaneando documentos",
            style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
