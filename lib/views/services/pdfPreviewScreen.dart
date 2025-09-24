import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/services_operator/detail_service.dart';
import 'package:segadi/viewmodels/services_operator/send_evidences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfPreviewScreen extends StatefulWidget {
  const PdfPreviewScreen({Key? key}) : super(key: key);

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late int id;
  // late String serviceId;
  late List<File> images;
  late String receiverName;
  late String dateTime;
  late Uint8List signatureBytes;
  late String type;

  Uint8List? _pdfBytes;
  bool _isLoading = true;
  bool _isSending = false;
  bool _pdfGenerated = false;

  String? _message; // Mensaje de éxito o error
  Color? _messageColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_pdfGenerated) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      id = args['id'] as int;
      //serviceId = args['serviceId'] as String;
      images = List<File>.from(args['images'] as List<File>);
      receiverName = args['receiverName'] ?? "";
      dateTime = args['dateTime'] ?? "";
      signatureBytes = (args['signatureBytes'] != null &&
              args['signatureBytes'] is Uint8List)
          ? args['signatureBytes'] as Uint8List
          : Uint8List(0);
      type = args['type'] ?? "0";
      print('tipo de dato en pdfpreview: $type');

      _generatePdf();
      _pdfGenerated = true;
    }
  }

  /// Genera el PDF a partir de las imágenes
  Future<void> _generatePdf() async {
    final document = PdfDocument();

    try {
      for (var imageFile in images) {
        final page = document.pages.add();
        final bytes = await imageFile.readAsBytes();
        final pdfImage = PdfBitmap(bytes);
        page.graphics.drawImage(pdfImage, const Rect.fromLTWH(0, 0, 500, 500));
      }

      final bytes = await document.save();
      document.dispose();

      if (!mounted) return;

      setState(() {
        _pdfBytes = Uint8List.fromList(bytes);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _message = 'Error generando PDF: $e';
        _messageColor = Colors.red;
      });
    }
  }

  /// Envía el PDF al servidor
  Future<void> _sendPdfToServer() async {
    if (_pdfBytes == null || _isSending) return;

    setState(() {
      _isSending = true;
      _message = null;
    });

    final viewModel =
        Provider.of<SendEvidenceViewModel>(context, listen: false);
    final detailVM = Provider.of<DetailViewModel>(context, listen: false);

    bool success = false;

    try {
      if (type == '0') {
        print('estas en enviar evidencias ');
        success = await viewModel.sendEvidences(
          pdfBytes: _pdfBytes!,
          id: id,
          receiverName: receiverName,
          receiverDate: dateTime,
          signatureBytes: signatureBytes,
          detailViewModel: detailVM,
        );
      } else if (type == '1') {
        print('estas en enviar la EIR firma');
        success = await viewModel.sendSignaturePdf(
          pdfBytes: _pdfBytes!,
          id: id,
          receiverName: receiverName,
          receiverDate: dateTime,
          signatureBytes: signatureBytes,
          detailViewModel: detailVM,
        );
      }

      if (!mounted) return;

      setState(() {
        _isSending = false;
        _message = success
            ? 'Evidencias enviadas con éxito.'
            : 'Error al enviar evidencias.';
        _messageColor = success ? Colors.green : Colors.red;
      });

      if (success) {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _message = 'Error al enviar: $e';
        _messageColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vista previa del PDF',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      body: Column(
        children: [
          if (_message != null)
            Container(
              width: double.infinity,
              color: _messageColor?.withOpacity(0.1),
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              child: Text(
                _message!,
                style: TextStyle(color: _messageColor, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PdfPreview(
                    build: (format) async => _pdfBytes!,
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    allowPrinting: false,
                    allowSharing: false,
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: _isSending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.send, color: Colors.white),
          label: Text(
            _isSending ? 'Enviando...' : 'Enviar Evidencias',
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C522A),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: _isSending || _isLoading ? null : _sendPdfToServer,
        ),
      ),
    );
  }
}
