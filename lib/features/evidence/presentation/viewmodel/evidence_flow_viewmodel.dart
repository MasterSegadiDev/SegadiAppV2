import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

import 'package:segadi/features/evidence/domain/repositories/evidence_repository.dart';
import 'package:segadi/features/evidence/presentation/pages/widgets/evidence_pdf_generator.dart';
import 'package:segadi/features/service_detail/data/repositories/detail_service_repository_impl.dart';
import '../../domain/evidence_entity.dart';

/// Estatus del flujo de evidencias
enum EvidenceFlowStatus { idle, scanning, error, sending, success }

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

  // =========================================================
  // ACCIONES DEL FLUJO
  // =========================================================

  /// Captura de imágenes desde la cámara
  Future<void> scanFromCamera() async {
    if (_status == EvidenceFlowStatus.scanning) return;
    _setStatus(EvidenceFlowStatus.scanning);

    try {
      _clearRamCache(); // Dar aire a la RAM antes de abrir cámara

      final List<String>? paths = await CunningDocumentScanner.getPictures(
        noOfPages: _maxEvidences - _evidences.length,
        isGalleryImportAllowed: false,
      );

      if (paths != null && paths.isNotEmpty) {
        for (final path in paths) {
          _evidences.add(EvidenceEntity(
            path: path,
            filename: path.split('/').last,
          ));
        }
      }
      _setStatus(EvidenceFlowStatus.idle);
    } catch (e) {
      _errorMessage = 'Fallo en cámara o memoria insuficiente';
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
    if (_evidences.isEmpty) return;
    _setStatus(EvidenceFlowStatus.scanning);

    try {
      _pdfBytes = await EvidencePdfGenerator.generate(
        serviceId: id,
        evidences: evidences,
        receiverName: receiverName,
        confirmationDate: confirmationDate,
      );
      _setStatus(EvidenceFlowStatus.idle);
    } catch (e) {
      _errorMessage = "No se pudo generar el documento PDF";
      _setStatus(EvidenceFlowStatus.error);
    }
  }

  /// Envío final de evidencias
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
}
