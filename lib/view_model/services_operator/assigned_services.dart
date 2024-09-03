import 'package:flutter/material.dart';
import 'package:segadi/model/services/services.dart';

class ServicesViewModel extends ChangeNotifier {
  final ItemService _itemService = ItemService();

  List<Services> _items = [];
  final bool _isLoading = false;

  List<Services> get items => _items;
  bool get isLoading => _isLoading;

  ServicesViewModel() {
    onRefresh();
  }

  Future<void> fetchItems() async {
    //_isLoading = true;
    //_items.clear();
    //notifyListeners();

    _items = await _itemService.fetchItems();
    

    //_isLoading = false;
    notifyListeners();
  }

  Future onRefresh() async {
    _items.clear();
    await _itemService.fetchItems();
    notifyListeners();
  }

  
}
