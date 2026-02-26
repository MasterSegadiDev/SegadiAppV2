import 'dart:async';

import 'package:dio/dio.dart';
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

  DetailServiceViewModel({
    required this.repository,
    required this.listenServicioUpdates,
  });

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

    // El repositorio ahora devuelve el Either (Left: Failure, Right: Data)
    final result = await repository.getDetail(id);

    result.fold(
      (failure) {
        // ❌ Caso de Error
        status = DetailServiceStatus.error;
        errorMessage = failure.message;
        debugPrint('❌ Error loading detail: $errorMessage');
      },
      (data) {
        // ✅ Caso de Éxito
        _evidenceNavigationConsumed = false;

        // 1. Asignamos la data a la entidad primero
        entity = data;

        // 2. Validamos la lógica de evidencia
        if (mustSendEvidence) {
          _navigateToSendEvidence = true;
        }

        // 3. Construimos el estado visual usando la entidad ya cargada
        // Usamos data directamente para evitar el force unwrap (!) si prefieres
        state = buildDetailServiceState(data);

        status = DetailServiceStatus.loaded;
        debugPrint('✅ Detail loaded successfully');
      },
    );

    notifyListeners();
  }

  ///////////////////////////////////////
  ///////// 🔄 CHANGE STATUS ////////////
  ///////////////////////////////////////

  Future<void> changeMandatoryStatus(BuildContext context) async {
    if (entity == null) return;
    final statusId = entity!.nextMandatoryStatusId;

    debugPrint('estatus a enviar: $statusId');
    _setLoading();

    final result = await repository.changeStatus(
      serviceId: entity!.id,
      statusId: statusId,
    );

    print('🔄 Change status result: $result');

    // ✅ Usamos fold como único flujo de decisión
    await result.fold(
      (failure) async {
        final msg = failure.message;
        _setError(msg);
        if (context.mounted) _showSnackBar(context, msg, isError: true);
      },
      (apiResult) async {
        // 1. Verificamos si el API respondió success: true
        if (!apiResult.success) {
          final msg = apiResult.message ?? 'No se pudo cambiar el estatus';
          _setError(msg);
          if (context.mounted) _showSnackBar(context, msg, isError: true);
          return; // Salimos si falló el backend
        }

        // 2. SI EL ESTATUS ES 14, EVALUAMOS EL CIERRE AUTOMÁTICO
        if (statusId == 23) {
          final bool checksPendientes = entity!.pendingMoneyChecks;
          debugPrint(
              'Evaluando cierre: checksPendientes es ${checksPendientes} en la remision ${entity!.id}');

          if (checksPendientes == false) {
            debugPrint('🚀 Ejecutando closeService automático...');
            final closeResult = await repository.closeService(id: entity!.id);

            closeResult.fold(
              (f) => debugPrint('❌ Error al cerrar el servicio: ${f.message}'),
              (s) => debugPrint('✅ Servicio cerrado automáticamente'),
            );
          } else {
            debugPrint('⚠️ Pendientes detectados, no se ejecuta closeService');
          }
        }

        // 3. ÉXITO: Recargamos la información para actualizar la UI
        await loadDetail(entity!.id);

        if (context.mounted) {
          _showSnackBar(context, "Estatus actualizado correctamente",
              isError: false);
        }
      },
    );
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

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
