import 'package:flutter/material.dart';
import 'package:segadi/features/services/domain/entities/recipient_entity.dart';
import 'package:segadi/features/services/domain/entities/sender_entity.dart';
import 'package:segadi/features/services/domain/entities/service_actions_entity.dart';
import 'package:segadi/features/services/domain/entities/service_general_entity.dart';
import 'package:segadi/features/services/domain/entities/service_status_entity.dart';
import 'package:segadi/features/services/domain/entities/update_mandatory_status_entity.dart';
import 'package:segadi/features/services/domain/usecases/get_detail_service_actions_usecase.dart';
import 'package:segadi/features/services/domain/usecases/get_detail_service_info_general_usecase.dart';
import 'package:segadi/features/services/domain/usecases/get_detail_service_status_button_usecase.dart';
import 'package:segadi/features/services/domain/usecases/update_mandatory_status_usecase.dart';
import 'package:segadi/features/services/presentation/models/service_action_item.dart';
import 'package:segadi/features/services/presentation/models/service_detail_arguments.dart';

class ServiceDetailViewModel extends ChangeNotifier {
  late ServiceDetailArguments arguments;

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

  bool isLoading = false;
  bool isRefreshing = false;
  String? error;

  ServiceGeneralEntity? service;
  ServiceActionsEntity? serviceActions;
  ServiceStatusEntity? serviceStatus;

  Future<void> initialize(
    ServiceDetailArguments args,
  ) async {
    arguments = args;

    try {
      isLoading = true;
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
      isLoading = false;
      notifyListeners();
    }
  }

  SenderEntity get sender => service!.sender;
  RecipientEntity get recipient => service!.recipient;
  String get serviceNumber => arguments.serviceNumber;

  bool get enableStatusButton => serviceStatus?.enableBtn ?? false;
  String get nextStatusName => serviceStatus?.nextMandatoryStatus ?? '';
  String get nextStatusId => serviceStatus?.nextMandatoryStatusId ?? '';

  Future<void> refreshServiceState(
    String referralId,
  ) async {
    try {
      isRefreshing = true;
      error = null;
      notifyListeners();

      await Future.wait([
        getServiceActions(referralId),
        getServiceStatus(referralId),
      ]);
    } catch (e) {
      error = e.toString();
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> getServiceGeneral(
    String referralId,
  ) async {
    service = await getServiceGeneralUseCase(
      referralId,
    );
  }

  Future<void> getServiceActions(
    String referralId,
  ) async {
    serviceActions = await getServiceActionsUseCase(
      referralId,
    );
  }

  Future<void> getServiceStatus(
    String referralId,
  ) async {
    serviceStatus = await getServiceStatusUseCase(
      referralId,
    );
  }

  List<ServiceActionItem> get actionItems {
    final actions = serviceActions;

    if (actions == null) {
      return [];
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

  Future<bool> updateMandatoryStatus() async {
    try {
      isRefreshing = true;
      error = null;
      notifyListeners();

      final result = await updateMandatoryStatusUseCase(
        UpdateMandatoryStatusParams(
          referralId: arguments.idRemision,
          serviceRequestId: arguments.idSolicitud,
          statusId: nextStatusId,
        ),
      );

      // Actualizamos el estado local
      serviceStatus = ServiceStatusEntity(
        enableBtn: serviceStatus?.enableBtn ?? false,
        nextMandatoryStatus: result.nextMandatoryStatus,
        nextMandatoryStatusId: result.nextMandatoryStatusId,
      );

      // Las acciones sí las volvemos a consultar
      await getServiceActions(
        arguments.idSolicitud,
      );

      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> refreshAfterSupport() async {
    try {
      isRefreshing = true;
      error = null;
      notifyListeners();

      await getServiceActions(
        arguments.idSolicitud,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }
}
