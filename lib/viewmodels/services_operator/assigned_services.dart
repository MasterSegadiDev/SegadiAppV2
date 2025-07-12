import 'package:flutter/material.dart';
import 'package:segadi/models/services/services.dart';
import 'package:segadi/services/operatorServices/ServicesListApi.dart';

class ServicesViewModel extends ChangeNotifier {
  List<Services> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Services> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await ServicesApi.fetchAssignedServices();
    } catch (e) {
      _errorMessage = 'No se han podido obtener los servicios asignados.';
      print('[ServicesViewModel] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onRefresh() async {
    await fetchItems();
  }
}
