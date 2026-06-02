import 'dart:async';

import 'package:flutter/material.dart';
import 'package:segadi/features/firebase_cloud_messaging.dart/domain/usecases/listen_service_update.dart';
import 'package:segadi/features/service_detail/data/repositories/detail_service_repository_impl.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_permissions.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_state.dart';
import 'package:segadi/features/service_detail/domain/usecases/use_case_change_status.dart';
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
  final ChangeStatusUseCase changeStatusUseCase;

  StreamSubscription? _fcmSub;

  DetailServiceViewModel({
    required this.repository,
    required this.listenServicioUpdates,
    required this.changeStatusUseCase,
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

  bool _recentEvidenceUploaded = false;

  void markEvidenceAsUploaded() {
    _recentEvidenceUploaded = true;
    _navigateToSendEvidence = false;
    _evidenceNavigationConsumed = true;

    notifyListeners();

    Future.delayed(const Duration(seconds: 10), () {
      // 🚩 VALIDACIÓN POST-ESPERA
      if (_isDisposed) return;

      _recentEvidenceUploaded = false;
      debugPrint('🔓 Candado liberado.');
      notifyListeners();
    });
  }

  // Modifica tu getter para que respete el candado
  bool get mustSendEvidence {
    if (entity == null) return false;
    if (_recentEvidenceUploaded) return false; // 🚩 El candado bloquea el envío
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
      // 🛡️ SEGURO DE VIDA: Si acabamos de subir evidencias, ignoramos cualquier
      // actualización externa por unos segundos para evitar el salto a la pantalla de captura.
      if (_recentEvidenceUploaded) {
        debugPrint(
            '🛡️ FCM bloqueado por subida reciente. Ignorando recarga...');
        return;
      }

      if (update.servicioId == serviceId) {
        debugPrint('🎯 FCM update matches service. Reloading detail...');
        await loadDetail(int.parse(serviceId));
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
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
        // entity = data;

        // if (data.ui.serviceClosed) {
        //   _isClosingAutomatically = false;
        // }

        // if (mustSendEvidence) {
        //   _navigateToSendEvidence = true;
        // }

        // state = buildDetailServiceState(data);
        // status = DetailServiceStatus.loaded;

        // final permissions = DetailServicePermissions(data);

        // Solo ejecutamos el cierre si seguimos vivos
        // if (permissions.shouldAutoClose && !_isClosingAutomatically) {
        //   if (!_isDisposed) _executeSilentClose(id);
        // }

        debugPrint('✅ Detail loaded successfully');
      },
    );

    notifyListeners();
  }

  bool _isChangingStatus = false;

  // Future<void> changeMandatoryStatus(BuildContext context) async {
  //   if (entity == null) return;

  //   // 1. BLOQUEO DE SEGURIDAD: Si ya se está ejecutando, ignoramos el nuevo click
  //   if (_isChangingStatus) return;

  //   _isChangingStatus = true; // Iniciamos el bloqueo
  //   final statusId = entity!.nextMandatoryStatusId;

  //   debugPrint('estatus a enviar: $statusId');
  //   _setLoading();

  //   final result = await changeStatusUseCase.execute(
  //     serviceId: entity!.id,
  //     statusId: statusId,
  //   );

  //   print('🔄 Change status result: $result');

  //   await result.fold(
  //     (failure) async {
  //       final msg = failure.message;
  //       _setError(msg);
  //       if (context.mounted) _showSnackBar(context, msg, isError: true);
  //     },
  //     (apiResult) async {
  //       if (!apiResult) {
  //         _setError('No se pudo cambiar el estatus');
  //         if (context.mounted) {
  //           _showSnackBar(context, 'No se pudo cambiar el estatus',
  //               isError: true);
  //         }
  //       } else {
  //         await loadDetail(entity!.id);
  //         if (context.mounted) {
  //           _showSnackBar(context, "Estatus actualizado correctamente",
  //               isError: false);
  //         }
  //       }
  //     },
  //   );

  //   // 2. TIEMPO DE ESPERA FORZADO (5 segundos)
  //   // Esto evita que el usuario pueda volver a darle click inmediatamente después de que termine la petición
  //   await Future.delayed(const Duration(seconds: 5));

  //   _isChangingStatus = false; // Liberamos el bloqueo
  //   notifyListeners(); // Aseguramos que la UI sepa que ya puede habilitar el botón
  // }

  Future<void> changeMandatoryStatus(BuildContext context) async {
    if (entity == null) return;

    // 1. Bloqueo de seguridad para evitar múltiples clics
    if (_isChangingStatus) return;

    try {
      _isChangingStatus = true;

      // 2. Usamos tu función centralizada de carga
      _setLoading();

      final statusId = entity!.nextMandatoryStatusId;
      debugPrint('🚀 Enviando cambio de estatus: $statusId');

      final result = await changeStatusUseCase.execute(
        serviceId: entity!.id,
        statusId: statusId,
      );

      await result.fold(
        (failure) async {
          // 3. Usamos tu función centralizada de error
          _setError(failure.message);
          if (context.mounted) {
            _showSnackBar(context, failure.message, isError: true);
          }
        },
        (success) async {
          if (!success) {
            _setError('No se pudo confirmar el cambio de estatus');
            if (context.mounted) {
              _showSnackBar(context, 'Error en la respuesta del servidor',
                  isError: true);
            }
          } else {
            // 4. Éxito: Recargamos el detalle
            await loadDetail(entity!.id);

            if (context.mounted) {
              _showSnackBar(context, "Estatus actualizado correctamente",
                  isError: false);
            }
          }
        },
      );

      // 5. Cooldown: Mantenemos el botón bloqueado un momento tras terminar
      await Future.delayed(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('💥 Error Crítico: $e');
      _setError('Error inesperado: $e');
    } finally {
      // 6. CIERRE DE SEGURIDAD ABSOLUTO
      _isChangingStatus = false;

      // Si por alguna razón el estatus se quedó en loading (ej. éxito sin error pero sin cambio de estado)
      // lo movemos a loaded para quitar el spinner.
      if (status == DetailServiceStatus.loading) {
        status = DetailServiceStatus.loaded;
      }

      notifyListeners();
    }
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
