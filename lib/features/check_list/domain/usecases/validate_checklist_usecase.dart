import 'package:segadi/features/check_list/domain/entities/checklist_item_entity.dart';

bool isChecklistValid(List<ChecklistItemEntity> items) {
  return items.any((e) => e.checked);
}
