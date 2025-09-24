import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/services_operator/trip_closure.dart';
import 'package:signature/signature.dart';
import 'package:segadi/viewmodels/services_operator/detail_service.dart';

class TripConfirmationScreen extends StatefulWidget {
  final List<File> images;
  final int id;
  final String serviceId;

  const TripConfirmationScreen({
    Key? key,
    required this.images,
    required this.id,
    required this.serviceId,
  }) : super(key: key);

  @override
  State<TripConfirmationScreen> createState() => _TripConfirmationScreenState();
}

class _TripConfirmationScreenState extends State<TripConfirmationScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final TextEditingController _nameController = TextEditingController();
  late String _currentDate;
  late String _currentTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentDate = DateFormat('yyyy-MM-dd').format(now);
    _currentTime = DateFormat('HH:mm').format(now);
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Confirmar Evidencias",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C522A),
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black26,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text(
                    "Remisión: ${widget.serviceId}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Imágenes adjuntas:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              widget.images[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del receptor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[100],
                          ),
                          child: Text(
                            _currentDate,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[100],
                          ),
                          child: Text(
                            _currentTime,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Firmar para confirmar:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: Signature(
                      controller: _signatureController,
                      height: 200,
                      backgroundColor: Colors.grey[200]!,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextButton.icon(
                    onPressed: () => _signatureController.clear(),
                    icon: const Icon(Icons.clear),
                    label: const Text("Limpiar Firma"),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    onPressed: () async {
                      if (_signatureController.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, firme antes de enviar.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final signatureBytes =
                          await _signatureController.toPngBytes();
                      if (signatureBytes == null) return;

                      final success = await Navigator.pushNamed(
                        context,
                        '/pdf_preview',
                        arguments: {
                          'id': widget.id,
                          //'serviceId': widget.serviceId.toString(),
                          'images': widget.images,
                          'receiverName': _nameController.text,
                          'dateTime': _currentDate,
                          'signatureBytes': signatureBytes,
                          'type': '0'
                        },
                      );

                      if (!mounted) return;
                      if (success == true) {
                        Navigator.pop(context, true);
                      }
                    },
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Confirmar y Enviar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
