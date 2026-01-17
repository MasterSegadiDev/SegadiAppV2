import 'package:segadi/features/check_list/data/datasources/checklist_api.dart';
import 'package:segadi/features/check_list/domain/entities/checklist_item_entity.dart';
import 'package:segadi/features/check_list/domain/entities/checklist_item_model.dart';

class ChecklistRepositoryImpl {
  final ChecklistApi api;

  ChecklistRepositoryImpl(this.api);

  Future<List<ChecklistItemEntity>> getChecklist() async {
    final List data = await api.getChecklistCatalog();

    return data.map((e) => ChecklistItemModel.fromJson(e).toEntity()).toList();
  }

  Future<bool> saveChecklist(
    int serviceId,
    List<int> checkedIds,
  ) {
    return api.saveChecklist(
      serviceId: serviceId,
      checkedIds: checkedIds,
    );
  }
}
