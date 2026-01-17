import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
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

  EvidenceFlowViewModel(
      {required this.id,
      required this.repository,
      required this.detailServiceApi});

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
    notifyListeners();
  }

  void updateSignature(Uint8List? bytes) {
    _signatureBytes = bytes;

    notifyListeners();
  }

  bool get hasSignature => signatureBytes != null && signatureBytes!.isNotEmpty;

  Future<void> saveSignature(Uint8List bytes) async {
    _signatureBytes = bytes;
    notifyListeners();
  }

  bool get isConfirmationValid =>
      receiverName.trim().isNotEmpty &&
      signatureBytes != null &&
      signatureBytes!.isNotEmpty;

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

  Future<bool> sendEvidences(Uint8List pdfBytes) async {
    if (signatureBytes == null) return false;

    isSending = true;
    notifyListeners();

    try {
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

      final response = await detailServiceApi.changeStatus(
        serviceId: id,
        statusId: 10,
      );

      if (response.success) {
        print('el estatus se ha insertado con exito ${response.message}');
      }

      return true;
    } catch (e) {
      debugPrint('Error sending evidences: $e');
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }
}
