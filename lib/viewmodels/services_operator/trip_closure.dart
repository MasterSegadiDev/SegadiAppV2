import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:segadi/models/services/trip_closure.dart';

import 'package:pdf/widgets.dart' as pw;

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class TripClosureViewModel extends ChangeNotifier {
  late int id;
  late String serviceId;

  final ImagePicker _picker = ImagePicker();
  final TripClosure _tripClosureService = TripClosure();

  File? _image;
  String _imageEncoded = '';
  String _extension = '';
  String _imagePath = '';

  String _errorMessage = '';
  String _successMessage = '';

  int _numberTotalEvidentias = 0;
  bool _showSaveButton = false;
  bool _showCaptureButton = false;
  bool _isServiceClosed = false;
  bool _isLoading = false;

  // Getters
  File? get image => _image;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  bool get showSaveButton => _showSaveButton;
  bool get showCaptureButton => _showCaptureButton;
  bool get isServiceClosed => _isServiceClosed;
  bool get isLoading => _isLoading;
  int get numberTotalEvidentias => _numberTotalEvidentias;

  final List<File> _images = [];
  List<File> get images => List.unmodifiable(_images);

  // Inicializa el ViewModel con id y serviceId
  void initialize(int tripId, String tripServiceId) {
    id = tripId;
    serviceId = tripServiceId;
  }

  // Control de carga y notificaciones
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = '';
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = '';
    notifyListeners();
  }

  Future<bool> sendPdfToServer(Uint8List pdfData) async {
    try {
      final uri =
          Uri.parse("https://tu-api.com/enviar-pdf"); // Cambia por tu endpoint

      final request = http.MultipartRequest('POST', uri)
        ..fields['serviceId'] = serviceId
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            pdfData,
            filename: 'capturas_viaje.pdf',
            contentType: MediaType('application', 'pdf'),
          ),
        );

      final response = await request.send();

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error al enviar el PDF: $e");
      return false;
    }
  }

  // Elimina la imagen capturada y actualiza estados
  void deleteCapturedImage({bool notify = true}) {
    _image = null;
    _imagePath = '';
    _imageEncoded = '';
    _extension = '';
    _showSaveButton = false;
    _showCaptureButton = true;
    _errorMessage = '';
    _successMessage = '';
    if (notify) notifyListeners();
  }

  // Carga datos iniciales como total evidencias
  Future<void> loadInitialData() async {
    _setLoading(true);
    try {
      _numberTotalEvidentias = await _tripClosureService.getTotalEvidentias(id);
      _showCaptureButton = true;
      _showSaveButton = false;
      _isServiceClosed = false;
      _setSuccess('');
      _setError('');
    } catch (e) {
      _setError("Error al cargar los datos: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Abre la cámara y captura una imagen
  Future<void> captureImage() async {
    if (_images.length >= 3) {
      _setError('Has alcanzado el límite máximo de 3 evidencias.');
      return;
    }

    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        final newImage = File(pickedFile.path);
        _images.add(newImage);

        _showSaveButton = true;
        _showCaptureButton = _images.length < 3;

        _errorMessage = '';
        _successMessage = '';
        notifyListeners();
      }
    } catch (e) {
      _setError('Error al capturar la imagen: $e');
    }
  }

  void deleteLastCapturedImage() {
    if (_images.isNotEmpty) {
      _images.removeLast();
      _showSaveButton = _images.isNotEmpty;
      _showCaptureButton = _images.length < 3;
      notifyListeners();
    }
  }

  // Guarda la imagen y opcionalmente cierra el viaje
  Future<bool> saveImage(bool closeTravel) async {
    if (_image == null) {
      _setError('No hay imagen para guardar');
      return false;
    }

    _setLoading(true);
    try {
      await _prepareImageForUpload();

      // Inserta la imagen
      await _tripClosureService.insertImageTripClosure(
        id,
        serviceId,
        _imageEncoded,
        _extension,
      );

      if (closeTravel) {
        await _closeTrip(id);
        return true;
      } else {
        _numberTotalEvidentias =
            await _tripClosureService.getTotalEvidentias(id);

        if (_numberTotalEvidentias > 0) {
          _isServiceClosed = false;
          _showCaptureButton = true;
          _setSuccess('La captura se ha enviado con éxito');
        } else {
          await _closeTrip(id);
          return true;
        }
      }
    } catch (e) {
      _setError('No se pudo guardar la imagen: $e');
    } finally {
      _resetImageState();
      _setLoading(false);
    }

    return false;
  }

  // Cierra el viaje llamando al servicio correspondiente
  Future<void> _closeTrip(int id) async {
    final response = await _tripClosureService.closeTravels(id);

    if (response.statusCode == 200) {
      _isServiceClosed = true;
      _setSuccess('Tu viaje se ha cerrado con éxito');
    } else {
      throw Exception('Error al cerrar el viaje: ${response.statusCode}');
    }
  }

  // Prepara la imagen para subir: comprime y codifica en base64
  Future<void> _prepareImageForUpload() async {
    if (_imagePath.isEmpty) return;

    final compressedBytes = await FlutterImageCompress.compressWithFile(
      _imagePath,
      quality: 70,
    );

    final bytes = compressedBytes ?? await File(_imagePath).readAsBytes();

    _imageEncoded = base64Encode(bytes);
  }

  // Extrae extensión del archivo (incluyendo el punto)
  String? _getFileExtension(String path) {
    try {
      final ext = path.split('.').last;
      return '.$ext';
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> generatePdf() async {
    final pdf = pw.Document();

    for (final imageFile in _images) {
      final imageBytes = await imageFile.readAsBytes();
      final pdfImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Center(child: pw.Image(pdfImage, fit: pw.BoxFit.contain));
          },
        ),
      );
    }

    return pdf.save();
  }

  Future<bool> saveImagesAndCloseTrip() async {
    if (_images.isEmpty) {
      _setError('No hay imágenes para guardar.');
      return false;
    }

    _setLoading(true);
    try {
      // Itera sobre todas las imágenes
      for (final imageFile in _images) {
        _imagePath = imageFile.path;
        _extension = _getFileExtension(_imagePath) ?? '';
        await _prepareImageForUpload();

        await _tripClosureService.insertImageTripClosure(
          id,
          serviceId,
          _imageEncoded,
          _extension,
        );
      }

      // Cierra el viaje
      await _closeTrip(id);

      return true;
    } catch (e) {
      _setError('Error al guardar imágenes y cerrar viaje: $e');
      return false;
    } finally {
      _images.clear();
      _showSaveButton = false;
      _showCaptureButton = true;
      _setLoading(false);
      notifyListeners();
    }
  }

  // Reinicia estados relacionados con la imagen
  void _resetImageState() {
    _image = null;
    _imagePath = '';
    _imageEncoded = '';
    _extension = '';
    _showSaveButton = false;
    notifyListeners();
  }
}
