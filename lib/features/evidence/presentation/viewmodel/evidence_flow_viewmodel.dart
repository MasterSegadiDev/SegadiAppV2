import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
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

  /// 🔹 Escanear documentos
  Future<void> scanFromCamera() async {
    if (_status == EvidenceFlowStatus.scanning) return;
    if (_evidences.length >= _maxEvidences) return;

    _setStatus(EvidenceFlowStatus.scanning);

    try {
      final List<String>? paths = await CunningDocumentScanner.getPictures(
        noOfPages: _maxEvidences - _evidences.length,
        isGalleryImportAllowed: false,
      );

      if (paths == null || paths.isEmpty) {
        _setStatus(EvidenceFlowStatus.idle);
        return;
      }

      for (final path in paths) {
        if (_evidences.length >= _maxEvidences) break;

        final file = File(path);
        final bytes = await file.readAsBytes();

        _evidences.add(
          EvidenceEntity(
            bytes: bytes,
            filename: file.uri.pathSegments.last,
          ),
        );
      }

      _setStatus(EvidenceFlowStatus.idle);
    } catch (e) {
      _errorMessage = 'Error al escanear documentos';
      _setStatus(EvidenceFlowStatus.error);
    }
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

  /// 🔹 Reset (por si el flujo se cancela)
  void reset() {
    _evidences.clear();
    _errorMessage = null;
    _setStatus(EvidenceFlowStatus.idle);
  }

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
        (apiResponse) {
          if (apiResponse.success) return true;
          _errorMessage =
              apiResponse.message; // Aquí cae el error de negocio del API
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
