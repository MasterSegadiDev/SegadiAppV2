import 'package:flutter/material.dart';
import 'package:segadi/features/service_detail/data/repositories/detail_service_repository_impl.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_state.dart';
import 'package:segadi/features/service_detail/domain/usecases/use_case_detail_service_state.dart';

enum DetailServiceStatus {
  initial,
  loading,
  loaded,
  error,
}

class DetailServiceViewModel extends ChangeNotifier {
  final DetailServiceRepositoryImpl repository;

  DetailServiceViewModel(this.repository);

  DetailServiceStatus status = DetailServiceStatus.initial;
  DetailServiceEntity? entity;
  DetailServiceState? state;
  String? errorMessage;

  bool _navigateToSendEvidence = false;
  bool _evidenceNavigationConsumed = false;

  bool get navigateToSendEvidence =>
      _navigateToSendEvidence && !_evidenceNavigationConsumed;

  /// 🔹 Regla de negocio
  bool get mustSendEvidence {
    if (entity == null) return false;
    return entity!.nextMandatoryStatusId == 10 && entity!.isEvidence == false;
  }

  void consumeNavigation() {
    _evidenceNavigationConsumed = true;
    _navigateToSendEvidence = false;
  }

  Future<void> loadDetail(int id) async {
    status = DetailServiceStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      entity = await repository.getDetail(id);

      _evidenceNavigationConsumed = false;

      if (mustSendEvidence) {
        _navigateToSendEvidence = true;
      }

      // 🔥 AQUÍ ESTÁ LA CLAVE
      state = buildDetailServiceState(entity!);

      status = DetailServiceStatus.loaded;
    } catch (e) {
      status = DetailServiceStatus.error;
      errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> changeMandatoryStatus(BuildContext context) async {
    if (entity == null) return;

    final statusId = entity!.nextMandatoryStatusId;

    _setLoading();

    final result = await repository.changeStatus(
      serviceId: entity!.id,
      statusId: statusId,
    );

    if (!result.success) {
      _setError(result.message ?? 'No se pudo cambiar el estatus');
      return;
    }

    await loadDetail(entity!.id);
  }

  void _setLoading() {
    status = DetailServiceStatus.loading;
    errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    status = DetailServiceStatus.error;
    errorMessage = message;
    notifyListeners();
  }

  void retry(int id) => loadDetail(id);
}
