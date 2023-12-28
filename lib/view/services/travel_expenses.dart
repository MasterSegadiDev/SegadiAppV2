import 'package:flutter/material.dart';
import 'package:segadi/model/services/travel_expenses.dart';

import 'package:segadi/view_model/services_operator/travel_expenses.dart';

class TravelExpensesScreen extends StatefulWidget {
  final int id;
  const TravelExpensesScreen({Key? key, required this.id}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _TravelExpensesScreen createState() => _TravelExpensesScreen(id);
}

class _TravelExpensesScreen extends State<TravelExpensesScreen> {
  _TravelExpensesScreen(this.id);
  final int id;

  List data = [];
  String concept = "";
  String comentery = "";
  dynamic importe = 0;

  String? valuePaymentConcept;
  int? selected;
  int? conceptId;
  late double totalImport = 0;

  List listDataOption = [];

  Future getDataOption(int id) async {
    listDataOption = await TravelExpensesService().getData(id);
  }

  List<TravelExpenses> listTravelExpenses = [];
  bool loading = true;
  Future getTravelExpenses(int id) async {
    listTravelExpenses = await TravelExpensesService().getTravelExpenses(id);
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getDataOption(id);
    getTravelExpenses(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viaticos'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () => _dialogBuilder(context),
                  child: const Text('Agregar concepto'),
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
                    label: Text('Concepto'),
                  ),
                  DataColumn(
                    label: Text('Importe'),
                  ),
                ],
                rows: listTravelExpenses.map((e) {
                  double result = double.parse(e.totalUsed);
                  totalImport += result;

                  return DataRow(cells: [
                    DataCell(Text(e.paymentConcept.toString())),
                    //DataCell(Text(e.comments.toString())),
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

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Basic dialog title'),
          insetPadding: const EdgeInsets.all(20),
          content: Column(
            children: [
              DropdownButtonFormField(
                hint: const Text('Selecciona un concepto'),
                items: listDataOption.map((e) {
                  return DropdownMenuItem(
                    value: e["id"],
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        e["payment_concept"],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  conceptId = value as int?;
                },
                isDense: true,
                isExpanded: true,
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                minLines: 4,
                keyboardType: TextInputType.multiline,
                maxLines: 250,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  filled: true,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  labelText: 'Agrega un comentario',
                ),
                onChanged: (value) {
                  comentery = value;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: const InputDecoration(
                  labelText: 'Importe',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  importe = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Agregar'),
              onPressed: () => validate(),
            ),
          ],
        );
      },
    );
  }

  validate() async {
    double importSelected = 0;
    double importAdd = 0;
    var estateSelected =
        listDataOption.firstWhere((dropdown) => dropdown['id'] == conceptId);

    importAdd = double.parse(importe);
    importSelected = double.parse(estateSelected['payment_total']);
    print(importAdd);

    if (importAdd <= importSelected) {
      print('el importe es menor o igual');

      //http.Response response =
      // await Detail.insertImport(id, conceptId!, importe, comentery);
      // Map responseMap = jsonDecode(response.body);
      getTravelExpenses(id);
      Navigator.pop(context);
    } else if (importAdd > importSelected) {
      print('el importe agregado es mayor que el seleecionado');
    } else {
      print('es un valor desconocido');
    }
  }

  Future<void> message(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
            title: Text('Basic dialog title'),
            insetPadding: EdgeInsets.all(20),
            content:
                Text('El importe registrado es mayor al importe asignado'));
      },
    );
  }
}
