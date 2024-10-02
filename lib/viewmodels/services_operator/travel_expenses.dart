import 'package:flutter/material.dart';
import 'package:segadi/models/services/table_expeneses.dart';
import 'package:segadi/models/services/travel_expenses.dart';
import 'package:segadi/utils/global_variables.dart';

class TravelExpensesViewModel extends ChangeNotifier {
  TravelExpenses _travelExpenses = TravelExpenses();
  TableExpenses _tableExpenses = TableExpenses();

  final TextEditingController textController = TextEditingController();
  final TextEditingController textController1 = TextEditingController();
  int serviceDetailId = GlobalVariables.serviceDetailId;

  TableExpenses? _table;
  TableExpenses? get table => _table;

  String _import = '';
  String get import => _import;

  set import(String value) {
    _import = value;
    notifyListeners();
  }

  String _comentary = '';
  String get comentary => _comentary;

  set comentary(String value) {
    _comentary = value;
    notifyListeners();
  }

  int _conceptId = 0;
  int get conceptId => _conceptId;

  set concetId(int value) {
    _conceptId = value;
    notifyListeners();
  }

  String? _errorMessage = null;
  String? get errorMessage => _errorMessage;

  List<TravelExpenses> _items = [];
  List<TravelExpenses> get items => _items;

  TravelExpenses? _selectedItem;
  TravelExpenses? get selectedItem => _selectedItem;

  List<TableExpenses> _tableItems = [];
  List<TableExpenses> get tableItems => _tableItems;

  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _bandera = false;
  bool get bandera => _bandera;

  List<TravelExpenses> _data = [];
  List<TravelExpenses> get data => _data;

  TravelExpensesViewModel() {
    fetchItemsTravelExpenses();
  }

  void setNewDetail(int id) async {
    serviceDetailId = id;
    _tableItems = await _tableExpenses.getTravelExpenses(serviceDetailId);
    notifyListeners();
  }

  Future<void> fetchItemsTravelExpenses() async {
    _items = [];
    _data = [];
    
    _bandera = false;

    _items = await _travelExpenses.getData(serviceDetailId);
    if (_items.isNotEmpty) {
      _bandera = true;
      _data = _items;
      _conceptId = 0;
      _comentary = '';
      _import = '';
      textController.clear();
      textController1.clear();
      
    }
    notifyListeners();
  }

  void setSelectedItem(TravelExpenses? id) {
    _selectedItem = id;
    notifyListeners();
  }

  Future<void> tableFetchItems() async {
    _tableItems = await _tableExpenses.getTravelExpenses(serviceDetailId);
    notifyListeners();
  }

  Future<void> insertImport() async {
    _errorMessage = null;

    if (conceptId <= 0) {
      _errorMessage = 'Necesitas seleccionar un concepto';
     
    } else if (import.isEmpty) {
      _errorMessage = 'Necesitas ingresar un importe a registrar';
    
    } else if (conceptId > 0 && import.isNotEmpty) {
      var contain = _data.where((element) => element.id == conceptId);

      if (contain.isNotEmpty) {
        var new_import = double.parse(import);
        var payment_total = double.parse(contain.first.paymentTotal.toString());

        if (new_import <= payment_total) {
          var rest = await _travelExpenses.insertImport(
              serviceDetailId, conceptId, new_import, comentary);
          if (rest.statusCode == 200) {
            _tableItems =
                await _tableExpenses.getTravelExpenses(serviceDetailId);
            textController.clear();
            textController1.clear();
          } else {
            _errorMessage = 'Ha ocurrido un error al registrar tu viático';
          }
        } else {
          _errorMessage =
              'El importe : ${import} es mayor al importe seleccionado de: ${contain.first.paymentTotal}';
        }
      }
    }
    notifyListeners();
  }
}
