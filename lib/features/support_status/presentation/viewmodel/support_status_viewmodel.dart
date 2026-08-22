import 'package:flutter/material.dart';

import '../../domain/entities/support_status_entity.dart';
import '../../domain/usecases/get_support_status_usecase.dart';
import '../../domain/usecases/send_support_status_usecase.dart';

class SupportStatusViewModel extends ChangeNotifier {
  final GetSupportStatusUseCase getSupportStatusUseCase;
  final SendSupportStatusUseCase sendSupportStatusUseCase;

  SupportStatusViewModel({
    required this.getSupportStatusUseCase,
    required this.sendSupportStatusUseCase,
  });

  bool isLoading = false;
  bool isSending = false;

  String? error;

  List<SupportStatusEntity> statuses = [];

  SupportStatusEntity? selectedStatus;

  Future<void> loadStatuses() async {
    try {
      isLoading = true;
      error = null;

      notifyListeners();

      statuses = await getSupportStatusUseCase();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectStatus(
    SupportStatusEntity status,
  ) {
    selectedStatus = status;

    notifyListeners();
  }

  Future<bool> sendStatus({
    required String referralId,
    required String serviceRequestId,
  }) async {
    print('remision id: ${referralId} y servicio id: ${serviceRequestId}');

    if (selectedStatus == null) {
      error = 'Selecciona un estatus de soporte.';
      notifyListeners();
      return false;
    }

    try {
      isSending = true;
      error = null;

      notifyListeners();

      final result = await sendSupportStatusUseCase(
        referralId: referralId,
        serviceRequestId: serviceRequestId,
        statusId: selectedStatus!.id,
      );

      return result;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }
}
