import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:segadi/viewmodels/login/user_login.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:segadi/viewmodels/services_operator/detail_service.dart';
import 'package:segadi/utils/global_variables.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class TripClosureViewModel extends ChangeNotifier {
  List<File> images = [];

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  DetailViewModelOld? detailViewModel;

  late int _id;
  late String _serviceId;

  void initialize(int id, String serviceId) {
    _id = id;
    _serviceId = serviceId;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // ---------------- Manejo de imágenes ----------------
  void addImage(File image) {
    if (images.length >= 5) return;
    images.add(image);
    notifyListeners();
  }

  void deleteLastImage() {
    if (images.isNotEmpty) {
      images.removeLast();
      notifyListeners();
    }
  }

  void clearImages() {
    images.clear();
    notifyListeners();
  }

  // ---------------- Generación de PDF ----------------
  Future<Uint8List> generatePdf() async {
    final document = PdfDocument();

    for (var img in images) {
      final page = document.pages.add();
      final bytes = await img.readAsBytes();
      final pdfImage = PdfBitmap(bytes);
      page.graphics.drawImage(pdfImage, const Rect.fromLTWH(0, 0, 500, 500));
    }

    final pdfBytes = await document.save();
    document.dispose();
    return Uint8List.fromList(pdfBytes);
  }

  // ---------------- Envío de evidencias ----------------
  Future<bool> sendEvidencesPdf({
    required Uint8List pdfBytes,
    required int id,
    required String serviceId,
  }) async {
    if (_isLoading) return false;
    _setLoading(true);

    try {
      final token = await LoginViewModel.getSavedToken();
      if (token == null || token.isEmpty) {
        _setError('Token no encontrado.');
        return false;
      }

      final uri = Uri.parse(
          '${GlobalVariables.baseUrl}index.php?r=esegadi/evidenciaspost');
      final request = http.MultipartRequest('POST', uri);

      // Campos obligatorios
      request.fields['service_id'] = id.toString();
      request.fields['token'] = token;

      // PDF
      request.files.add(http.MultipartFile.fromBytes(
        'evidence_pdf',
        pdfBytes,
        filename: 'evidence_$serviceId.pdf',
        contentType: MediaType('application', 'pdf'),
      ));

      // Enviar request
      final response = await request.send();

      if (response.statusCode == 200) {
        // Si quieres actualizar detalles aquí, puedes llamar a tu detailViewModel
        return true;
      } else {
        _setError('Error en la respuesta del servidor: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _setError('Error al enviar evidencias: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
