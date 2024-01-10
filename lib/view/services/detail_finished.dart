import 'package:flutter/material.dart';

import 'package:segadi/model/services/checklist.dart';
import 'package:segadi/view/home/sidebar.dart';

import 'package:segadi/view_model/services_operator/detail_service.dart';
import 'package:segadi/model/services/detail_service.dart';

class DetailServicesFinishedScreen extends StatefulWidget {
  final int id;

  const DetailServicesFinishedScreen({Key? key, required this.id})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _DetailServicesFinishedScreen createState() =>
      // ignore: no_logic_in_create_state
      _DetailServicesFinishedScreen(id);
}

class _DetailServicesFinishedScreen
    extends State<DetailServicesFinishedScreen> {
  _DetailServicesFinishedScreen(this.id);
  final int id;

  Future<DetailService>? detail;
  bool loading = true;

  // ignore: non_constant_identifier_names
  Future<CheckList>? list_data;

  final int value = 0;

  final bool valueIcon = false;

  String status = "";
  int statusId = 0;
  int serviceId = 0;

  @override
  void initState() {
    super.initState();
    detail = Detail().getService(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle Remisión'),
        backgroundColor: Colors.green,
      ),
      drawer: const DrawerScreen(),
      body: Column(children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.all(0.0),
              color: Colors.white,
              alignment: Alignment.center,
              child: FutureBuilder<DetailService>(
                future: detail,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    serviceId = snapshot.data!.id;

                    return Column(
                      children: <Widget>[
                        Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Servicio: ${snapshot.data!.service}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.transparent,
                          height: 10.0,
                        ),
                        const Row(children: [
                          Text(
                            'Remitente:',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ]),
                        const Divider(
                          color: Colors.transparent,
                          height: 15.0,
                        ),
                        const Row(
                          children: [
                            Text(
                              'Razon Social:',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [Text(snapshot.data!.senderBusinessName)],
                        ),
                        const Row(
                          children: [
                            Text(
                              'Télefono:',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [Text(snapshot.data!.senderPhoneNumber)],
                        ),
                        const Row(
                          children: [
                            Text(
                              'Contacto:',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Row(
                          children: [Text('Sin nombre de contacto')],
                        ),
                        const Row(
                          children: [
                            Text(
                              'Domicilio:',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                                '${snapshot.data!.senderStreet} ${snapshot.data!.senderOutdoorNumber} ${snapshot.data!.senderZipCode}')
                          ],
                        ),
                        const Divider(
                          color: Colors.transparent,
                        ),
                        const Row(children: [
                          Text(
                            'Destinatario:',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ]),
                        const Divider(
                          color: Colors.transparent,
                          height: 15.0,
                        ),
                        const Row(
                          children: [
                            Text(
                              'Razon Social:',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(snapshot.data!.recipientBusinessName)
                          ],
                        ),
                        const Row(
                          children: [
                            Text(
                              'Télefono:',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [Text(snapshot.data!.recipientPhoneNumber)],
                        ),
                        const Row(
                          children: [
                            Text(
                              'Contacto:',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Row(
                          children: [Text('Sin nombre del contacto')],
                        ),
                        const Row(
                          children: [
                            Text(
                              'Domicilio:',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${snapshot.data!.recipientStreet} ${snapshot.data!.recipientOutdoorNumber}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                                '${snapshot.data!.recipientZipCode} ${snapshot.data!.recipientState}'),
                          ],
                        ),
                        const Divider(
                          color: Colors.transparent,
                        ),
                        const Row(children: [
                          Text(
                            'Comisiones:',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ]),
                        const Divider(
                          color: Colors.transparent,
                        ),
                        const Row(
                          children: [
                            Text(
                              'Comisión Total:',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Text(''),
                          ],
                        ),
                        const Row(
                          children: [
                            Text(
                              'Viaticos:',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Text('1800.00'),
                          ],
                        ),
                        const Row(
                          children: [
                            Text(
                              'Viaticos Comprobados:',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Text('800.00'),
                          ],
                        ),
                        const Row(
                          children: [
                            Text(
                              'Diferencia de viaticos:',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Text('1000.00'),
                          ],
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        elevation: 20.0,
        child: const Icon(Icons.phone),
        onPressed: () {
          // FlutterPhoneDirectCaller.callNumber('+523311364928');
        },
      ),
    );
  }
}
