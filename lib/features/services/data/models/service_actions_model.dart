import '../../domain/entities/service_action_entity.dart';
import '../../domain/entities/service_actions_entity.dart';

class ServiceActionsModel extends ServiceActionsEntity {
  const ServiceActionsModel({
    required super.checklist,
    required super.support,
    required super.route,
    required super.closeEvidence,
    required super.travelExpenses,
    required super.downloadCcp,
  });

  factory ServiceActionsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ServiceActionsModel(
      checklist: _fromJson(json['check_list']),
      support: _fromJson(json['support']),
      route: _fromJson(json['route']),
      closeEvidence: _fromJson(json['close_evidence']),
      travelExpenses: _fromJson(json['travel_expenses']),
      downloadCcp: _fromJson(json['download_ccp']),
    );
  }

  static ServiceActionEntity _fromJson(
    dynamic value,
  ) {
    if (value is! Map<String, dynamic>) {
      return const ServiceActionEntity(
        enabled: false,
        show: false,
      );
    }

    return ServiceActionEntity(
      enabled: value['enabled'] == true,
      show: value['show'] == true,
    );
  }

  factory ServiceActionsModel.empty() {
    return const ServiceActionsModel(
      checklist: ServiceActionEntity(
        enabled: false,
        show: false,
      ),
      support: ServiceActionEntity(
        enabled: false,
        show: false,
      ),
      route: ServiceActionEntity(
        enabled: false,
        show: false,
      ),
      closeEvidence: ServiceActionEntity(
        enabled: false,
        show: false,
      ),
      travelExpenses: ServiceActionEntity(
        enabled: false,
        show: false,
      ),
      downloadCcp: ServiceActionEntity(
        enabled: false,
        show: false,
      ),
    );
  }
}
