import 'package:flutter/material.dart';
import 'package:segadi/features/trip_closure/domain/services/document_scanner.dart';
import 'package:segadi/features/trip_closure/domain/trip_closure_repository.dart';
import 'package:segadi/features/trip_closure/pdf/trip_pdf_generator.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum TripClosureStatus { idle, loading, success, error }

class TripClosureViewModel extends ChangeNotifier {
  final TripClosureRepository repository;
  final DocumentScanner scanner;

  TripClosureViewModel({
    required this.repository,
    required this.scanner,
  });

  // Estado y Control
  TripClosureStatus _status = TripClosureStatus.idle;
  String? _errorMessage;
  bool _isDisposed = false;

  // Datos del Negocio
  int _id = 0;
  String _serviceId = "";
  final List<Uint8List> _images = [];
  Uint8List? _pdfBytes;

  // Getters
  int get id => _id;
  String get serviceId => _serviceId;
  TripClosureStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSending => _status == TripClosureStatus.loading;
  List<Uint8List> get images => _images;
  Uint8List? get pdfBytes => _pdfBytes;

  /// Inicializa el flujo
  void startNewTripClosure(int newId, String newServiceId) {
    _id = newId;
    _serviceId = newServiceId;

    // Limpiamos todo lo anterior explícitamente
    _images.clear();
    _pdfBytes = null;
    _errorMessage = null;
    _status = TripClosureStatus.idle;

    _clearRamCache();
    _clearDiskFiles(); // <--- Agrega esta llamada aquí también
    notifyListeners();
  }

  /// Reset completo de datos
  Future<void> reset() async {
    _images.clear();
    _pdfBytes = null;
    _errorMessage = null;
    _status = TripClosureStatus.idle;
    _clearRamCache();
    await _clearDiskFiles();
    _safeNotify();
  }

  /// Captura de imagen con scanner
  Future<void> captureImage() async {
    if (_images.length >= 5) {
      _errorMessage = "Límite de 5 imágenes alcanzado";
      notifyListeners();
      return;
    }

    try {
      _status = TripClosureStatus.loading;
      _errorMessage = null;
      _safeNotify();

      final image = await scanner.scan();

      if (image != null) {
        _images.add(image);
        _clearRamCache(); // Limpia RAM al añadir imagen pesada
        _status = TripClosureStatus.idle;
      } else {
        _status = TripClosureStatus.idle;
      }
    } catch (e) {
      _status = TripClosureStatus.error;
      _errorMessage = "Error al escanear: ${e.toString()}";
    } finally {
      _safeNotify();
    }
  }

  void removeImage(int index) {
    _images.removeAt(index);
    _clearRamCache();
    notifyListeners();
  }

  Future<void> preparePdf() async {
    if (_images.isEmpty) return;
    _status = TripClosureStatus.loading;
    _safeNotify();

    try {
      _pdfBytes = await TripPdfGenerator.generate(_images);
      _status = TripClosureStatus.idle;
    } catch (e) {
      _status = TripClosureStatus.error;
      _errorMessage = "Error al generar PDF";
    } finally {
      _safeNotify();
    }
  }

  Future<bool> sendTripClosure() async {
    if (_pdfBytes == null) return false;

    try {
      _status = TripClosureStatus.loading;
      _safeNotify();

      await repository.sendTripClosure(id: _id, pdfBytes: _pdfBytes!);

      _status = TripClosureStatus.success;
      await reset();
      return true;
    } catch (e) {
      _status = TripClosureStatus.error;
      _errorMessage = e.toString();
      _safeNotify();
      return false;
    }
  }

  // --- Herramientas de Limpieza ---

  void _clearRamCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    debugPrint("🧠 RAM: Caché de imágenes liberada");
  }

  Future<void> _clearDiskFiles() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        final files = cacheDir.listSync();
        for (var file in files) {
          if (file is File && file.path.endsWith('.jpg')) {
            await file.delete();
          }
        }
        debugPrint("🗑️ DISCO: Temporales limpiados");
      }
    } catch (e) {
      debugPrint("❌ Error limpiando disco: $e");
    }
  }

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _clearRamCache();
    _clearDiskFiles();
    super.dispose();
  }
}
