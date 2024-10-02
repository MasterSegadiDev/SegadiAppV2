import 'package:flutter/material.dart';
import 'package:segadi/models/services/checklist.dart';
import 'package:segadi/utils/global_variables.dart';

class CheckListViewModel extends ChangeNotifier {

  final NewCheckList _itemCheckList = NewCheckList();
  final int serviceDetailId = GlobalVariables.serviceDetailId;

  List<CheckList> _items = [];
  List<CheckList> get items => _items;

  List _optionSelect = [];
  List get optionSelect => _optionSelect;

  Future<void> fetchItems() async {
    _optionSelect.clear();
    _items = await _itemCheckList.fetchItems();
    notifyListeners();
  }

  void toggleItem(int index, int id) {
    _items[index].isChecked = !_items[index].isChecked;

    if (_items[index].isChecked == true) {
      optionSelect.add(id);
    } else if (_items[index].isChecked == false) {
      optionSelect.remove(id);
    }

    notifyListeners();
  }

  Future<void> save() async {
    _itemCheckList.saveCheckList(serviceDetailId, optionSelect);
  }
}
