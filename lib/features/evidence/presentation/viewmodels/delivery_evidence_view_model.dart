import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:segadi/core/device/scanner/scanner_service.dart';

import '../../domain/entities/delivery_evidence.dart';
import '../../domain/usecases/send_delivery_evidences.dart';

enum EvidenceStatus {
  idle,
  scanning,
  sending,
  success,
  error,
}

class DeliveryEvidenceViewModel extends ChangeNotifier {
  final SendDeliveryEvidencesUseCase sendDeliveryEvidences;
  final ScannerService scannerService;

  DeliveryEvidenceViewModel({
    required this.sendDeliveryEvidences,
    required this.scannerService,
  });

  static const int maxEvidences = 5;

  String _serviceRequestId = '';
  String _referralId = '';

  final List<List<String>> _evidences = [];

  String _notes = '';

  EvidenceStatus _status = EvidenceStatus.idle;
  String? _errorMessage;

  // =========================================================
  // GETTERS
  // =========================================================

  String get serviceRequestId => _serviceRequestId;

  String get referralId => _referralId;

  List<List<String>> get evidences => List.unmodifiable(_evidences);

  int get evidenceCount => _evidences.length;

  bool get hasEvidences => _evidences.isNotEmpty;

  bool get canScanMore => _evidences.length < maxEvidences;

  String get notes => _notes;

  EvidenceStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get isScanning => _status == EvidenceStatus.scanning;

  bool get isSending => _status == EvidenceStatus.sending;

  bool get isLoading => isScanning || isSending;

  bool get isSuccess => _status == EvidenceStatus.success;

  // =========================================================
  // INICIALIZACIÓN
  // =========================================================

  void initialize({
    required String serviceRequestId,
    required String referralId,
    bool notify = true,
  }) {
    _serviceRequestId = serviceRequestId;
    _referralId = referralId;

    _evidences.clear();

    _notes = '';

    _status = EvidenceStatus.idle;
    _errorMessage = null;

    if (notify) {
      notifyListeners();
    }
  }

  // =========================================================
  // SCANNER
  // =========================================================

  Future<void> scanEvidence() async {
    if (!canScanMore) {
      _setError(
        'Solo puedes capturar un máximo de '
        '$maxEvidences evidencias.',
      );
      return;
    }

    _setStatus(
      EvidenceStatus.scanning,
    );

    try {
      final scannedImages = await scannerService.scanDocument();

      // El usuario canceló el scanner.
      if (scannedImages.isEmpty) {
        _setStatus(
          EvidenceStatus.idle,
        );
        return;
      }

      // Una ejecución del scanner = una evidencia.
      _evidences.add(
        List<String>.from(scannedImages),
      );

      _setStatus(
        EvidenceStatus.idle,
      );
    } catch (e) {
      _setError(
        _parseError(e),
      );
    }
  }

  // =========================================================
  // ELIMINAR EVIDENCIA
  // =========================================================

  Future<void> removeEvidence(int index) async {
    if (index < 0 || index >= _evidences.length) {
      return;
    }

    final evidence = _evidences[index];

    _evidences.removeAt(index);

    notifyListeners();

    for (final path in evidence) {
      try {
        final file = File(path);

        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint(
          'Error eliminando evidencia: $e',
        );
      }
    }
  }

  // =========================================================
  // NOTAS
  // =========================================================

  void updateNotes(String value) {
    _notes = value;
    notifyListeners();
  }

  // =========================================================
  // ENVIAR EVIDENCIAS
  // =========================================================

  Future<bool> sendEvidences() async {
    if (_serviceRequestId.isEmpty) {
      _setError(
        'No se encontró el service request.',
      );
      return false;
    }

    if (_referralId.isEmpty) {
      _setError(
        'No se encontró el referral.',
      );
      return false;
    }

    if (_evidences.isEmpty) {
      _setError(
        'Debes escanear al menos una evidencia.',
      );
      return false;
    }

    if (_evidences.length > maxEvidences) {
      _setError(
        'No puedes enviar más de '
        '$maxEvidences evidencias.',
      );
      return false;
    }

    _setStatus(
      EvidenceStatus.sending,
    );

    try {
      final evidence = DeliveryEvidence(
        serviceRequestId: _serviceRequestId,
        evidence1: _getEvidence(0),
        evidence2: _getEvidence(1),
        evidence3: _getEvidence(2),
        evidence4: _getEvidence(3),
        evidence5: _getEvidence(4),
        notes: _notes.trim(),
        referralId: _referralId,
      );

      final result = await sendDeliveryEvidences(
        evidence,
      );

      if (!result) {
        _setError(
          'No se pudieron enviar las evidencias.',
        );
        return false;
      }

      _setStatus(
        EvidenceStatus.success,
      );

      return true;
    } catch (e) {
      _setError(
        _parseError(e),
      );

      return false;
    }
  }

  // =========================================================
  // OBTENER EVIDENCIA
  // =========================================================

  File? _getEvidence(int index) {
    if (index >= _evidences.length) {
      return null;
    }

    final pages = _evidences[index];

    if (pages.isEmpty) {
      return null;
    }

    /*
     * Por ahora tomamos la primera página.
     *
     * Si un escaneo tiene varias páginas,
     * posteriormente podemos definir cómo
     * convertirlas en un único archivo.
     */
    return File(pages.first);
  }

  // =========================================================
  // ESTADO
  // =========================================================

  void clearError() {
    _errorMessage = null;

    if (_status == EvidenceStatus.error) {
      _status = EvidenceStatus.idle;
    }

    notifyListeners();
  }

  void _setStatus(EvidenceStatus status) {
    _status = status;
    _errorMessage = null;

    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = EvidenceStatus.error;

    notifyListeners();
  }

  String _parseError(dynamic error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst(
        'Exception: ',
        '',
      );
    }

    return message;
  }

  // =========================================================
  // RESET
  // =========================================================

  Future<void> reset() async {
    final evidences = List<List<String>>.from(
      _evidences.map(
        (evidence) => List<String>.from(evidence),
      ),
    );

    _serviceRequestId = '';
    _referralId = '';

    _evidences.clear();

    _notes = '';

    _errorMessage = null;
    _status = EvidenceStatus.idle;

    notifyListeners();

    for (final evidence in evidences) {
      for (final path in evidence) {
        try {
          final file = File(path);

          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint(
            'Error eliminando archivo: $e',
          );
        }
      }
    }
  }
}
