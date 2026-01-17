import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;
import 'package:segadi/models/services/detail_service.dart';
import 'package:segadi/models/services/trip_closure.dart';
import 'package:segadi/utils/global_variables.dart';
import 'package:segadi/viewmodels/login/user_login.dart';
import 'package:segadi/viewmodels/services_operator/detail_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendEvidenceViewModel extends ChangeNotifier {
  List<XFile> _images = [];
  List<XFile> get images => _images;

  bool canCapture = true;
  String _successMessage = '';
  String get successMessage => _successMessage;

  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  final TripClosure _tripClosureService = TripClosure();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Captura imagen con cámara
  Future<void> captureImage() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        _images.add(photo);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error al capturar imagen: $e';
      notifyListeners();
    }
  }

  /// Escanea documentos y agrega a la lista de imágenes.
  /// Devuelve null si todo fue bien, o un String con el error/mensaje.
  Future<String?> scanDocument() async {
    if (_images.length >= 5) {
      return 'Solo puedes agregar hasta 5 evidencias.';
    }

    try {
      final scannedPaths = await CunningDocumentScanner.getPictures();

      if (scannedPaths == null || scannedPaths.isEmpty) {
        return 'No se detectaron documentos escaneados.';
      }

      for (var path in scannedPaths) {
        if (_images.length < 5) {
          _images.add(XFile(path));
        } else {
          notifyListeners(); // Notificamos aunque no se agregue más
          return 'Límite de 5 imágenes alcanzado.';
        }
      }

      notifyListeners(); // Actualiza la UI
      return null; // Sin errores
    } catch (e) {
      return 'Error al escanear: $e';
    }
  }

  /// Eliminar imagen por índice
  void deleteImage(int index) {
    if (index >= 0 && index < _images.length) {
      _images.removeAt(index);
      notifyListeners();
    }
  }

  Future<bool> sendEvidences({
    required Uint8List pdfBytes,
    required int id,
    required String receiverName,
    required String receiverDate,
    required Uint8List signatureBytes,
    DetailViewModelOld? detailViewModel,
  }) async {
    if (_isLoading) return false;
    _setLoading(true);
    print('signatureBytes length: ${signatureBytes.length}');

    try {
      final token = await LoginViewModel.getSavedToken();
      if (token == null || token.isEmpty) {
        _setError('Token no encontrado.');
        return false;
      }

      // Normalizar receiverName y receiverDate
      final String safeReceiverName = receiverName.toString();
      final String safeReceiverDate = receiverDate.toString();

      // --- PDF en base64 ---
      final String pdfBase64 = base64Encode(pdfBytes);

      // Construimos el body en JSON
      final Map<String, dynamic> dataPdf = {
        "service_id": id.toString(),
        "token": token,
        "receiver_name": '',
        "receiver_date": '',
        "file_type": "pdf",
        "document_name": "Evidencia",
        "document_type": "POD Operador",
        "document_description": "POD Operador",
        "document": pdfBase64,
      };

      print('Enviando PDF: ${jsonEncode(dataPdf)}');

      // Hacemos la petición POST enviando todo el JSON
      final pdfResponse = await http.post(
        Uri.parse(
            "${GlobalVariables.baseUrl}index.php?r=esegadi/evidenciaspost"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(dataPdf),
      );

      print('estatus pod operador: ${pdfResponse.statusCode}');
      if (pdfResponse.statusCode != 200) {
        _setError("Error al enviar PDF: ${pdfResponse.body}");
        return false;
      }

      // --- Validar que la firma tenga datos ---
      if (signatureBytes.isEmpty) {
        print('No hay firma capturada');
        _setError('No hay firma capturada');
        return false;
      }

      print('datos de la firma length: ${signatureBytes.length}');

      // --- Firma en base64 ---
      final String signatureBase64 = base64Encode(signatureBytes);

      final Map<String, dynamic> dataSignature = {
        "service_id": id.toString(),
        "token": token,
        "receiver_name": safeReceiverName,
        "receiver_date": safeReceiverDate,
        "file_type": "png", // mejor usar "image/png"
        "document_name": "Firma",
        "document_type": "Firma",
        "document_description": "Firma",
        "document": signatureBase64,
      };

      print('Enviando firma: ${jsonEncode(dataSignature)}');

      final signatureResponse = await http.post(
        Uri.parse(
            "${GlobalVariables.baseUrl}index.php?r=esegadi/evidenciaspost"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(dataSignature),
      );

      print('body: ${signatureResponse.body}');
      print('respuesta signatureResponse: ${signatureResponse.statusCode}');

      if (signatureResponse.statusCode == 200) {
        clearImages();

        detailViewModel?.changeStatusService(10);
        await detailViewModel?.updateDetail();
        return true;
      }

      _setError('Error al enviar la firma: ${signatureResponse.body}');
      return false;
    } catch (e) {
      print('Error al enviar las evidencias: $e');
      _setError('Error al enviar evidencias: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendSignaturePdf({
    required Uint8List pdfBytes,
    required int id,
    // required String serviceId,
    required String receiverName,
    required String receiverDate,
    required Uint8List signatureBytes,
    DetailViewModelOld? detailViewModel,
  }) async {
    if (_isLoading) return false;
    _setLoading(true);

    try {
      final token = await LoginViewModel.getSavedToken();
      if (token == null || token.isEmpty) {
        _setError('Token no encontrado.');
        return false;
      }

      // --- PDF en base64 ---
      final String pdfBase64 = base64Encode(pdfBytes);

      // Construimos el body en JSON
      final Map<String, dynamic> dataPdf = {
        "service_id": id.toString(),
        "token": token,
        "receiver_name": '',
        "receiver_date": '',
        "file_type": "pdf",
        "document_name": "EIR",
        "document_type": "EIR",
        "document_description": "EIR",
        "document": pdfBase64,
      };

      // Hacemos la petición POST enviando todo el JSON
      final pdfResponse = await http.post(
        Uri.parse(
            "${GlobalVariables.baseUrl}index.php?r=esegadi/evidenciaspost"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(dataPdf),
      );

      if (pdfResponse.statusCode != 200) {
        _setError("Error al enviar PDF: ${pdfResponse.body}");
        return false;
      }

      if (pdfResponse.statusCode == 200) {
        final detail = await getDetail(id);

        if (detail!.pendingMoneyChecks == false) {
          print('se va a cerrar el viaje de la remision : $id');
          await _closeTrip(id);
        }
        await detailViewModel?.updateDetail();
        return true;
      }

      return false;
    } catch (e) {
      _setError('Error al enviar evidencias: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _closeTrip(int id) async {
    final response = await _tripClosureService.closeTravels(id);
    if (response.statusCode == 200) {
      print('se ha cerrado el viaje de la remision : $id');
      return true;
    } else {
      throw Exception('Error al cerrar el viaje: ${response.statusCode}');
    }
  }

  void clearImages() {
    if (_images.isEmpty) {
      print('No hay imágenes para borrar.');
      return;
    }

    for (var file in _images) {
      final f = File(file.path);
      try {
        if (f.existsSync()) {
          f.deleteSync();
          print('Archivo eliminado: ${f.path}');
        } else {
          print('Archivo no existe: ${f.path}');
        }
      } catch (e) {
        print('Error al borrar archivo ${f.path}: $e');
      }
    }

    // Limpiar la lista en memoria
    _images.clear();

    // Notificar a la UI
    notifyListeners();
    print('Lista de imágenes en memoria limpia.');
  }

  final String baseUrl = GlobalVariables.baseUrl;

  Future<DetailService?> getDetail(id) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id') ?? 0;
    final token = prefs.getString('token') ?? '';

    final route = 'index.php';

    final uri = Uri.parse(baseUrl + route).replace(
      queryParameters: {
        'r': 'esegadi/getdetalle',
        'id_remision': id.toString(),
        'token': token,
        'id': userId.toString(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      //  print('BODY DETALLE: ${response.body}');
      final result = DetailService.fromJson(body);
      return result;
    } else {
      return null;
    }
  }
}
