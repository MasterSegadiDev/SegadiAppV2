import 'package:segadi/features/services/data/models/serice_action_dto_model.dart';

class ServiceActionsDto {
  final bool enableBtn;

  final ActionDto checklist;
  final ActionDto support;
  final ActionDto evidence;
  final ActionDto closeTravel;
  final ActionDto expenses;

  const ServiceActionsDto({
    required this.enableBtn,
    required this.checklist,
    required this.support,
    required this.evidence,
    required this.closeTravel,
    required this.expenses,
  });

  factory ServiceActionsDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ServiceActionsDto(
      enableBtn: json['enableBtn'] ?? false,
      checklist: ActionDto.fromJson(
        json['check_list'] ?? {},
      ),
      support: ActionDto.fromJson(
        json['support'] ?? {},
      ),
      evidence: ActionDto.fromJson(
        json['close_evidence'] ?? {},
      ),
      closeTravel: ActionDto.fromJson(
        json['close_travel'] ?? {},
      ),
      expenses: ActionDto.fromJson(
        json['travel_expenses'] ?? {},
      ),
    );
  }
}
