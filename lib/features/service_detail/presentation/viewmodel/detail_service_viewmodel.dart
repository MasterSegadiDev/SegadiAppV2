import 'dart:async';

import 'package:flutter/material.dart';
import 'package:segadi/features/firebase_cloud_messaging.dart/domain/usecases/listen_service_update.dart';
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
  final ListenServicioUpdates listenServicioUpdates;

  StreamSubscription? _fcmSub;

  DetailServiceViewModel(
    this.repository,
    this.listenServicioUpdates,
  );

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

  ///////////////////////////////////////
  //////////// 🔔 FCM LISTENER ///////////
  ///////////////////////////////////////

  void init(String serviceId) {
    debugPrint('🧠 DetailServiceVM init (FCM) for serviceId=$serviceId');

    _fcmSub = listenServicioUpdates().listen((update) async {
      debugPrint('🔁 VM received FCM update: '
          'id=${update.servicioId}, estado=${update.nuevoEstado}');

      if (update.servicioId == serviceId) {
        debugPrint('🎯 FCM update matches service. Reloading detail...');
        await loadDetail(int.parse(serviceId)); // 🔥 clave
      } else {
        debugPrint('⏭ FCM update ignored (different service)');
      }
    });
  }

  @override
  void dispose() {
    _fcmSub?.cancel();
    super.dispose();
  }

  ///////////////////////////////////////
  //////////// 📦 LOAD DETAIL ////////////
  ///////////////////////////////////////

  Future<void> loadDetail(int id) async {
    debugPrint('📦 Loading detail for serviceId=$id');

    status = DetailServiceStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      entity = await repository.getDetail(id);

      _evidenceNavigationConsumed = false;

      if (mustSendEvidence) {
        _navigateToSendEvidence = true;
      }

      state = buildDetailServiceState(entity!);

      status = DetailServiceStatus.loaded;

      debugPrint('✅ Detail loaded successfully');
    } catch (e) {
      status = DetailServiceStatus.error;
      errorMessage = e.toString();

      debugPrint('❌ Error loading detail: $errorMessage');
    }

    notifyListeners();
  }

  ///////////////////////////////////////
  ///////// 🔄 CHANGE STATUS ////////////
  ///////////////////////////////////////

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

  ///////////////////////////////////////
  //////////// 🛠 HELPERS ///////////////
  ///////////////////////////////////////

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
