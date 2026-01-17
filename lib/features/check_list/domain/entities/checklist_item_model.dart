import 'package:segadi/features/check_list/domain/entities/checklist_item_entity.dart';

class ChecklistItemModel {
  final int id;
  final String option;
  final int sequence;

  ChecklistItemModel({
    required this.id,
    required this.option,
    required this.sequence,
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      id: json['id'],
      option: json['option'],
      sequence: json['sequence'],
    );
  }

  ChecklistItemEntity toEntity() {
    return ChecklistItemEntity(
      id: id,
      option: option,
      sequence: sequence,
    );
  }
}
