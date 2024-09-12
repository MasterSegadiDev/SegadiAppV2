import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/view_model/services_operator/travel_expenses.dart';

class ListTravelExpensesView extends StatefulWidget {
  const ListTravelExpensesView({super.key});

  @override
  State<ListTravelExpensesView> createState() => _ListTravelExpensesView();
}

class _ListTravelExpensesView extends State<ListTravelExpensesView> {
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

  @override
  Widget build(BuildContext context) {
    final travelExpensesViewModel =
        Provider.of<TravelExpensesViewModel>(context, listen: false);

    listDataOption = travelExpensesViewModel.listItemsTravelExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text('Viáticos asignados'),
      ),
      body: SafeArea(
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
                        items: travelExpensesViewModel.listItemsTravelExpenses
                            .map((e) {
                          return DropdownMenuItem(
                            value: e.id,
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                e.paymentConcept.toString() +
                                    '  \$' +
                                    e.paymentTotal.toString(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          conceptId = value;
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
                  width: double.infinity,
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
                  width: double.infinity,
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
                  width: double.infinity,
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () => validate(),
                                //onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(20), // <-- Radius
                                  ),
                                  backgroundColor: Colors.lightGreen,
                                ),
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

  void validate() async {
    double importSelected = 0;
    double importAdd = 0;
    var estateSelected =
        listDataOption.firstWhere(( dropdown) => dropdown.id == conceptId);

    

    // importAdd = double.parse(importe);
     importSelected = double.parse(estateSelected.paymentTotal);

     print(importSelected);

    // if (importAdd <= importSelected) {
    //   print('Registrar concepto');
    //   //http.Response response = await TravelExpensesService()
    //   //  .insertImport(id, conceptId!, importe, comentery);
    //   // Map responseMap = jsonDecode(response.body);

    //   //if (response.statusCode == 200) {
    //   //getTravelExpenses(id);
    //   // ignore: use_build_context_synchronously
    //   //  Navigator.pop(context);
    //   // }
    // } else if (importAdd > importSelected) {
    //   message(context, importAdd, importSelected);
    // }
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
}
