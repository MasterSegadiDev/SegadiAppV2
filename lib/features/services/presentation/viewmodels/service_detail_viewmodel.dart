import 'package:flutter/material.dart';

import 'package:segadi/features/services/domain/entities/recipient_entity.dart';
import 'package:segadi/features/services/domain/entities/sender_entity.dart';
import 'package:segadi/features/services/domain/entities/service_actions_entity.dart';
import 'package:segadi/features/services/domain/entities/service_general_entity.dart';
import 'package:segadi/features/services/domain/entities/service_status_entity.dart';
import 'package:segadi/features/services/domain/entities/support_status_current_entity.dart';
import 'package:segadi/features/services/domain/entities/update_mandatory_status_entity.dart';

import 'package:segadi/features/services/domain/usecases/get_detail_service_actions_usecase.dart';
import 'package:segadi/features/services/domain/usecases/get_detail_service_info_general_usecase.dart';
import 'package:segadi/features/services/domain/usecases/get_service_status_usecase.dart';
import 'package:segadi/features/services/domain/usecases/update_mandatory_status_usecase.dart';

import 'package:segadi/features/services/presentation/models/service_action_item.dart';
import 'package:segadi/features/services/presentation/models/service_detail_arguments.dart';

class ServiceDetailViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final GetServiceGeneralUseCase getServiceGeneralUseCase;
  final GetServiceActionsUseCase getServiceActionsUseCase;
  final GetServiceStatusUseCase getServiceStatusUseCase;
  final UpdateMandatoryStatusUseCase updateMandatoryStatusUseCase;

  ServiceDetailViewModel({
    required this.getServiceGeneralUseCase,
    required this.getServiceActionsUseCase,
    required this.getServiceStatusUseCase,
    required this.updateMandatoryStatusUseCase,
  });

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  ServiceDetailArguments? _arguments;

  ServiceDetailArguments? get arguments => _arguments;

  bool isInitialized = false;
  bool isLoading = false;
  bool isRefreshing = false;

  String? error;

  ServiceGeneralEntity? service;
  ServiceActionsEntity? serviceActions;
  ServiceStatusEntity? serviceStatus;

  // ---------------------------------------------------------------------------
  // Computed state
  // ---------------------------------------------------------------------------

  bool get hasError => error != null;

  bool get hasService => service != null;

  bool get hasActions => serviceActions != null;

  bool get hasStatus => serviceStatus != null;

  String get serviceNumber {
    return _arguments?.serviceNumber ?? '';
  }

  String get idRemision {
    return _arguments?.idRemision ?? '';
  }

  String get idSolicitud {
    return _arguments?.idSolicitud ?? '';
  }

  SenderEntity? get sender {
    return service?.sender;
  }

  RecipientEntity? get recipient {
    return service?.recipient;
  }

  bool get enableStatusButton {
    return serviceStatus?.enableBtn ?? false;
  }

  String get nextStatusName {
    return serviceStatus?.nextMandatoryStatus ?? '';
  }

  String get nextStatusId {
    return serviceStatus?.nextMandatoryStatusId ?? '';
  }

  SupportStatusCurrentEntity? get currentSupportStatus {
    return serviceStatus?.supportStatus;
  }

  bool get requiresConfirmation {
    return service?.blnConfirmation == false;
  }

  bool get requiresEvidence {
    return service?.blnConfirmation == true && service?.blnEvidence == false;
  }

  bool get flowCompleted {
    return service?.blnConfirmation == true && service?.blnEvidence == true;
  }

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<void> initialize(ServiceDetailArguments args) async {
    // Guardamos los argumentos ANTES de cualquier operación async.
    _arguments = args;

    isInitialized = false;
    isLoading = true;
    error = null;

    notifyListeners();

    try {
      await Future.wait([
        getServiceGeneral(args.idSolicitud),
        getServiceActions(args.idSolicitud),
        getServiceStatus(args.idSolicitud),
      ]);

      isInitialized = true;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Service General
  // ---------------------------------------------------------------------------

  Future<void> getServiceGeneral(String referralId) async {
    service = await getServiceGeneralUseCase(referralId);
  }

  // ---------------------------------------------------------------------------
  // Service Actions
  // ---------------------------------------------------------------------------

  Future<void> getServiceActions(String referralId) async {
    serviceActions = await getServiceActionsUseCase(referralId);
  }

  // ---------------------------------------------------------------------------
  // Service Status
  // ---------------------------------------------------------------------------

  Future<void> getServiceStatus(String referralId) async {
    serviceStatus = await getServiceStatusUseCase(referralId);
  }

  // ---------------------------------------------------------------------------
  // Refresh
  // ---------------------------------------------------------------------------

  Future<void> refreshServiceState() async {
    final args = _arguments;

    // Si por alguna razón todavía no existen argumentos,
    // simplemente no hacemos nada.
    if (args == null) {
      return;
    }

    try {
      isRefreshing = true;
      error = null;

      notifyListeners();

      await Future.wait([
        getServiceGeneral(args.idSolicitud),
        getServiceActions(args.idSolicitud),
        getServiceStatus(args.idSolicitud),
      ]);
    } catch (e) {
      error = e.toString();
    } finally {
      isRefreshing = false;

      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Update Mandatory Status
  // ---------------------------------------------------------------------------

  Future<bool> updateMandatoryStatus() async {
    final args = _arguments;

    if (args == null) {
      error = 'No se han inicializado los argumentos del servicio.';
      notifyListeners();
      return false;
    }

    if (nextStatusId.isEmpty) {
      error = 'No existe un siguiente estatus disponible.';
      notifyListeners();
      return false;
    }

    try {
      isRefreshing = true;
      error = null;

      notifyListeners();

      final result = await updateMandatoryStatusUseCase(
        UpdateMandatoryStatusParams(
          referralId: args.idRemision,
          serviceRequestId: args.idSolicitud,
          statusId: nextStatusId,
        ),
      );

      serviceStatus = ServiceStatusEntity(
        enableBtn: serviceStatus?.enableBtn ?? false,
        nextMandatoryStatus: result.nextMandatoryStatus,
        nextMandatoryStatusId: result.nextMandatoryStatusId,
        supportStatus: serviceStatus?.supportStatus,
      );

      await getServiceActions(args.idSolicitud);

      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isRefreshing = false;

      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Refresh after support
  // ---------------------------------------------------------------------------

  Future<void> refreshAfterSupport() async {
    final args = _arguments;

    if (args == null) {
      return;
    }

    try {
      isRefreshing = true;
      error = null;

      notifyListeners();

      await Future.wait([
        getServiceActions(args.idSolicitud),
        getServiceStatus(args.idSolicitud),
      ]);
    } catch (e) {
      error = e.toString();
    } finally {
      isRefreshing = false;

      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Action items
  // ---------------------------------------------------------------------------

  List<ServiceActionItem> get actionItems {
    final actions = serviceActions;

    if (actions == null) {
      return const [];
    }

    return [
      ServiceActionItem(
        title: 'Chequeo Unidad',
        icon: Icons.checklist,
        enabled: actions.checklist.enabled,
        show: actions.checklist.show,
        key: 'checklist',
      ),
      ServiceActionItem(
        title: 'Estatus Soporte',
        icon: Icons.headset,
        enabled: actions.support.enabled,
        show: actions.support.show,
        key: 'support',
      ),
      ServiceActionItem(
        title: 'Geo Ruta',
        icon: Icons.route,
        enabled: actions.route.enabled,
        show: actions.route.show,
        key: 'route',
      ),
      ServiceActionItem(
        title: 'Cerrar Viaje',
        icon: Icons.check_circle,
        enabled: actions.closeEvidence.enabled,
        show: actions.closeEvidence.show,
        key: 'close_evidence',
      ),
      ServiceActionItem(
        title: 'Viáticos',
        icon: Icons.money,
        enabled: actions.travelExpenses.enabled,
        show: actions.travelExpenses.show,
        key: 'travel_expenses',
      ),
      ServiceActionItem(
        title: 'Descargar CCP',
        icon: Icons.picture_as_pdf,
        enabled: actions.downloadCcp.enabled,
        show: actions.downloadCcp.show,
        key: 'download_ccp',
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Clear state
  // ---------------------------------------------------------------------------

  void clearError() {
    error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
