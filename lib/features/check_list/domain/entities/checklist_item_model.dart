import 'package:segadi/features/check_list/domain/entities/checklist_item_entity.dart';

class ChecklistItemModel extends ChecklistItemEntity {
  ChecklistItemModel({
    required super.id,
    required super.option,
    required super.sequence,
    super.checked = false, // Pasamos el valor por defecto
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      id: json['id'] ?? 0,
      option: json['option'] ?? '',
      sequence: json['sequence'] ?? 0,
      // Si el JSON trae el estado, lo mapeamos, si no, usa el default
      checked: json['checked'] ?? false,
    );
  }
}
