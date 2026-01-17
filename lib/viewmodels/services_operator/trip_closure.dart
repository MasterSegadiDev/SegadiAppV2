import 'dart:io';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:segadi/viewmodels/services_operator/detail_service.dart';

class TripClosureViewModel extends ChangeNotifier {
  late int id;
  late String serviceId;
  final DetailViewModelOld? detailViewModel;

  TripClosureViewModel({required this.detailViewModel});

  // Estado de carga y errores
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // --------------------------
  // Variables y métodos nuevos
  // --------------------------

  /// Lista de imágenes capturadas/escaneadas
  final List<File> _images = [];
  List<File> get images => _images;

  /// Inicializa el ViewModel con datos del viaje
  void initialize(int tripId, String tripServiceId) {
    id = tripId;
    serviceId = tripServiceId;
  }

  /// Agrega una imagen a la lista (máx. 5)
  void addImage(File image) {
    if (_images.length >= 5) return;
    _images.add(image);
    notifyListeners();
  }

  /// Elimina la última imagen agregada
  void deleteLastImage() {
    if (_images.isEmpty) return;
    _images.removeLast();
    notifyListeners();
  }

  /// Limpia todas las imágenes
  void clearImages() {
    _images.clear();
    notifyListeners();
  }

  /// Valida si hay imágenes para generar el PDF
  bool canGeneratePdf() {
    return _images.isNotEmpty;
  }

  /// Información básica del viaje
  Map<String, dynamic> get tripInfo => {
        "id": id,
        "serviceId": serviceId,
        "imagesCount": _images.length,
      };

  // --------------------------
  // Manejo de estado y errores
  // --------------------------

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

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
          _images.add(XFile(path) as File);
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
}
