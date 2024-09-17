import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/view/services/modals/list_travel_expenses.dart';
import 'package:segadi/view_model/services_operator/travel_expenses.dart';

class TravelExpensesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final travelExpensesViewModel =
        Provider.of<TravelExpensesViewModel>(context);
    double totalImport = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Viáticos',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF2C522A),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    fixedSize: Size(200, double.infinity)),
                onPressed: () async {
                  await travelExpensesViewModel.fetchItemsTravelExpenses();
                  if (travelExpensesViewModel.bandera) {
                    _showBottomSheet(context);
                  }
                },
                child: Text('Agregar conceptos'),
              ),
              SizedBox(
                height: 20,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Viático Asignado',
                        style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Importe Registrado',
                        style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: travelExpensesViewModel.tableItems.map((e) {
                    double result = double.parse(e.totalUsed.toString());

                    totalImport += result;

                    return DataRow(cells: [
                      DataCell(Text(e.paymentConcept.toString())),
                      DataCell(Text(e.totalUsed.toString())),
                    ]);
                  }).toList(),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 1),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green.withOpacity(0.1),
                  ),
                  headingRowColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                    return Colors.green.withOpacity(0.3);
                  }),
                  dataRowColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                    return states.contains(WidgetState.selected)
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.transparent;
                  }),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Importe Total  : ${totalImport}',
                style: TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.normal,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (ctx) => ListTravelExpensesView(),
  );
}
