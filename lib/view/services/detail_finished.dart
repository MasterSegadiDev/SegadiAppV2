import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:segadi/model/services/checklist.dart';
import 'package:segadi/view/home/sidebar.dart';

import 'package:segadi/view_model/services_operator/detail_service.dart';
import 'package:segadi/model/services/detail_service.dart';

import 'package:http/http.dart' as http;

class DetailServicesFinishedScreen extends StatefulWidget {
  final int id;
  final bool detailFinished;
  final Map response;
  const DetailServicesFinishedScreen(
      {Key? key,
      required this.id,
      required this.detailFinished,
      required this.response})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _DetailServicesFinishedScreen createState() =>
      // ignore: no_logic_in_create_state
      _DetailServicesFinishedScreen(id, detailFinished, response);
}

class _DetailServicesFinishedScreen
    extends State<DetailServicesFinishedScreen> {
  _DetailServicesFinishedScreen(this.id, this.detailFinished, this.response);
  final int id;
  final bool detailFinished;
  final Map response;

  Future<DetailService>? detail;
  bool loading = true;

  // ignore: non_constant_identifier_names
  Future<CheckList>? list_data;

  final int value = 0;

  final bool valueIcon = false;

  bool _isEnable = true;
  bool _isEnablButton = true;

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
        title: const Text('Servicio finalizado'),
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
                    //  status = snapshot.data!.status;
                    //   statusId = snapshot.data!.statusId;
                    serviceId = snapshot.data!.id;

                    /*  if (snapshot.data!.statusId > 0) {
                      _isEnable = true;
                      _isEnablButton = true;
                    }
*/
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
                                '${snapshot.data!.recipientStreet} ${snapshot.data!.recipientOutdoorNumber} ${snapshot.data!.recipientZipCode} ${snapshot.data!.recipientState}')
                          ],
                        ),
                        const Divider(
                          color: Colors.transparent,
                          height: 20,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: IconButton(
                                icon:
                                    const Icon(FontAwesomeIcons.clipboardList),
                                iconSize: 50.0,
                                tooltip: 'CheckList',
                                onPressed: _isEnable
                                    // ignore: dead_code
                                    ? () {
                                        Navigator.pushNamed(
                                            context, '/check_list', arguments: {
                                          'id': id,
                                          'value': value,
                                          'detailFinished': detailFinished
                                        });
                                      }
                                    : null,
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                  icon:
                                      const Icon(FontAwesomeIcons.locationDot),
                                  iconSize: 50.0,
                                  tooltip: 'Localidad',
                                  onPressed: () => _dialogBuilder(context)),
                            ),
                            const Expanded(
                              child: Icon(FontAwesomeIcons.mapLocationDot,
                                  size: 50),
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.transparent,
                          height: 30,
                        ),
                        const Row(
                          children: <Widget>[
                            Expanded(
                              child:
                                  Icon(FontAwesomeIcons.circleCheck, size: 50),
                            ),
                            Expanded(
                              child: Icon(FontAwesomeIcons.fileInvoiceDollar,
                                  size: 50),
                            ),
                            Expanded(
                              child:
                                  Icon(FontAwesomeIcons.solidFilePdf, size: 50),
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.transparent,
                          height: 25,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                // ignore: dead_code
                                onPressed: _isEnablButton ? () {} : null,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.green),
                                ),
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    height: 0,
                                  ),
                                ),
                              ),
                            ))
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

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registrar Parada'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              childAspectRatio: 8.0 / 9.0,
              children: <Widget>[
                GestureDetector(
                  onTap: () => getValue(value: 24),
                  child: const Card(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: SizedBox(
                            child: Image(
                              width: 50,
                              height: 50,
                              color: Colors.blue,
                              image: AssetImage("assets/images/toilet.png"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => getValue(value: 22),
                  child: const Card(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: SizedBox(
                            child: Image(
                              width: 50,
                              height: 50,
                              color: Colors.orange,
                              image: AssetImage("assets/images/restaurant.png"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => getValue(value: 38),
                  child: const Card(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: SizedBox(
                            child: Image(
                              width: 50,
                              height: 50,
                              color: Colors.black,
                              image: AssetImage("assets/images/sleeping.png"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => getValue(value: 39),
                  child: const Card(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: SizedBox(
                            child: Image(
                              width: 50,
                              height: 50,
                              color: Colors.yellow,
                              image: AssetImage("assets/images/gas.png"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Continuar ruta'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void getValue({required int value}) {
    print(value);
  }
}
