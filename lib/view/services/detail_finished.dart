import 'package:flutter/material.dart';

import 'package:segadi/model/services/checklist.dart';
import 'package:segadi/model/services/detail_finished.dart';
import 'package:segadi/view/home/sidebar.dart';

import 'package:segadi/view_model/services_operator/detail_finished.dart';

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

  Future<DetailFinished>? detailFinished;
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
    detailFinished = Detail().getService(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle Remision',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      drawer: const DrawerScreen(),
      body: FutureBuilder<DetailFinished>(
        future: detailFinished,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            serviceId = snapshot.data!.id;
            return Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF84A756),
                        ),
                        color: const Color(0xFF84A756),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Servicio: ${snapshot.data!.service}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              const Row(children: [
                                Text(
                                  'Remitente',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                )
                              ]),
                              const Row(
                                children: [
                                  Text(
                                    'Razón Social:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    snapshot.data!.senderBusinessName,
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Télefono:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    snapshot.data!.senderPhoneNumber,
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Contacto:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    snapshot.data!.senderName,
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Domicilio:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${snapshot.data!.senderStreet} ${snapshot.data!.senderOutdoorNumber} ${snapshot.data!.senderZipCode}',
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Destinatario',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Razón Social:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    snapshot.data!.recipientBusinessName,
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Télefono:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    snapshot.data!.recipientPhoneNumber,
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Contacto:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    snapshot.data!.recipientName,
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Domicilio:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${snapshot.data!.recipientStreet} ${snapshot.data!.recipientOutdoorNumber}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${snapshot.data!.recipientZipCode} ${snapshot.data!.recipientState}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Comisiones',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Comisión Total:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    snapshot.data!.paymentTotal,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Total Asignado:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    snapshot.data!.allowanceTotal,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Viaticos Comprobados:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    snapshot.data!.allowanceChecked,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Diferencia de viaticos:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    snapshot.data!.allowanceDifference,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return const CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        elevation: 20.0,
        child: const Icon(
          Icons.phone,
          color: Colors.white,
        ),
        onPressed: () {
          // FlutterPhoneDirectCaller.callNumber('+523311364928');
        },
      ),
    );
  }
}
