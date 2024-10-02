import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:segadi/models/services/checklist.dart';
import 'package:segadi/models/services/detail_service.dart';
import 'package:segadi/utils/global_variables.dart';

class DetailViewModel extends ChangeNotifier {
  final DetailServices _detailService = DetailServices();
  final NewCheckList _itemCheckList = NewCheckList();


  int serviceDetailId = GlobalVariables.serviceDetailId;

  late DetailService detail;

  DetailService? _item;
  DetailService? get item => _item;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  late String _errorMessageUrl;
  String get errorMessageUrl => _errorMessageUrl;

  String _url = '';
  String get url => _url;

  bool _bandera = true;
  bool get bandera => _bandera;

  void setNewDetail(DetailService detailServiceModel) async {
    print('numero servicio detalle: ${detailServiceModel.id}');

    serviceDetailId = detailServiceModel.id!;

    _item = await _detailService.getDetail(detailServiceModel.id);

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

    if (_items[index].isChecked == true) {
      optionSelect.add(id);
    } else if (_items[index].isChecked == false) {
      optionSelect.remove(id);
    }

    notifyListeners();
  }

  Future<void> save() async {
    var response;
    _errorMessage = null;

    if (optionSelect.isEmpty) {
      _errorMessage =
          'Necesitas seleccionar al menos una opción del check list';
    } else {
      response =
          await _itemCheckList.saveCheckList(serviceDetailId, optionSelect);

      if (response.statusCode == 200) {
        _item = await _detailService.getDetail(serviceDetailId);
      } else {
        _errorMessage =
            'Ha ocurrido un error al guardar el checkList, código de error: ${response.statusCode}';
      }
    }

    notifyListeners();
  }

  Future<void> changeStatusService(int statusId) async {
    

    _errorMessage = null;
    http.Response response =
        await _detailService.changeStatusService(serviceDetailId, statusId);

    if (response.statusCode == 200) {
      _item = await _detailService.getDetail(serviceDetailId);
    } else {
      _errorMessage =
          'Ha ocurrido un error al cambiar el estatus de la remision, código de error: ${response.statusCode}';
    }
    notifyListeners();
  }

  Future<void> changeStatusSupport(int statusId, String status) async {
    print('numero servicio detalle: ${serviceDetailId}');
    _errorMessage = null;
    http.Response response = await _detailService.changeStatusSupport(
        serviceDetailId, statusId, status);

    if (response.statusCode == 200) {
      _item = await _detailService.getDetail(serviceDetailId);
    } else {
      _errorMessage =
          'Ha ocurrido un error al cambiar el estatus de soporte, código de error: ${response.statusCode}';
    }
    notifyListeners();
  }
}
