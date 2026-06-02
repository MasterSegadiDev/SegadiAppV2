import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:segadi/features/evidence/domain/repositories/evidence_repository.dart';
import 'package:segadi/features/evidence/presentation/pages/widgets/evidence_pdf_generator.dart';
import 'package:segadi/features/service_detail/data/repositories/detail_service_repository_impl.dart';
import '../../domain/evidence_entity.dart';

/// Estatus del flujo de evidencias
enum EvidenceFlowStatus { idle, scanning, error, sending, success, processing }

class EvidenceFlowViewModel extends ChangeNotifier {
  int _id;
  final EvidenceRepository repository;
  final DetailServiceRepositoryImpl detailServiceApi;

  EvidenceFlowViewModel({
    required int id,
    required this.repository,
    required this.detailServiceApi,
  }) : _id = id;

  int get id => _id;

  // Control de ciclo de vida
  bool _isDisposed = false;

  // ---------------------------------------------------------
  // EVIDENCIAS (Imágenes)
  // ---------------------------------------------------------
  final List<EvidenceEntity> _evidences = [];
  List<EvidenceEntity> get evidences => List.unmodifiable(_evidences);

  static const int _maxEvidences = 5;
  bool get hasEvidences => _evidences.isNotEmpty;
  bool get canScanMore => _evidences.length < _maxEvidences;

  // ---------------------------------------------------------
  // DATOS DE CONFIRMACIÓN (Firma y Nombre)
  // ---------------------------------------------------------
  String _receiverName = '';
  String get receiverName => _receiverName;

  Uint8List? _signatureBytes;
  Uint8List? get signatureBytes => _signatureBytes;

  final DateTime _confirmationDate = DateTime.now();
  DateTime get confirmationDate => _confirmationDate;

  // ---------------------------------------------------------
  // RESULTADO DEL PROCESAMIENTO (PDF)
  // ---------------------------------------------------------
  Uint8List? _pdfBytes;
  Uint8List? get pdfBytes => _pdfBytes;

  // ---------------------------------------------------------
  // ESTADO DE LA UI
  // ---------------------------------------------------------
  EvidenceFlowStatus _status = EvidenceFlowStatus.idle;
  EvidenceFlowStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isSending => _status == EvidenceFlowStatus.sending;

  //bool get hasSignature => signatureBytes != null && signatureBytes!.isNotEmpty;
  bool get hasSignature => _signatureBytes != null;
  // =========================================================
  // PROTOCOLO DE LIMPIEZA (Manejo Senior de Memoria)
  // =========================================================

  void startNewFlow(int serviceId) {
    _id = serviceId; // Asignamos el ID de la remisión actual

    // Limpieza total de datos previos
    _signatureBytes = null;
    _pdfBytes = null;
    _receiverName = "";
    _errorMessage = null;
    _evidences.clear(); // Borra la lista de fotos

    _status = EvidenceFlowStatus.idle;

    print("✅ Flujo inicializado para la remisión: $_id");
    notifyListeners(); // Avisamos a las pantallas que todo está en cero
  }

  /// Libera la RAM de imágenes que Flutter mantiene en caché
  void _clearRamCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    debugPrint("🧠 RAM: Caché de imágenes liberada");
  }

  /// Borra físicamente los archivos .jpg del almacenamiento del teléfono
  Future<void> _clearDiskFiles() async {
    for (final evidence in _evidences) {
      try {
        final file = File(evidence.path);
        if (await file.exists()) {
          await file.delete();
          debugPrint("🗑️ DISCO: Archivo eliminado: ${evidence.path}");
        }
      } catch (e) {
        debugPrint("❌ Error eliminando archivo físico: $e");
      }
    }
  }

  /// Resetea el flujo completo y limpia memoria
  Future<void> reset() async {
    await _clearDiskFiles();
    _evidences.clear();
    _pdfBytes = null;
    _signatureBytes = null;
    _receiverName = '';
    _errorMessage = null;
    _status = EvidenceFlowStatus.idle;
    _clearRamCache();
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _clearDiskFiles(); // Limpia archivos al cerrar la pantalla
    _clearRamCache(); // Limpia RAM
    super.dispose();
  }

  Future<File?> _compressImage(String path) async {
    try {
      final String targetPath = path.replaceFirst(
          ".jpg", "_optimized_${DateTime.now().millisecondsSinceEpoch}.jpg");

      // FlutterImageCompress usa hilos nativos, lo que evita congelar la UI
      var result = await FlutterImageCompress.compressAndGetFile(
        path,
        targetPath,
        quality:
            70, // Balance perfecto: reduce ~80% el peso con mínima pérdida visual
        minWidth: 1280, // Resolución suficiente para leer textos en un PDF
        minHeight: 1280,
        format: CompressFormat.jpeg,
      );

      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      debugPrint("❌ Error en compresión: $e");
      return null;
    }
  }

  // =========================================================
  // ACCIONES DEL FLUJO
  // =========================================================

  /// Captura de imágenes desde la cámara
  Future<void> scanFromCamera() async {
    if (_status == EvidenceFlowStatus.scanning || !canScanMore) return;

    _setStatus(EvidenceFlowStatus.scanning);
    _errorMessage = null;

    try {
      // 1. Limpieza preventiva antes de abrir la cámara
      _clearRamCache();

      final List<String>? paths = await CunningDocumentScanner.getPictures(
        noOfPages: _maxEvidences - _evidences.length,
        isGalleryImportAllowed: false,
      );

      if (paths == null || paths.isEmpty) {
        _setStatus(EvidenceFlowStatus.idle);
        return;
      }

      // 2. Procesamiento secuencial (Pipeline de validación y compresión)
      for (final path in paths) {
        // Validar integridad del archivo original
        final originalFile = File(path);
        if (!await originalFile.exists() || await originalFile.length() == 0)
          continue;

        // COMPRESIÓN: Convertimos la foto pesada en una ligera antes de guardarla
        final File? compressedFile = await _compressImage(path);

        if (compressedFile != null) {
          _evidences.add(EvidenceEntity(
            path: compressedFile.path,
            filename: compressedFile.path.split('/').last,
          ));

          // 3. LIMPIEZA INMEDIATA: Borramos el original de alta resolución
          // Solo conservamos la versión optimizada para ahorrar espacio en disco
          if (await originalFile.exists()) await originalFile.delete();

          debugPrint("✅ Imagen optimizada: ${compressedFile.path}");
        }
      }

      _setStatus(EvidenceFlowStatus.idle);
    } catch (e) {
      debugPrint("🚨 Fallo crítico en captura: $e");
      _handleCaptureError(e);
      _setStatus(EvidenceFlowStatus.error);
    }
  }

  void removeEvidence(int index) async {
    if (index < 0 || index >= _evidences.length) return;

    final path = _evidences[index].path;
    _evidences.removeAt(index);
    notifyListeners();

    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  /// Genera el PDF una sola vez y lo guarda en memoria
  Future<void> buildPdf() async {
    if (_evidences.isEmpty) {
      _errorMessage = "No hay evidencias capturadas para generar el reporte.";
      _setStatus(EvidenceFlowStatus.error);
      return;
    }

    // Cambiamos el estatus a 'sending' o un nuevo 'processing' si lo prefieres,
    // para bloquear la UI mientras el procesador trabaja.
    _setStatus(EvidenceFlowStatus.sending);
    _errorMessage = null;

    try {
      // 1. Verificación de seguridad: ¿Los archivos siguen ahí?
      for (final ev in _evidences) {
        if (!await File(ev.path).exists()) {
          throw Exception(
              "Archivo no encontrado: ${ev.filename}. Por favor, captura la foto de nuevo.");
        }
      }

      // 2. Generación del PDF
      // Tip: Si EvidencePdfGenerator.generate es muy pesado,
      // asegúrate de que use internamente el método 'compute' de Flutter.
      final generatedPdf = await EvidencePdfGenerator.generate(
        serviceId: id,
        evidences: _evidences,
        receiverName: _receiverName,
        confirmationDate: _confirmationDate,
      );

      if (generatedPdf.isEmpty) {
        throw Exception("El documento generado está vacío.");
      }

      _pdfBytes = generatedPdf;
      _setStatus(EvidenceFlowStatus.idle);
      debugPrint(
          "✅ PDF generado con éxito: ${_pdfBytes!.lengthInBytes / 1024} KB");
    } catch (e) {
      debugPrint("🚨 Error en buildPdf: $e");
      // Mensaje amigable pero informativo
      _errorMessage = e.toString().contains("Exception:")
          ? e.toString().replaceAll("Exception: ", "")
          : "Ha ocurrido un error al generar el PDF. Intenta con menos imágenes.";

      _setStatus(EvidenceFlowStatus.error);
    }
  }

  /// Envío final de evidencias
  // Future<bool> sendEvidences() async {
  //   if (_pdfBytes == null || _pdfBytes!.isEmpty) {
  //     _errorMessage =
  //         "Hay un problema con el PDF generado. Por favor, intenta generar el PDF de nuevo.";
  //     _setStatus(EvidenceFlowStatus.error);
  //     return false;
  //   }

  //   if (_signatureBytes == null || _signatureBytes!.isEmpty) {
  //     _errorMessage =
  //         "Hay un problema con la firma capturada. Por favor, intenta capturar la firma de nuevo.";
  //     _setStatus(EvidenceFlowStatus.error);
  //     return false;
  //   }

  //   debugPrint("BODY DE FIRMA: ${_signatureBytes!.length / 1024} KB");

  //   _setStatus(EvidenceFlowStatus.sending);

  //   try {
  //     // 1. PDF
  //     final pdfResult = await repository.sendPdf(
  //       serviceId: id,
  //       pdfBytes: _pdfBytes!,
  //       receiverName: receiverName,
  //       receiverDate: confirmationDate,
  //     );

  //     if (pdfResult.isLeft()) {
  //       return pdfResult.fold((failure) {
  //         _errorMessage = "Error PDF: ${failure.message}";
  //         _setStatus(EvidenceFlowStatus.error);
  //         return false;
  //       }, (_) => false);
  //     }

  //     debugPrint("✅ PDF subido correctamente");

  //     // 2. FIRMA
  //     final signResult = await repository.sendSignature(
  //       serviceId: id,
  //       signatureBytes: _signatureBytes!,
  //       receiverName: receiverName,
  //       receiverDate: confirmationDate,
  //     );

  //     if (signResult.isLeft()) {
  //       return signResult.fold((failure) {
  //         _errorMessage = "Error en FIRMA: ${failure.message}";
  //         _setStatus(EvidenceFlowStatus.error);
  //         debugPrint("❌ Firma falló: ${failure.message}");
  //         return false;
  //       }, (_) => false);
  //     }

  //     debugPrint("✅ Firma subida correctamente");

  //     // 3. STATUS
  //     final statusResult = await detailServiceApi.changeStatus(
  //       serviceId: id,
  //       statusId: 10,
  //     );

  //     return statusResult.fold(
  //       (failure) {
  //         _errorMessage = "Error STATUS: ${failure.message}";
  //         _setStatus(EvidenceFlowStatus.error);
  //         return false;
  //       },
  //       (response) async {
  //         if (response.success) {
  //           debugPrint("✅ Status actualizado correctamente");
  //           await reset();
  //           _setStatus(EvidenceFlowStatus.success);
  //           return true;
  //         }

  //         _errorMessage =
  //             "Ha ocurrido un error al actualizar la remisión despues de subir las evidencias. Por favor, contacta al equipo de soporte.";
  //         _setStatus(EvidenceFlowStatus.error);
  //         return false;
  //       },
  //     );
  //   } catch (e) {
  //     _errorMessage = "Ha ocurrido un error inesperado: $e";
  //     _setStatus(EvidenceFlowStatus.error);
  //     debugPrint("❌ EXCEPCIÓN: $e");
  //     return false;
  //   }
  // }

  Future<bool> sendEvidences() async {
    print("DEBUG: Iniciando envío de evidencias");
    print("DEBUG: ID actual: $_id");
    print("DEBUG: Firma presente: ${_signatureBytes != null}");
    print("DEBUG: PDF generado: ${_pdfBytes != null}");
    print("DEBUG: Cantidad de fotos: ${evidences.length}");

    if (_pdfBytes == null || _signatureBytes == null) {
      _errorMessage =
          "Faltan documentos o firma (Firma: ${_signatureBytes != null}, PDF: ${_pdfBytes != null})";
      _setStatus(EvidenceFlowStatus.error);
      return false;
    }

    _setStatus(EvidenceFlowStatus.sending);

    try {
      // 1. Enviar archivos
      await repository.sendPdf(
        serviceId: id,
        pdfBytes: _pdfBytes!,
        receiverName: receiverName,
        receiverDate: confirmationDate,
      );

      await repository.sendSignature(
        serviceId: id,
        signatureBytes: _signatureBytes!,
        receiverName: receiverName,
        receiverDate: confirmationDate,
      );

      // 2. Cambiar estatus en el servidor
      final result =
          await detailServiceApi.changeStatus(serviceId: id, statusId: 10);

      return result.fold(
        (failure) {
          _errorMessage = failure.message;
          _setStatus(EvidenceFlowStatus.error);
          return false;
        },
        (apiResponse) async {
          if (apiResponse.success) {
            await reset(); // Limpiar todo tras el éxito
            _setStatus(EvidenceFlowStatus.success);
            return true;
          }
          _errorMessage = apiResponse.message;
          _setStatus(EvidenceFlowStatus.error);
          return false;
        },
      );
    } catch (e) {
      _errorMessage =
          e.toString(); // Esto usará el toString() de tu ApiException
      _setStatus(EvidenceFlowStatus.error);
      debugPrint("❌ Error capturado en VM: $e");
      return false;
    }
  }

  // =========================================================
  // ACTUALIZACIÓN DE DATOS
  // =========================================================

  void updateReceiverName(String value) {
    _receiverName = value;
    notifyListeners();
  }

  void updateSignature(Uint8List? bytes) {
    _signatureBytes = (bytes == null || bytes.isEmpty) ? null : bytes;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _status = EvidenceFlowStatus.idle;
    notifyListeners();
  }

  void _setStatus(EvidenceFlowStatus status) {
    if (!_isDisposed) {
      _status = status;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  void initCaptureFlow({bool notify = true}) {
    _clearRamCache();
    _evidences.clear();
    _pdfBytes = null;
    _errorMessage = null;
    _status = EvidenceFlowStatus.idle;
    if (notify) notifyListeners();
  }

  void _handleCaptureError(dynamic e) {
    if (e.toString().contains('permission')) {
      _errorMessage =
          "No hay permisos activos para hacer uso de la cámara. Activalos en la configuración de tu teléfono e intenta de nuevo.";
    } else if (e.toString().contains('Memory')) {
      _errorMessage =
          "Tu teléfono tiene poca memoria RAM. Cierra otras apps e intenta de nuevo.";
    } else {
      _errorMessage =
          "El escaneo se interrumpió. Por favor, intenta capturar la imagen otra vez.";
    }
    _setStatus(EvidenceFlowStatus.error);
  }
}
