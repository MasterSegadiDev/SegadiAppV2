import 'package:cunning_document_scanner/cunning_document_scanner.dart';
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

  // --- Estado y Control ---
  TripClosureStatus _status = TripClosureStatus.idle;
  String? _errorMessage;
  bool _isDisposed = false;

  // --- Datos del Negocio ---
  int _id = 0;
  String _serviceId = "";
  // CAMBIO: Ahora guardamos rutas (Strings) para no saturar la RAM
  final List<String> _images = [];
  Uint8List? _pdfBytes;

  // --- Getters ---
  int get id => _id;
  String get serviceId => _serviceId;
  TripClosureStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSending => _status == TripClosureStatus.loading;
  List<String> get images => _images;
  Uint8List? get pdfBytes => _pdfBytes;

  // --- Lógica de Interfaz ---

  /// Limpia el error para que la UI deje de mostrar el SnackBar
  void clearError() {
    _errorMessage = null;
    _safeNotify();
  }

  /// Inicializa el flujo de un nuevo cierre
  void startNewTripClosure(int newId, String newServiceId) {
    _id = newId;
    _serviceId = newServiceId;

    _images.clear();
    _pdfBytes = null;
    _errorMessage = null;
    _status = TripClosureStatus.idle;

    _clearRamCache();
    _clearDiskFiles();
    notifyListeners();
  }

  Future<void> reset() async {
    _images.clear();
    _pdfBytes = null; // Liberar la RAM del PDF inmediatamente
    _errorMessage = null;
    _status = TripClosureStatus.idle;

    _clearRamCache();
    await _clearDiskFiles(); // Esperamos el borrado físico
    _safeNotify();
  }

  /// Captura imágenes usando el scanner controlado
  Future<void> captureImage() async {
    const int maxAllowed = 5;
    if (_images.length >= maxAllowed) {
      _errorMessage = "Límite de $maxAllowed imágenes alcanzado";
      _status = TripClosureStatus.error; // Para que el listener lo detecte
      _safeNotify();
      return;
    }

    try {
      _status = TripClosureStatus.loading;
      _errorMessage = null;
      _safeNotify();

      _clearRamCache(); // Liberar RAM antes de abrir la cámara

      final List<String>? paths = await CunningDocumentScanner.getPictures(
        noOfPages: maxAllowed - _images.length,
        isGalleryImportAllowed: false,
      );

      if (paths != null && paths.isNotEmpty) {
        // Guardamos las rutas directamente (String)
        _images.addAll(paths);
        _status = TripClosureStatus.idle;
      } else {
        _status = TripClosureStatus.idle;
      }
    } catch (e) {
      _status = TripClosureStatus.error;
      _errorMessage = "Fallo en cámara o memoria insuficiente";
      debugPrint("Error captureImage: $e");
    } finally {
      _clearRamCache();
      _safeNotify();
    }
  }

  void removeImage(int index) async {
    if (index >= 0 && index < _images.length) {
      final path = _images[index];
      _images.removeAt(index);

      // Borrado físico inmediato del archivo removido
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          debugPrint("🗑️ Archivo individual eliminado: $path");
        }
      } catch (e) {
        debugPrint("Error borrando archivo individual: $e");
      }

      _clearRamCache();
      notifyListeners();
    }
  }

  /// Prepara el PDF convirtiendo las rutas a bytes solo en este momento
  Future<void> preparePdf() async {
    if (_images.isEmpty) return;

    _status = TripClosureStatus.loading;
    _safeNotify();

    try {
      // Convertimos las rutas a bytes temporalmente para el generador de PDF
      final List<Uint8List> imageBytesList = [];
      for (final path in _images) {
        final bytes = await File(path).readAsBytes();
        imageBytesList.add(bytes);
      }

      _pdfBytes = await TripPdfGenerator.generate(imageBytesList);
      _status = TripClosureStatus.idle;

      _pdfBytes!.clear();
      _clearRamCache();
    } catch (e) {
      _status = TripClosureStatus.error;
      _errorMessage = "Error al generar el documento PDF";
    } finally {
      _safeNotify();
    }
  }

  Future<bool> sendTripClosure() async {
    if (_pdfBytes == null || _pdfBytes!.isEmpty) {
      _errorMessage = "El documento PDF no se generó correctamente.";
      _status = TripClosureStatus.error;
      _safeNotify();
      return false;
    }

    try {
      _status = TripClosureStatus.loading;
      _safeNotify();

      await repository.sendTripClosure(id: _id, pdfBytes: _pdfBytes!);

      _status = TripClosureStatus.success;

      // 🚩 AQUÍ: Antes de retornar true, limpiamos TODO
      // Esto garantiza que al volver a la pantalla anterior no haya basura
      await reset();

      return true;
    } catch (e) {
      _status = TripClosureStatus.error;
      _errorMessage = e.toString().replaceAll("Exception:", "").trim();
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
        // Usamos recursividad simple para asegurar que entramos a subcarpetas si el scanner las crea
        final files = cacheDir.listSync(recursive: true);
        for (var file in files) {
          if (file is File) {
            final path = file.path.toLowerCase();
            // Borramos imágenes Y cualquier PDF residual
            if (path.endsWith('.jpg') ||
                path.endsWith('.png') ||
                path.endsWith('.pdf')) {
              await file.delete();
            }
          }
        }
        debugPrint("🗑️ DISCO: Limpieza profunda completada (Imágenes y PDFs)");
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
    // No esperamos el clearDiskFiles porque es async, pero se dispara
    _clearDiskFiles();
    super.dispose();
  }
}
