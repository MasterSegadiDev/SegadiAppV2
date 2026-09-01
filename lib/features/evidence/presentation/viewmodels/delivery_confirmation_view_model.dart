import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../domain/entities/delivery_confirmation.dart';
import '../../domain/usecases/send_delivery_confirmation.dart';

enum ConfirmationStatus {
  idle,
  sending,
  success,
  error,
}

class DeliveryConfirmationViewModel extends ChangeNotifier {
  final SendDeliveryConfirmationUseCase sendDeliveryConfirmation;

  DeliveryConfirmationViewModel({
    required this.sendDeliveryConfirmation,
  });

  String _serviceRequestId = '';
  String _receiverName = '';
  String _strDateTime = '';

  Uint8List? _signature;

  ConfirmationStatus _status = ConfirmationStatus.idle;
  String? _errorMessage;

  // =========================================================
  // GETTERS
  // =========================================================

  String get serviceRequestId => _serviceRequestId;

  String get receiverName => _receiverName;

  String get strDateTime => _strDateTime;

  Uint8List? get signature => _signature;

  bool get hasSignature => _signature != null && _signature!.isNotEmpty;

  ConfirmationStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get isSending => _status == ConfirmationStatus.sending;

  bool get isLoading => isSending;

  bool get isSuccess => _status == ConfirmationStatus.success;

  // =========================================================
  // INICIALIZACIÓN
  // =========================================================

  void initialize({
    required String serviceRequestId,
    bool notify = true,
  }) {
    _serviceRequestId = serviceRequestId;

    _receiverName = '';
    _strDateTime = '';
    _signature = null;

    _status = ConfirmationStatus.idle;
    _errorMessage = null;

    if (notify) {
      notifyListeners();
    }
  }

  // =========================================================
  // FORMULARIO
  // =========================================================

  void updateReceiverName(String value) {
    _receiverName = value;
    notifyListeners();
  }

  void updateDateTime(String value) {
    _strDateTime = value;
    notifyListeners();
  }

  void updateSignature(Uint8List? value) {
    _signature = value;
    notifyListeners();
  }

  // =========================================================
  // ENVIAR CONFIRMACIÓN
  // =========================================================

  Future<bool> sendConfirmation() async {
    if (_serviceRequestId.isEmpty) {
      _setError(
        'No se encontró el service request.',
      );
      return false;
    }

    if (_receiverName.trim().isEmpty) {
      _setError(
        'El nombre del remitente es obligatorio.',
      );
      return false;
    }

    if (_strDateTime.trim().isEmpty) {
      _setError(
        'La fecha y hora son obligatorias.',
      );
      return false;
    }

    if (!hasSignature) {
      _setError(
        'La firma es obligatoria.',
      );
      return false;
    }

    _setStatus(
      ConfirmationStatus.sending,
    );

    try {
      final confirmation = DeliveryConfirmation(
        serviceRequestId: _serviceRequestId,
        fileSignature: _signature!,
        strDateTime: _strDateTime,
        strReceiverName: _receiverName.trim(),
      );

      final result = await sendDeliveryConfirmation(
        confirmation,
      );

      if (!result) {
        _setError(
          'No se pudo enviar la confirmación.',
        );
        return false;
      }

      _setStatus(
        ConfirmationStatus.success,
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
  // ESTADO
  // =========================================================

  void clearError() {
    _errorMessage = null;

    if (_status == ConfirmationStatus.error) {
      _status = ConfirmationStatus.idle;
    }

    notifyListeners();
  }

  void _setStatus(ConfirmationStatus status) {
    _status = status;
    _errorMessage = null;

    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = ConfirmationStatus.error;

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

  void reset() {
    _serviceRequestId = '';

    _receiverName = '';
    _strDateTime = '';
    _signature = null;

    _errorMessage = null;
    _status = ConfirmationStatus.idle;

    notifyListeners();
  }
}
