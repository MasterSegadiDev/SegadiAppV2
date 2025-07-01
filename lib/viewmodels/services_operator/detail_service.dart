import 'package:flutter/material.dart';
import 'package:segadi/utils/user_session.dart';

import 'package:segadi/models/services/checklist.dart';
import 'package:segadi/models/services/detail_service.dart';
import 'package:segadi/utils/global_variables.dart';

class DetailViewModel extends ChangeNotifier {
  // ===========================================================================
  // DEPENDENCIAS Y SERVICIOS
  // ===========================================================================
  final DetailServices _detailService = DetailServices();
  final NewCheckList _itemCheckList = NewCheckList();

  // ===========================================================================
  // PROPIEDADES DE ESTADO
  // ===========================================================================
  int _serviceDetailId = GlobalVariables.serviceDetailId;
  DetailService? _item;
  final List<CheckList> _items = [];
  final List<int> _optionSelect = [];

  // ===========================================================================
  // VARIABLES DE CONTROL Y MENSAJES
  // ===========================================================================
  bool _bandera = true;
  String _operatorRole = '';
  String? _errorMessage;
  String _url = '';
  String _errorMessageUrl = '';

  // ===========================================================================
  // GETTERS PÚBLICOS
  // ===========================================================================
  DetailService? get item => _item;
  List<CheckList> get items => _items;
  List<int> get optionSelect => _optionSelect;
  bool get bandera => _bandera;
  String get operatorRole => _operatorRole;
  String? get errorMessage => _errorMessage;
  String get url => _url;
  String get errorMessageUrl => _errorMessageUrl;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  // ===========================================================================
  // ACCIONES PÚBLICAS
  // ===========================================================================

  Future<void> setNewDetail(DetailService detailServiceModel) async {
    debugPrint('ID de detalle de servicio: ${detailServiceModel.id}');
    _serviceDetailId = detailServiceModel.id!;
    await _updateDetail();
  }

  Future<void> fetchItems() async {
    _optionSelect.clear();
    final fetchedItems = await _itemCheckList.fetchItems();
    _items
      ..clear()
      ..addAll(fetchedItems);
    notifyListeners();
  }

  void toggleItem(int index, int id) {
    final item = _items[index];
    item.isChecked = !item.isChecked;

    item.isChecked ? _optionSelect.add(id) : _optionSelect.remove(id);
    notifyListeners();
  }

  Future<void> save() async {
    _errorMessage = null;

    if (_isSaving) return; // Evita doble ejecución

    _isSaving = true;
    notifyListeners();

    if (_optionSelect.isEmpty) {
      _errorMessage =
          'Necesitas seleccionar al menos una opción del checklist.';
      _isSaving = false;
      notifyListeners();
      return;
    }

    final response =
        await _itemCheckList.saveCheckList(_serviceDetailId, _optionSelect);

    if (response.statusCode == 200) {
      await _updateDetail();
      await fetchItems(); // 🔄 Refrescar lista
    } else {
      _errorMessage =
          'Error al guardar el checklist. Código: ${response.statusCode}';
    }

    _isSaving = false;
    notifyListeners();
  }

  Future<void> changeStatusService(int statusId) async {
    final user = UserSession();
    print('USUARIO TIPO ROL ${user.userRoll}');
    _errorMessage = null;

    final response =
        await _detailService.changeStatusService(_serviceDetailId, statusId);

    print('ESTATUS ID CON EL QUE NECESITO INICIAR ${statusId}');

    if (statusId == 2 && user.userRoll == 'No') {
      print('SE VA ACTIVAR EL USUARIO EN AIRBAG');
      await _detailService.changeStatusOperatorAirbag('active');
    } else if (statusId == 23) {
      await _detailService.changeStatusOperatorAirbag('inactive');
    }

    if (response.statusCode == 200) {
      await _updateDetail();
    } else {
      _errorMessage =
          'Error al cambiar el estatus del servicio. Código: ${response.statusCode}';
      notifyListeners();
    }
  }

  /// ✅ Método renombrado para coincidir con la vista
  Future<void> changeStatusSupport(int statusId, String status) async {
    _errorMessage = null;

    final response = await _detailService.changeStatusSupport(
      _serviceDetailId,
      statusId,
      status,
    );

    if (response.statusCode == 200) {
      await _updateDetail();
    } else {
      _errorMessage =
          'Error al cambiar el estatus de soporte. Código: ${response.statusCode}';
      notifyListeners();
    }
  }

  // ===========================================================================
  // MÉTODOS PRIVADOS
  // ===========================================================================
  Future<void> _updateDetail() async {
    _item = await _detailService.getDetail(_serviceDetailId);
    notifyListeners();
  }
}
