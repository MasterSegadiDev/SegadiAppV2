import 'package:flutter/material.dart';
import 'package:segadi/model/services/checklist.dart';
import 'package:segadi/model/services/detail_service.dart';
import 'package:segadi/view_model/globals.dart';

class DetailViewModel extends ChangeNotifier {
  final DetailServices _detailService = DetailServices();
  final NewCheckList _itemCheckList = NewCheckList();

  late DetailService detail;

  DetailService? _item;
  DetailService? get item => _item;

  void setNewDetail(DetailService detailServiceModel) async {
    detail = detailServiceModel;
    serviceDetailId = 0;
    serviceDetailId = detail.id!;

    _item = await _detailService.getDetail(detail.id);
    print(_item);
    notifyListeners();
  }

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
    await _itemCheckList.saveCheckList(serviceDetailId, optionSelect);
    _item = await _detailService.getDetail(detail.id);
    print(_item);
    notifyListeners();
  }

  Future<void> changeStatusService(int statusId) async {
    serviceDetailId = 0;
    serviceDetailId = detail.id!;
    var res =
        await _detailService.changeStatusService(serviceDetailId, statusId);
    print(res.statusCode);
    if (res.statusCode == 200) {
      _item = await _detailService.getDetail(detail.id);
      print(_item);
      notifyListeners();
    }
  }

  Future<void> changeStatusSupport(int statusId, String status) async {
    print('estatus: ${statusId} estatus tipo: ${status}');
    serviceDetailId = 0;
    serviceDetailId = detail.id!;
    print(statusId);

    var res = await _detailService.changeStatusSupport(
        serviceDetailId, statusId, status);

    if (res.statusCode == 200) {
      _item = await _detailService.getDetail(detail.id);
      print(_item);
      notifyListeners();
    }
  }

}
