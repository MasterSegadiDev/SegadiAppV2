import 'package:flutter/material.dart';
import 'package:segadi/model/services/table_expeneses.dart';
import 'package:segadi/model/services/travel_expenses.dart';
import 'package:segadi/view_model/globals.dart';

class TravelExpensesViewModel extends ChangeNotifier {
  TravelExpenses _travelExpenses = TravelExpenses();
  TableExpenses _tableExpenses = TableExpenses();

  double _import = 0.0;
  double get import => _import;

  List<TravelExpenses> _listItemsTravelExpenses = [];
  List<TravelExpenses> get listItemsTravelExpenses => _listItemsTravelExpenses;

  List<TableExpenses> _loadListTableTravelExpenses = [];
  List<TableExpenses> get loadListTableTravelExpenses =>
      _loadListTableTravelExpenses;

  final bool _isLoading = false;

  bool get isLoading => _isLoading;

  late TravelExpenses _itemTwo;
  TravelExpenses get itemTwo => _itemTwo;

  void setNewDetail(int id) async {
    serviceDetailId = id;

    _listItemsTravelExpenses = await _travelExpenses.getData(serviceDetailId);
    _loadListTableTravelExpenses =
        await _tableExpenses.getTravelExpenses(serviceDetailId);

    print(_loadListTableTravelExpenses);
  }

// int serviceId, int moneyCheckId, dynamic importTotal, comentary
  Future<void> insertImport(double import) async {
    if (import > 0) {
      //await _travelExpenses.getData(id);
    }
  }
}
