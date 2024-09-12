import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/view/services/modals/list_travel_expenses.dart';
import 'package:segadi/view_model/services_operator/travel_expenses.dart';

class TravelExpensesScreen extends StatefulWidget {
  const TravelExpensesScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _TravelExpensesScreen createState() => _TravelExpensesScreen();
}

class _TravelExpensesScreen extends State<TravelExpensesScreen> {
  List data = [];
  String concept = "";
  String comentery = "";
  dynamic importe = 0;

  String? valuePaymentConcept;
  int? selected;
  int? conceptId;
  //double totalImport = 0;

  bool loading = true;
  List listDataOption = [];

  bool cancelButton = true;

  // Future getDataOption(int id) async {
  //   listDataOption = await TravelExpensesService().getData(id);
  //   if (listDataOption.isEmpty) {
  //     setState(() {
  //       cancelButton = false;
  //     });
  //   }
  // }

  // List<TravelExpenses> listTravelExpenses = [];
  // Future getTravelExpenses(int id) async {
  //   listTravelExpenses = await TravelExpensesService().getTravelExpenses(id);
  //   setState(() {
  //     loading = false;
  //     _loadData();
  //   });
  // }

  _loadData() async {
    setState(() {
      // getDataOption(id);
    });
  }

  @override
  void initState() {
    super.initState();
    // getDataOption(id);
    // getTravelExpenses(id);
  }

  @override
  Widget build(BuildContext context) {
    final travelExpensesViewModel =
        Provider.of<TravelExpensesViewModel>(context);
    double totalImport = 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Viáticos',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: cancelButton
                      ? () {
                          // _dialogBuilder(context);
                          _showBottomSheet(context);
                        }
                      : null,
                  child: const Text(
                    'Agregar conceptos',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(
                    label: Text(
                      'Concepto',
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Importe',
                    ),
                  ),
                ],
                rows: travelExpensesViewModel.loadListTableTravelExpenses
                    .map((e) {
                  double result = double.parse(e.totalUsed.toString());
                  totalImport += result;

                  return DataRow(cells: [
                    DataCell(Text(e.paymentConcept.toString())),
                    DataCell(Text(e.totalUsed.toString())),
                  ]);
                }).toList(),
              ),
            ),
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Text('Importe Total:$totalImport')],
                )
              ],
            )
          ],
        ),
      ),
    );
  }


  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: false,
      context: context,
      builder: (ctx) => ListTravelExpensesView(),
    );
  }
}
