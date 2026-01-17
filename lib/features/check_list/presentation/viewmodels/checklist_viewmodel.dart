import 'package:flutter/cupertino.dart';
import 'package:segadi/features/check_list/data/repositories/checklist_repository_impl.dart';
import 'package:segadi/features/check_list/domain/entities/checklist_item_entity.dart';

class ChecklistViewModel extends ChangeNotifier {
  final ChecklistRepositoryImpl repo;
  final int serviceId;

  ChecklistViewModel({
    required this.repo,
    required this.serviceId,
  });

  List<ChecklistItemEntity> items = [];
  bool loading = false;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    items = await repo.getChecklist();

    loading = false;
    notifyListeners();
  }

  void toggle(int id) {
    final item = items.firstWhere((e) => e.id == id);
    item.checked = !item.checked;
    notifyListeners();
  }

  bool get isValid => items.any((e) => e.checked);

  Future<bool> save() async {
    final checkedIds = items.where((e) => e.checked).map((e) => e.id).toList();

    if (checkedIds.isEmpty) return false;

    return repo.saveChecklist(serviceId, checkedIds);
  }
}
