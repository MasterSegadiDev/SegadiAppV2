import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:segadi/model/services/travel_expenses.dart';

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
  String importe = "";
  String? valuePaymentConcept;
  int? selected;
  int? conceptId;

  getData() async {
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
    var jsonData = json.decode(result.body);

    setState(() {
      data = jsonData;
    });
    return jsonData;
  }

  @override
  void initState() {
    super.initState();
    getData();
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
            Table(children: const [
              TableRow(children: [
                Text(
                  'Concepto',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Comentario',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Importe',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ]),
            ]),
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
              TextFormField(
                keyboardType: TextInputType.name,
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
    print(importe);
    var estateSelected =
        data.firstWhere((dropdown) => dropdown['id'] == conceptId);
    print(estateSelected['payment_total']);
  }
}
