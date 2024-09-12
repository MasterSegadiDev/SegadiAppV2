import 'package:flutter/material.dart';
import 'package:segadi/model/services/services.dart';

class ServicesViewModel extends ChangeNotifier {
  final Services _itemService = Services();

  List<Services> _items = [];
  final bool _isLoading = false;

  List<Services> get items => _items;
  bool get isLoading => _isLoading;

  // ServicesViewModel() {
  //   onRefresh();
  // }

  Future fetchItems() async {
    try {
      _items = await _itemService.fetchItems();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future onRefresh() async {
    _items.clear();
    await _itemService.fetchItems();
    notifyListeners();
  }
}
