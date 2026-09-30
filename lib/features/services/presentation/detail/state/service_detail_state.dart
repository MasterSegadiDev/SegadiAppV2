import 'package:segadi/features/services/domain/entities/service_actions_entity.dart';
import 'package:segadi/features/services/domain/entities/service_general_entity.dart';
import 'package:segadi/features/services/domain/entities/service_status_entity.dart';
import 'package:segadi/features/services/domain/entities/support_status_current_entity.dart';
import 'package:segadi/features/services/domain/enums/evidence_step.dart';
import 'package:segadi/features/services/presentation/detail/arguments/service_detail_arguments.dart';
import 'package:segadi/features/services/presentation/detail/state/load_status.dart';

class ServiceDetailState {
  final LoadStatus status;
  final String? error;

  final ServiceDetailArguments? arguments;
  final ServiceGeneralEntity? service;
  final ServiceActionsEntity? serviceActions;
  final ServiceStatusEntity? serviceStatus;
  final EvidenceStep evidenceStep;

  const ServiceDetailState({
    this.status = LoadStatus.initial,
    this.error,
    this.arguments,
    this.service,
    this.serviceActions,
    this.serviceStatus,
    this.evidenceStep = EvidenceStep.notApplicable,
  });

  bool get isLoading => status == LoadStatus.loading;
  bool get isRefreshing => status == LoadStatus.refreshing;
  bool get hasError => error != null;

  String get serviceNumber => arguments?.serviceNumber ?? '';
  String get idRemision => arguments?.idRemision ?? '';
  String get idSolicitud => arguments?.idSolicitud ?? '';

  bool get enableStatusButton => serviceStatus?.enableBtn ?? false;

  String get nextStatusId => serviceStatus?.nextMandatoryStatusId ?? '';
  SupportStatusCurrentEntity? get currentSupportStatus =>
      serviceStatus?.supportStatus;

  String get nextStatusName => serviceStatus?.nextMandatoryStatus ?? '';

  String get statusName {
    if (evidenceStep == EvidenceStep.confirmationPending ||
        evidenceStep == EvidenceStep.evidencePending) {
      return 'Evidencias faltantes';
    }
    return serviceStatus?.nextMandatoryStatus ?? '';
  }

  bool get canUpdateStatus {
    final blocksUpdate = evidenceStep == EvidenceStep.confirmationPending ||
        evidenceStep == EvidenceStep.evidencePending;

    return enableStatusButton && !blocksUpdate;
  }

  ServiceDetailState copyWith({
    LoadStatus? status,
    String? error,
    bool clearError = false,
    ServiceDetailArguments? arguments,
    ServiceGeneralEntity? service,
    ServiceActionsEntity? serviceActions,
    ServiceStatusEntity? serviceStatus,
    EvidenceStep? evidenceStep,
  }) {
    return ServiceDetailState(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      arguments: arguments ?? this.arguments,
      service: service ?? this.service,
      serviceActions: serviceActions ?? this.serviceActions,
      serviceStatus: serviceStatus ?? this.serviceStatus,
      evidenceStep: evidenceStep ?? this.evidenceStep,
    );
  }
}
