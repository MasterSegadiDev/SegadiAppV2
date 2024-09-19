import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'package:segadi/model/services/checklist.dart';
import 'package:segadi/model/services/detail_finished.dart';
import 'package:segadi/view/home/sidebar.dart';
import 'package:segadi/view_model/login_local_auth/auth_login.dart';

import 'package:segadi/view_model/services_operator/detail_finished.dart';

class DetailServicesFinishedScreen extends StatefulWidget {
  final int id;

   DetailServicesFinishedScreen({Key? key, required this.id})
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

  // ignore: non_ant_identifier_names
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
        title:  Text(
          'Detalle Remision',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme:  IconThemeData(color: Colors.white),
        backgroundColor:  Color(0xFF2C522A),
      ),
      drawer:  DrawerScreen(),
      body: FutureBuilder<DetailFinished>(
        future: detailFinished,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            serviceId = snapshot.data!.id;
            // var userRoll = 'NO';
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding:  EdgeInsets.all(10.0),
                      child: Container(
                        padding:  EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:  Color(0xFF84A756),
                          ),
                          color:  Color(0xFF84A756),
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
                                    style:  TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                 Row(
                                  children: [
                                    Text(
                                      'Remitente',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    )
                                  ],
                                ),
                                 Divider(
                                  height: 15.0,
                                  color: Colors.white,
                                ),
                                 Row(
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
                                SizedBox(
                                  width: double.infinity,
                                  height: 20,
                                  child: AutoSizeText(
                                    snapshot.data!.senderBusinessName,
                                    style:  TextStyle(
                                        fontSize: 14, color: Colors.white),
                                    maxLines: 2,
                                  ),
                                ),
                                 Row(
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
                                      style:
                                           TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                                 Row(
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
                                      style:
                                           TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                                 Row(
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
                                // Row(
                                //   children: [
                                //     Text(
                                //       '${snapshot.data!.senderStreet} ${snapshot.data!.senderOutdoorNumber} ${snapshot.data!.senderZipCode}',
                                //       style:  TextStyle(color: Colors.white),
                                //     )
                                //   ],
                                // ),
                                SizedBox(
                                  width: double.infinity,
                                  height: 20,
                                  child: AutoSizeText(
                                    '${snapshot.data!.senderStreet} ${snapshot.data!.senderOutdoorNumber} ${snapshot.data!.senderZipCode}',
                                    style:  TextStyle(
                                        fontSize: 14, color: Colors.white),
                                    maxLines: 2,
                                  ),
                                ),
                                 Divider(
                                  height: 15.0,
                                  color: Colors.transparent,
                                ),
                                 Row(
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
                                 Divider(
                                  height: 15.0,
                                  color: Colors.white,
                                ),
                                 Row(
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

                                SizedBox(
                                  width: double.infinity,
                                  height: 20,
                                  child: AutoSizeText(
                                    snapshot.data!.recipientBusinessName,
                                    style:  TextStyle(
                                        fontSize: 14, color: Colors.white),
                                    maxLines: 2,
                                  ),
                                ),
                                 Row(
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
                                      style:
                                           TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                                 Row(
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
                                      style:
                                           TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                                 Row(
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
                                // Row(
                                //   children: [
                                //     Text(
                                //       "${snapshot.data!.recipientStreet} ${snapshot.data!.recipientOutdoorNumber}${snapshot.data!.recipientZipCode} ${snapshot.data!.recipientState}",
                                //       style:  TextStyle(color: Colors.white),
                                //     ),
                                //   ],
                                // ),
                                SizedBox(
                                  width: double.infinity,
                                  height: 20,
                                  child: AutoSizeText(
                                    '${snapshot.data!.recipientStreet} ${snapshot.data!.recipientOutdoorNumber}${snapshot.data!.recipientZipCode} ${snapshot.data!.recipientState}',
                                    style:  TextStyle(color: Colors.white),
                                    maxLines: 2,
                                  ),
                                ),
                                 Divider(
                                  height: 15.0,
                                  color: Colors.transparent,
                                ),
                                if (snapshot.data!.userRoll == false)
                                   Row(
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
                                 Divider(
                                  height: 15.0,
                                  color: Colors.white,
                                ),
                                if (snapshot.data!.userRoll == false)
                                   Row(
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
                                if (snapshot.data!.userRoll == false)
                                  Row(
                                    children: [
                                      Text(
                                        snapshot.data!.paymentTotal.toString(),
                                        style:  TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                if (snapshot.data!.userRoll == false)
                                   Row(
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
                                if (snapshot.data!.userRoll == false)
                                  Row(
                                    children: [
                                      Text(
                                        snapshot.data!.allowanceTotal
                                            .toString(),
                                        style:  TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                if (snapshot.data!.userRoll == false)
                                   Row(
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
                                if (snapshot.data!.userRoll == false)
                                  Row(
                                    children: [
                                      Text(
                                        snapshot.data!.allowanceChecked
                                            .toString(),
                                        style:  TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                if (snapshot.data!.userRoll == false)
                                   Row(
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
                                if (snapshot.data!.userRoll == false)
                                  Row(
                                    children: [
                                      Text(
                                        snapshot.data!.allowanceDifference
                                            .toString(),
                                        style:  TextStyle(
                                            color: Colors.white),
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
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return  CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        elevation: 20.0,
        child:  Icon(
          Icons.phone,
          color: Colors.white,
        ),
        onPressed: () {
          FlutterPhoneDirectCaller.callNumber('+523311364928');
          alert();
        },
      ),
    );
  }

  // ignore: non_ant_identifier_names
  Widget Comitions(snapshot) {
    return  Column(
      children: [],
    );
  }

  void alert() async {
    await AuthServices.alert();
  }
}
