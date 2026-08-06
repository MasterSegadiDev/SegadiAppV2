import '../../domain/entities/service_actions_entity.dart';
import 'service_action_model.dart';

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
      checklist: ServiceActionModel.fromJson(
        json['check_list'] ?? {},
      ),
      support: ServiceActionModel.fromJson(
        json['support'] ?? {},
      ),
      route: ServiceActionModel.fromJson(
        json['route'] ?? {},
      ),
      closeEvidence: ServiceActionModel.fromJson(
        json['close_evidence'] ?? {},
      ),
      travelExpenses: ServiceActionModel.fromJson(
        json['travel_expenses'] ?? {},
      ),
      downloadCcp: ServiceActionModel.fromJson(
        json['download_ccp'] ?? {},
      ),
    );
  }

  ServiceActionsModel.empty()
      : super(
          checklist: ServiceActionModel.empty(),
          support: ServiceActionModel.empty(),
          route: ServiceActionModel.empty(),
          closeEvidence: ServiceActionModel.empty(),
          travelExpenses: ServiceActionModel.empty(),
          downloadCcp: ServiceActionModel.empty(),
        );
}
