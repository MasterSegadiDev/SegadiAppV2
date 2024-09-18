import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'package:segadi/view_model/services_operator/travel_expenses.dart';

class ListTravelExpensesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final travelExpensesViewModel =
        Provider.of<TravelExpensesViewModel>(context, listen: false);

    return Container(
      height: 600,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(0.0),
              child: SizedBox(
                child: Column(
                  children: [
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: 'Selecciona una concepto',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      hint: Text('Selecciona un concepto'),
                      items: travelExpensesViewModel.items.map((e) {
                        return DropdownMenuItem(
                          value: e.id,
                          child: Container(
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
                      onChanged: (value) =>
                          travelExpensesViewModel.concetId = value!,
                      isDense: true,
                      isExpanded: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    TextFormField(
                      minLines: 4,
                      keyboardType: TextInputType.multiline,
                      maxLines: 250,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        filled: true,
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        labelText: 'Agrega un comentario',
                      ),
                      controller: travelExpensesViewModel.textController1,
                      onChanged: (value) =>
                          travelExpensesViewModel.comentary = value,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        labelText: 'Agrega un importe a registrar',
                      ),
                      controller: travelExpensesViewModel.textController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      onChanged: (value) =>
                          travelExpensesViewModel.import = value,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                await travelExpensesViewModel.insertImport();
                                if (travelExpensesViewModel.errorMessage !=
                                    null) {
                                  return showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        //title: ,
                                        insetPadding: const EdgeInsets.all(20),
                                        content: Text(
                                            '${travelExpensesViewModel.errorMessage}'),
                                      );
                                    },
                                  );
                                }
                                if (travelExpensesViewModel.errorMessage ==
                                    null) {
                                  Navigator.of(context).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(20), // <-- Radius
                                ),
                                backgroundColor: Colors.lightGreen,
                              ),
                              child: Text(
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
            ),
          ],
        ),
      ),
    );
  }
}

