import 'package:segadi/features/services/domain/entities/service_action_entity.dart';

class ServiceActionsEntity {
  final ServiceActionEntity checklist;
  final ServiceActionEntity support;
  final ServiceActionEntity route;
  final ServiceActionEntity closeEvidence;
  final ServiceActionEntity travelExpenses;
  final ServiceActionEntity downloadCcp;

  const ServiceActionsEntity({
    required this.checklist,
    required this.support,
    required this.route,
    required this.closeEvidence,
    required this.travelExpenses,
    required this.downloadCcp,
  });
}
