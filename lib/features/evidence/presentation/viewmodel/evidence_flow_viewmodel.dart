import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:segadi/core/network/api_exceptions.dart';
import 'package:segadi/features/evidence/domain/repositories/evidence_repository.dart';
import 'package:segadi/features/evidence/presentation/pages/widgets/evidence_pdf_generator.dart';
import 'package:segadi/features/service_detail/data/repositories/detail_service_repository_impl.dart';
import '../../domain/evidence_entity.dart';

enum EvidenceFlowStatus { idle, scanning, error, sending, success }

class EvidenceFlowViewModel extends ChangeNotifier {
  final int id;

  // final SendEvidenceUseCase sendEvidenceUseCase;
  final EvidenceRepository repository;
  final DetailServiceRepositoryImpl detailServiceApi;

  EvidenceFlowViewModel({
    required this.id,
    required this.repository,
    required this.detailServiceApi,
  });

  bool _isDisposed = false;

  /// 🔹 Evidencias
  final List<EvidenceEntity> _evidences = [];
  List<EvidenceEntity> get evidences => List.unmodifiable(_evidences);

  /// 🔹 Estado
  EvidenceFlowStatus _status = EvidenceFlowStatus.idle;
  EvidenceFlowStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  static const int _maxEvidences = 5;

  //////pdf preview page
  Uint8List? _pdfBytes;
  Uint8List? get pdfBytes => _pdfBytes;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> scanFromCamera() async {
    if (_status == EvidenceFlowStatus.scanning) return;
    if (_evidences.length >= _maxEvidences) return;

    _setStatus(EvidenceFlowStatus.scanning);

    try {
      // 1. LIMPIEZA PREVENTIVA: Liberamos caché de imágenes de Flutter antes de abrir la cámara
      // Esto da aire a la GPU/RAM para el proceso del scanner.
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      final List<String>? paths = await CunningDocumentScanner.getPictures(
        noOfPages: _maxEvidences - _evidences.length,
        isGalleryImportAllowed: false,
      );

      if (paths == null || paths.isEmpty) {
        _setStatus(EvidenceFlowStatus.idle);
        return;
      }

      // 2. PEQUEÑA PAUSA TÉCNICA
      // Damos tiempo al sistema para cerrar la interfaz de la cámara antes de procesar bytes pesados
      await Future.delayed(const Duration(milliseconds: 300));

      for (final path in paths) {
        final file = File(path);
        if (!await file.exists()) continue;

        // 3. PROCESAMIENTO SEGURO
        // Leemos los bytes pero envolviéndolo en un try por si el archivo está bloqueado
        try {
          final bytes = await file.readAsBytes();

          _evidences.add(
            EvidenceEntity(
              bytes: bytes,
              filename: file.uri.pathSegments.last,
            ),
          );

          // 4. LIBERACIÓN DE MEMORIA NATIVA
          // Borramos el archivo físico para que la memoria del teléfono no se llene
          await file.delete();
        } catch (e) {
          debugPrint("⚠️ Error procesando archivo individual: $e");
        }
      }

      // 5. NOTIFICACIÓN FINAL SEGURA
      // Usamos addPostFrameCallback si el error de "widget tree locked" persiste
      _setStatus(EvidenceFlowStatus.idle);
    } catch (e) {
      debugPrint("❌ Crash en scanner: $e");
      _errorMessage =
          'Error al escanear: memoria insuficiente o fallo de cámara';
      _setStatus(EvidenceFlowStatus.error);
    }
  }

  void reset() {
    _evidences.clear(); // Limpia las fotos escaneadas
    _signatureBytes = null; // Limpia la firma
    _receiverName = ''; // Limpia el nombre
    _pdfBytes = null; // Limpia el PDF generado
    _errorMessage = null;
    _status = EvidenceFlowStatus.idle;
    notifyListeners();
    debugPrint("Flujo de evidencias reseteado y memoria liberada.");
  }

  void initCaptureFlow({bool notify = true}) {
    _evidences.clear();
    _pdfBytes = null;
    _errorMessage = null;
    _status = EvidenceFlowStatus.idle;

    // Limpieza de caché de imágenes
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    // 🚩 LA CLAVE: Solo notificamos si no estamos en un ciclo de vida crítico (como dispose)
    if (notify) {
      notifyListeners();
    }

    debugPrint("🚀 Datos reseteados (Notificación: $notify)");
  }

  /// 🔹 Eliminar evidencia
  void removeEvidence(int index) {
    if (index < 0 || index >= _evidences.length) return;

    _evidences.removeAt(index);
    notifyListeners();
  }

  /// 🔹 Validaciones
  bool get hasEvidences => _evidences.isNotEmpty;
  bool get canScanMore => _evidences.length < _maxEvidences;

  void _setStatus(EvidenceFlowStatus status) {
    _status = status;
    notifyListeners();
  }

  // ========================
// CONFIRMACIÓN
// ========================

  String _receiverName = '';
  String get receiverName => _receiverName;

  Uint8List? _signatureBytes;
  Uint8List? get signatureBytes => _signatureBytes;

  final DateTime _confirmationDate = DateTime.now();
  DateTime get confirmationDate => _confirmationDate;

  void updateReceiverName(String value) {
    _receiverName = value;
    notifyListeners(); // Esto activa el botón cuando escriben
  }

  void updateSignature(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) {
      _signatureBytes = null;
    } else {
      _signatureBytes = bytes;
    }
    notifyListeners(); // Esto activa el botón cuando firman
  }

  bool get hasSignature => signatureBytes != null && signatureBytes!.isNotEmpty;

  Future<void> saveSignature(Uint8List bytes) async {
    _signatureBytes = bytes;
    notifyListeners();
  }

  bool get isConfirmationValid {
    final hasName = _receiverName.trim().length > 3; // Al menos 4 caracteres
    final hasSign = _signatureBytes != null && _signatureBytes!.isNotEmpty;
    return hasName && hasSign;
  }
  ///////////////////////////////////
  ////  GENERAR PDF
  //////////////////////////////////

  Future<Uint8List> generatePdf() async {
    return EvidencePdfGenerator.generate(
      serviceId: id,
      evidences: evidences,
      receiverName: receiverName,
      confirmationDate: confirmationDate,
      //signatureBytes: signatureBytes!,
    );
  }

  Future<void> buildPdf() async {
    _pdfBytes = await EvidencePdfGenerator.generate(
      serviceId: id,
      evidences: evidences,
      receiverName: receiverName,
      confirmationDate: confirmationDate,
    );
    notifyListeners();
  }

  bool isSending = false;

  // Future<bool> sendEvidences(Uint8List pdfBytes) async {
  //   if (signatureBytes == null) return false;

  //   isSending = true;
  //   notifyListeners();

  //   try {
  //     // 1. Envíos de archivos
  //     await repository.sendPdf(
  //       serviceId: id,
  //       pdfBytes: pdfBytes,
  //       receiverName: receiverName,
  //       receiverDate: confirmationDate,
  //     );

  //     await repository.sendSignature(
  //       serviceId: id,
  //       signatureBytes: signatureBytes!,
  //       receiverName: receiverName,
  //       receiverDate: confirmationDate,
  //     );

  //     // 2. Cambio de estatus (Manejo de Either)
  //     final result = await detailServiceApi.changeStatus(
  //       serviceId: id,
  //       statusId: 10,
  //     );

  //     // Usamos fold para "abrir" la caja del Either
  //     bool isStatusOk = result.fold(
  //       (failure) {
  //         debugPrint('❌ Error de red/servidor: ${failure.message}');
  //         return false;
  //       },
  //       (apiResponse) {
  //         if (apiResponse.success) {
  //           debugPrint('✅ Estatus insertado con éxito: ${apiResponse.message}');
  //           return true;
  //         } else {
  //           debugPrint(
  //               '⚠️ El servidor respondió error: ${apiResponse.message}');
  //           return false;
  //         }
  //       },
  //     );

  //     return isStatusOk; // Retorna true solo si el estatus se cambió bien
  //   } catch (e) {
  //     debugPrint('❌ Error fatal enviando evidencias: $e');
  //     return false;
  //   } finally {
  //     isSending = false;
  //     notifyListeners();
  //   }
  // }

  Future<bool> sendEvidences(Uint8List pdfBytes) async {
    if (signatureBytes == null) return false;

    isSending = true;
    _errorMessage = null; // Limpiamos errores previos
    notifyListeners();

    try {
      // 1. Envíos de archivos (Capturamos el mensaje de ApiException)
      await repository.sendPdf(
        serviceId: id,
        pdfBytes: pdfBytes,
        receiverName: receiverName,
        receiverDate: confirmationDate,
      );

      await repository.sendSignature(
        serviceId: id,
        signatureBytes: signatureBytes!,
        receiverName: receiverName,
        receiverDate: confirmationDate,
      );

      // 2. Cambio de estatus
      final result = await detailServiceApi.changeStatus(
        serviceId: id,
        statusId: 10,
      );

      return result.fold(
        (failure) {
          _errorMessage = failure.message; // Aquí cae el error de red
          notifyListeners();
          return false;
        },
        // (apiResponse) {
        //   if (apiResponse.success) return true;
        //   _errorMessage = apiResponse.message;
        //   reset(); // Aquí cae el error de negocio del API
        //   notifyListeners();
        //   return false;
        // },
        (apiResponse) {
          if (apiResponse.success) {
            reset();
            return true;
          }
          _errorMessage = apiResponse.message;
          notifyListeners();
          return false;
        },
      );
    } on ApiException catch (e) {
      _errorMessage = e.message; // "Existe un estatus de soporte iniciado..."
      return false;
    } catch (e) {
      _errorMessage = 'Error fatal: ${e.toString()}';
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }
}
