import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  //double totalImport = 0;

  bool loading = true;
  List listDataOption = [];

  bool cancelButton = true;

  Future getDataOption(int id) async {
    listDataOption = await TravelExpensesService().getData(id);
    if (listDataOption.isEmpty) {
      setState(() {
        cancelButton = false;
      });
    }
  }

  List<TravelExpenses> listTravelExpenses = [];
  Future getTravelExpenses(int id) async {
    listTravelExpenses = await TravelExpensesService().getTravelExpenses(id);
    setState(() {
      loading = false;
      _loadData();
    });
  }

  _loadData() async {
    setState(() {
      getDataOption(id);
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
                    'Agregar concepto',
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

  validate() async {
    double importSelected = 0;
    double importAdd = 0;
    var estateSelected =
        listDataOption.firstWhere((dropdown) => dropdown['id'] == conceptId);

    importAdd = double.parse(importe);
    importSelected = double.parse(estateSelected['payment_total']);

    if (importAdd <= importSelected) {
      http.Response response = await TravelExpensesService()
          .insertImport(id, conceptId!, importe, comentery);
      // Map responseMap = jsonDecode(response.body);

      if (response.statusCode == 200) {
        getTravelExpenses(id);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    } else if (importAdd > importSelected) {
      message(context, importAdd, importSelected);
    }
  }

  Future<void> message(BuildContext context, importAdd, importSelected) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: null,
          insetPadding: const EdgeInsets.all(20),
          content: Text(
              'El importe agregado de: $importAdd es mayor al importe seleccionado de: $importSelected'),
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  //  width: 700,
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        hint: const Text('Selecciona un concepto'),
                        items: listDataOption.map((e) {
                          return DropdownMenuItem(
                            value: e["id"],
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                e["payment_concept"] +
                                    '  \$' +
                                    e["payment_total"].toString(),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 380,
                  child: Column(
                    children: [
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
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 380,
                  child: Column(
                    children: [
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: 40,
                  width: 380,
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () => validate(),
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          20), // <-- Radius
                                    ),
                                    backgroundColor: const Color(0xFF2C522A)),
                                child: const Text(
                                  'Agregar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
