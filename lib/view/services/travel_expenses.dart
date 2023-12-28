import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:segadi/model/services/travel_expenses.dart';
import 'package:segadi/view/services/DataClass.dart';
import 'package:segadi/view_model/globals.dart';

import 'package:segadi/view_model/services_operator/detail_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

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

  getData() async {
    var arrayDataOption = [];
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    var token = prefs.getString('token') ?? '';

    final result = await http.get(
        Uri.parse("http://198.251.68.42/DesarrolloSEGADI/web/index.php")
            .replace(queryParameters: {
      'r': 'esegadi/getcomprobaciones',
      'id': userId.toString(),
      'id_remision': id.toString(),
      'token': token,
    }));
    var jsonData = json.decode(result.body.toString());

    jsonData.forEach((subject) {
      if (subject["total_used"] == "0.00") {
        print("${subject["id"]}: ${subject["payment_concept"]}");

        arrayDataOption.add(subject);
      } else {
        print('vacio');
      }
    });

    setState(() {
      data = arrayDataOption;
    });
    return arrayDataOption;
  }

  List<TravelExpenses> listTravelExpenses = [];
  bool loading = true;
  Future getTravelExpenses(int id) async {
    listTravelExpenses = await Detail().getTravelExpenses(id);

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
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
                // Datatable widget that have the property columns and rows.
                columns: const [
                  // Set the name of the column
                  DataColumn(
                    label: Text('Concepto'),
                  ),
                  /* DataColumn(
                    label: Text('Comentario'),
                  ),*/
                  DataColumn(
                    label: Text('Importe'),
                  ),
                ],
                /*rows: listTravelExpenses
                    .map(
                      (e) => DataRow(cells: [
                        DataCell(Text(e.paymentConcept.toString())),
                        DataCell(Text(e.comments.toString())),
                        DataCell(Text(e.totalUsed.toString())),
                      ]),
                    )
                    .toList(),*/
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
                items: data.map((e) {
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
    var estateSelected =
        data.firstWhere((dropdown) => dropdown['id'] == conceptId);

    //if (importe == estateSelected['payment_total']) {
    http.Response response =
        await Detail.insertImport(id, conceptId!, importe, comentery);
    // Map responseMap = jsonDecode(response.body);

    //}
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
