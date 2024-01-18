// ignore: file_names
import 'package:flutter/material.dart';
import 'package:segadi/model/services/travel_expenses.dart';

class DataClass extends StatelessWidget {
  const DataClass({Key? key, required this.dataList}) : super(key: key);

  final List<TravelExpenses> dataList;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FittedBox(
          child: DataTable(
              sortColumnIndex: 1,
              showCheckboxColumn: false,
              border: TableBorder.all(width: 1.0),
              columns: const [
            DataColumn(label: Text('Concepto')),
            DataColumn(label: Text('Comentario')),
            DataColumn(label: Text('Importe')),
          ],
              rows: const [])),
    );
  }
}
