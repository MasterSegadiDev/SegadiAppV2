//import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:segadi/features/services/domain/entities/update_mandatory_status_entity.dart';
import 'package:segadi/features/services/domain/enums/service_action.dart';
import 'package:segadi/features/services/domain/usecases/get_detail_service_actions_usecase.dart';
import 'package:segadi/features/services/domain/usecases/get_detail_service_info_general_usecase.dart';
import 'package:segadi/features/services/domain/usecases/get_service_status_usecase.dart';
import 'package:segadi/features/services/domain/usecases/resolve_evidence_step_usecase.dart';
import 'package:segadi/features/services/domain/usecases/update_mandatory_status_usecase.dart';

import 'package:segadi/features/services/presentation/detail/arguments/service_detail_arguments.dart';
import 'package:segadi/features/services/presentation/detail/state/load_status.dart';
import 'package:segadi/features/services/presentation/detail/state/service_detail_state.dart';
import 'package:segadi/features/services/presentation/list/arguments/service_action_item.dart';

class ServiceDetailNotifier extends StateNotifier<ServiceDetailState> {
  ServiceDetailNotifier({
    required this.getServiceGeneralUseCase,
    required this.getServiceActionsUseCase,
    required this.getServiceStatusUseCase,
    required this.updateMandatoryStatusUseCase,
    required this.resolveEvidenceStepUseCase,
  }) : super(const ServiceDetailState());

  final GetServiceGeneralUseCase getServiceGeneralUseCase;
  final GetServiceActionsUseCase getServiceActionsUseCase;
  final GetServiceStatusUseCase getServiceStatusUseCase;
  final UpdateMandatoryStatusUseCase updateMandatoryStatusUseCase;
  final ResolveEvidenceStepUseCase resolveEvidenceStepUseCase;

  Future<void> initialize(ServiceDetailArguments args) async {
    state = state.copyWith(
      status: LoadStatus.loading,
      arguments: args,
      clearError: true,
    );

    await _fetchAll(args.idSolicitud);
  }

  Future<void> refreshServiceState() async {
    final args = state.arguments;
    if (args == null) return;

    state = state.copyWith(status: LoadStatus.refreshing, clearError: true);
    await _fetchAll(args.idSolicitud);
  }

  Future<void> refreshAfterSupport() async {
    final args = state.arguments;
    if (args == null) return;

    state = state.copyWith(status: LoadStatus.refreshing, clearError: true);

    try {
      final actions = await getServiceActionsUseCase(args.idSolicitud);
      final status = await getServiceStatusUseCase(args.idSolicitud);

      state = state.copyWith(
        status: LoadStatus.success,
        serviceActions: actions,
        serviceStatus: status,
      );
    } catch (e) {
      state = state.copyWith(status: LoadStatus.error, error: e.toString());
    }
  }

  Future<bool> updateMandatoryStatus() async {
    final args = state.arguments;

    if (args == null) {
      state = state.copyWith(
          error: 'No se han inicializado los argumentos del servicio.');
      return false;
    }

    if (state.nextStatusId.isEmpty) {
      state =
          state.copyWith(error: 'No existe un siguiente estatus disponible.');
      return false;
    }

    state = state.copyWith(status: LoadStatus.refreshing, clearError: true);

    try {
      final result = await updateMandatoryStatusUseCase(
        UpdateMandatoryStatusParams(
          referralId: args.idRemision,
          serviceRequestId: args.idSolicitud,
          statusId: state.nextStatusId,
        ),
      );

      final updatedStatus = state.serviceStatus?.copyWith(
        nextMandatoryStatus: result.nextMandatoryStatus,
        nextMandatoryStatusId: result.nextMandatoryStatusId,
      );

      final actions = await getServiceActionsUseCase(args.idSolicitud);

      state = state.copyWith(
        status: LoadStatus.success,
        serviceStatus: updatedStatus,
        serviceActions: actions,
      );

      return true;
    } catch (e) {
      state = state.copyWith(status: LoadStatus.error, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> _fetchAll(String referralId) async {
    try {
      final results = await Future.wait([
        getServiceGeneralUseCase(referralId),
        getServiceActionsUseCase(referralId),
        getServiceStatusUseCase(referralId),
      ]);

      final service = results[0] as dynamic;
      final actions = results[1] as dynamic;
      final status = results[2] as dynamic;

      final evidenceStep = resolveEvidenceStepUseCase(
        service: service,
        status: status,
      );

      state = state.copyWith(
        status: LoadStatus.success,
        service: service,
        serviceActions: actions,
        serviceStatus: status,
        evidenceStep: evidenceStep,
      );
    } catch (e) {
      state = state.copyWith(status: LoadStatus.error, error: e.toString());
    }
  }

  // dentro de ServiceDetailNotifier
  List<ServiceActionItem> get actionItems {
    final actions = state.serviceActions;

    if (actions == null) {
      return const [];
    }

    return [
      ServiceActionItem(
        title: 'Chequeo Unidad',
        icon: Icons.checklist,
        enabled: actions.checklist.enabled,
        show: actions.checklist.show,
        key: ServiceAction.checklist,
      ),
      ServiceActionItem(
        title: 'Estatus Soporte',
        icon: Icons.headset,
        enabled: actions.support.enabled,
        show: actions.support.show,
        key: ServiceAction.support,
      ),
      ServiceActionItem(
        title: 'Geo Ruta',
        icon: Icons.route,
        enabled: actions.route.enabled,
        show: actions.route.show,
        key: ServiceAction.route,
      ),
      ServiceActionItem(
        title: 'Cerrar Viaje',
        icon: Icons.check_circle,
        enabled: actions.closeEvidence.enabled,
        show: actions.closeEvidence.show,
        key: ServiceAction.closeEvidence,
      ),
      ServiceActionItem(
        title: 'Viáticos',
        icon: Icons.money,
        enabled: actions.travelExpenses.enabled,
        show: actions.travelExpenses.show,
        key: ServiceAction.travelExpenses,
      ),
      ServiceActionItem(
        title: 'Descargar CCP',
        icon: Icons.picture_as_pdf,
        enabled: actions.downloadCcp.enabled,
        show: actions.downloadCcp.show,
        key: ServiceAction.downloadCcp,
      ),
    ];
  }
}
