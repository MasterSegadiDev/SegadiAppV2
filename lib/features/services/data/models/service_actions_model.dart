import 'package:segadi/features/services/domain/entities/detail_service_actions_entity.dart';

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
      checklist: json['check_list'] ?? false,
      support: json['support'] ?? false,
      route: json['route'] ?? false,
      closeEvidence: json['close_evidence'] ?? false,
      travelExpenses: json['travel_expenses'] ?? false,
      downloadCcp: json['download_ccp'] ?? false,
    );
  }

  const ServiceActionsModel.empty()
      : super(
          checklist: true,
          support: true,
          route: true,
          closeEvidence: true,
          travelExpenses: true,
          downloadCcp: true,
        );
}
