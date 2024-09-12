import 'package:flutter/material.dart';
import 'package:segadi/model/services/checklist.dart';
import 'package:segadi/view_model/globals.dart';

class CheckListViewModel extends ChangeNotifier {
  final NewCheckList _itemCheckList = NewCheckList();

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
    print(_items[index].isChecked);

    if (_items[index].isChecked == true) {
      optionSelect.add(id);
    } else if (_items[index].isChecked == false) {
      optionSelect.remove(id);
    }

    notifyListeners();
  }

  Future<void> save() async {
    print(optionSelect);
    var response =
        await _itemCheckList.saveCheckList(serviceDetailId, optionSelect);
    print(response.statusCode);
  }
}
