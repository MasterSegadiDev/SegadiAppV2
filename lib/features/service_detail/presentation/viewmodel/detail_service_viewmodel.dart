import 'dart:async';

import 'package:flutter/material.dart';
import 'package:segadi/features/firebase_cloud_messaging.dart/domain/usecases/listen_service_update.dart';
import 'package:segadi/features/service_detail/data/repositories/detail_service_repository_impl.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_permissions.dart';
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

  bool _isDisposed = false;

  DetailServiceStatus status = DetailServiceStatus.initial;
  DetailServiceEntity? entity;
  DetailServiceState? state;
  String? errorMessage;

  bool _navigateToSendEvidence = false;
  bool _evidenceNavigationConsumed = false;

  bool get navigateToSendEvidence =>
      _navigateToSendEvidence && !_evidenceNavigationConsumed;

  bool get isProcessing =>
      _isChangingStatus || status == DetailServiceStatus.loading;

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

  @override
  void notifyListeners() {
    // 🚩 PROTECCIÓN DE ORO: Si ya se hizo dispose, no notificamos nada.
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  bool _isClosingAutomatically = false;
  ///////////////////////////////////////
  //////////// 📦 LOAD DETAIL ////////////
  ///////////////////////////////////////
  Future<void> loadDetail(int id) async {
    debugPrint('📦 Loading detail for serviceId=$id');

    status = DetailServiceStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await repository.getDetail(id);

    // 🚩 CHEQUEO DE SEGURIDAD POST-AWAIT
    if (_isDisposed) return;

    result.fold(
      (failure) {
        status = DetailServiceStatus.error;
        errorMessage = failure.message;
        debugPrint('❌ Error loading detail: $errorMessage');
      },
      (data) {
        _evidenceNavigationConsumed = false;
        entity = data;

        if (data.ui.serviceClosed) {
          _isClosingAutomatically = false;
        }

        if (mustSendEvidence) {
          _navigateToSendEvidence = true;
        }

        state = buildDetailServiceState(data);
        status = DetailServiceStatus.loaded;

        final permissions = DetailServicePermissions(data);

        // Solo ejecutamos el cierre si seguimos vivos
        if (permissions.shouldAutoClose && !_isClosingAutomatically) {
          if (!_isDisposed) _executeSilentClose(id);
        }

        debugPrint('✅ Detail loaded successfully');
      },
    );

    notifyListeners();
  }

  bool _isChangingStatus = false;

  Future<void> changeMandatoryStatus(BuildContext context) async {
    if (entity == null) return;

    // 1. BLOQUEO DE SEGURIDAD: Si ya se está ejecutando, ignoramos el nuevo click
    if (_isChangingStatus) return;

    _isChangingStatus = true; // Iniciamos el bloqueo
    final statusId = entity!.nextMandatoryStatusId;

    debugPrint('estatus a enviar: $statusId');
    _setLoading(); // Tu función existente que debería poner un spinner en el botón

    final result = await repository.changeStatus(
      serviceId: entity!.id,
      statusId: statusId,
    );

    print('🔄 Change status result: $result');

    await result.fold(
      (failure) async {
        final msg = failure.message;
        _setError(msg);
        if (context.mounted) _showSnackBar(context, msg, isError: true);
      },
      (apiResult) async {
        if (!apiResult.success) {
          final msg = apiResult.message ?? 'No se pudo cambiar el estatus';
          _setError(msg);
          if (context.mounted) _showSnackBar(context, msg, isError: true);
        } else {
          // Si todo fue bien, recargamos el detalle
          await loadDetail(entity!.id);
          if (context.mounted) {
            _showSnackBar(context, "Estatus actualizado correctamente",
                isError: false);
          }
        }
      },
    );

    // 2. TIEMPO DE ESPERA FORZADO (5 segundos)
    // Esto evita que el usuario pueda volver a darle click inmediatamente después de que termine la petición
    await Future.delayed(const Duration(seconds: 5));

    _isChangingStatus = false; // Liberamos el bloqueo
    notifyListeners(); // Aseguramos que la UI sepa que ya puede habilitar el botón
  }

  Future<void> _executeSilentClose(int id) async {
    if (_isClosingAutomatically) return;

    _isClosingAutomatically = true; // Bloqueamos la entrada
    debugPrint('🔒 Bloqueando auto-cierre para evitar bucles...');

    final result = await repository.closeService(id: id);

    result.fold(
      (failure) {
        _isClosingAutomatically =
            false; // Liberamos si falló para permitir reintento
        debugPrint('❌ Falló cierre: ${failure.message}');
      },
      (success) {
        debugPrint(
            '✅ Servicio cerrado. Manteniendo candado para evitar recargas infinitas.');
        // IMPORTANTE: Al cargar de nuevo, el flag serviceClosed ya debería venir en true
        loadDetail(id);
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
