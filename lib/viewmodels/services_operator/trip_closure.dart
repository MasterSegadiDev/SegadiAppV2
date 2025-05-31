import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:segadi/models/services/trip_closure.dart';
import 'package:segadi/utils/global_variables.dart';

class TripClosureViewModel extends ChangeNotifier {
  late int id;
  late String serviceId;

  void initialize(int tripId, String tripServiceId) {
    id = tripId;
    serviceId = tripServiceId;
  }

  File? _image;
  String _imageEncoded = '';
  String _extension = '';
  String _errorMessage = '';
  String _imagePath = '';
  String _imageEncode = '';
  String _exts = '';
  String _successMessage = '';
  int _numberTotalEvidentias = 0;
  bool _showSaveButton = false;
  bool _showCaptureButton = false;
  bool _isServiceClosed = false;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final TripClosure _tripClosureService = TripClosure();

  // Getters
  File? get image => _image;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  bool get showSaveButton => _showSaveButton;
  bool get showCaptureButton => _showCaptureButton;
  bool get isServiceClosed => _isServiceClosed;
  bool get isLoading => _isLoading;
  int get numberTotalEvidentias => _numberTotalEvidentias;

  TripClosure? get tripClosureModel => TripClosure();

  // Control de carga
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    notifyListeners();
  }

  void deleteCapturedImage({bool notify = true}) {
    _image = null;
    _showSaveButton = false;
    _showCaptureButton = true;
    if (notify) notifyListeners();
  }

  Future<void> loadInitialData() async {
    _setLoading(true);
    try {
      _numberTotalEvidentias = await _tripClosureService.getTotalEvidentias(id);
      _showCaptureButton = true;
      _showSaveButton = false;
    } catch (e) {
      _setError("Error al cargar los datos: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> captureImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        _imagePath = pickedFile.path;
        _extension = _getFileExtension(_imagePath) ?? '';
        _image = File(_imagePath);

        _showSaveButton = true;
        _showCaptureButton = false;
        notifyListeners();
      }
    } catch (e) {
      _setError('Error al capturar la imagen: $e');
    }
  }

  Future<bool> saveImage(bool closeTravel) async {
    _setLoading(true);
    try {
      if (closeTravel) {
        await _prepareImageForUpload();
        await _tripClosureService.insertImageTripClosure(
            id, serviceId, _imageEncode, _exts);
        await _closeTrip(id);
        return true;
      } else {
        await _prepareImageForUpload();

        await _tripClosureService.insertImageTripClosure(
            id, serviceId, _imageEncode, _exts);
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

  Future<void> _closeTrip(int id) async {
    final response = await _tripClosureService.closeTravels(id);
    if (response.statusCode == 200) {
      _isServiceClosed = true;
      _setSuccess('Tu viaje se ha cerrado con éxito');
    } else {
      throw Exception('Error al cerrar el viaje');
    }
  }

  Future<void> _prepareImageForUpload() async {
    if (_imagePath.isEmpty) return;

    final compressedBytes = await FlutterImageCompress.compressWithFile(
      _imagePath,
      quality: 70,
    );

    final bytes = compressedBytes ?? await File(_imagePath).readAsBytes();
    _imageEncode = base64Encode(bytes);
    _exts = _getFileExtension(_imagePath) ?? '';
  }

  String? _getFileExtension(String path) {
    try {
      return ".${path.split('.').last}";
    } catch (_) {
      return null;
    }
  }

  void _resetImageState() {
    _image = null;
    _imagePath = '';
    _exts = '';
    _imageEncode = '';
    _showSaveButton = false;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }
}
