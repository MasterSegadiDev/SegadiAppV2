import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:segadi/model/services/checklist.dart';

import 'package:segadi/view/home/sidebar.dart';
import 'package:segadi/view/services/travel_expenses.dart';
import 'package:segadi/view_model/globals.dart';
import 'package:segadi/view_model/services_operator/detail_service.dart';
import 'package:segadi/model/services/detail_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetailServicesScreen extends StatefulWidget {
  final int id;
  // final bool detailFinished;
  // final Map response;
  const DetailServicesScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _DetailServicesScreen createState() =>
      // ignore: no_logic_in_create_state
      _DetailServicesScreen(id);
}

class _DetailServicesScreen extends State<DetailServicesScreen> {
  _DetailServicesScreen(this.id);
  final int id;

  late Future<DetailService>? detail;
  //late Future<DetailService>? _detailService;
  //bool loadingCheck = true;
  final int value = 0;

  int statusSupportId = 0;

  bool loading = true;

  bool listCked = false;

  @override
  void initState() {
    super.initState();
    detail = Detail().getService(id);
    getCheckList().then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  void addStatus(statusId) async {
    http.Response response = await Detail.addStatus(id, statusId);
    if (response.statusCode == 200) {
      _loadData();
    }
  }

  _loadData() async {
    detail = Detail().getService(id);

    setState(() {
      detail = detail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle Remisión'),
        backgroundColor: const Color(0xFF2C522A),
      ),
      backgroundColor: Colors.white,
      drawer: const DrawerScreen(),
      body: FutureBuilder<DetailService>(
        future: detail,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.statusSupportId > 0) {
              statusSupportId = snapshot.data!.statusSupportId;
            }
            if (snapshot.data!.list != null) {
              listCked = true;
            }
            return Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 420,
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
                              const Divider(
                                height: 15.0,
                                color: Colors.white,
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Razon Social:',
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
                              const Divider(
                                color: Colors.green,
                                height: 15.0,
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
                              const Divider(
                                color: Colors.white,
                                height: 15.0,
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 130,
                      width: 380,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: const Icon(
                                        FontAwesomeIcons.clipboardList,
                                        color: Colors.blue,
                                      ),
                                      iconSize: 27.5,
                                      onPressed: () =>
                                          _dialogCircleCheck((context)),
                                    ),
                                    const Text(
                                      'Check List',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    iconStatus(context,
                                        snapshot.data!.isEnableStatusSupport),
                                  ],
                                  /*<Widget>[
                                    IconButton(
                                      icon: const Icon(
                                        FontAwesomeIcons.locationDot,
                                      ),
                                      iconSize: 27.5,
                                      onPressed:
                                          snapshot.data!.isEnableStatusSupport
                                              ? () {
                                                  _showBottomSheet(context);
                                                }
                                              : null,
                                    ),
                                    const Text(
                                      'Status de Soporte',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                    )
                                  ],*/
                                ),
                              ),
                              const Expanded(
                                child: Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(
                                        FontAwesomeIcons.mapLocationDot,
                                        color: Colors.blueAccent,
                                      ),
                                      iconSize: 27.5,
                                      onPressed: null,
                                    ),
                                    Text(
                                      'Ruta Sugerida',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: const Icon(
                                        FontAwesomeIcons.circleCheck,
                                        color: Colors.green,
                                      ),
                                      iconSize: 27.5,
                                      // onPressed: snapshot.data!.isEnableTripClosure
                                      onPressed: snapshot.data!.serviceClosed
                                          // ignore: dead_code
                                          ? () {
                                              Navigator.pushNamed(
                                                  context, '/trip_closure',
                                                  arguments: {
                                                    'id': snapshot.data!.id,
                                                    'serviceId':
                                                        snapshot.data!.service
                                                  });
                                            }
                                          : null,
                                    ),
                                    const Text(
                                      'Cierre de viaje',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: const Icon(
                                        FontAwesomeIcons.fileInvoiceDollar,
                                        color: Colors.green,
                                      ),
                                      iconSize: 27.5,
                                      // onPressed: () => sendTravelExpenses(id),
                                      onPressed:
                                          snapshot.data!.pendingMoneyChecks
                                              ? () {
                                                  sendTravelExpenses(id);
                                                }
                                              : null,
                                    ),
                                    const Text(
                                      ' Viaticos',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                    )
                                  ],
                                ),
                              ),
                              const Expanded(
                                child: Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(
                                        FontAwesomeIcons.solidFilePdf,
                                        color: Colors.red,
                                      ),
                                      iconSize: 27.5,
                                      onPressed: null,
                                    ),
                                    Text(
                                      'Descargar Servicio',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                    )
                                  ],
                                ),
                              ),
                            ],
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
                                    onPressed: snapshot.data!.isEnableButton
                                        ? () {
                                            addStatus(snapshot
                                                .data!.mandatoryStatusId!);
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // <-- Radius
                                        ),
                                        backgroundColor:
                                            const Color(0xFF2C522A)),
                                    child:
                                        Text(snapshot.data!.mandatoryStatus!),
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
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  Future<void> _dialogBuilderEnbled(BuildContext context) {
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
                  onTap: () async {
                    addStatusSupport(value: 24);
                    Navigator.of(context).pop();
                  },
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
                  onTap: () async {
                    addStatusSupport(value: 22);
                    Navigator.of(context).pop();
                  },
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
                  onTap: () async {
                    addStatusSupport(value: 38);
                    Navigator.of(context).pop();
                  },
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
                  onTap: () async {
                    addStatusSupport(value: 39);
                    Navigator.of(context).pop();
                  },
                  child: const Card(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: SizedBox(
                            child: Image(
                              width: 50,
                              height: 50,
                              color: Colors.greenAccent,
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
          actions: [
            ElevatedButton(
              onPressed: () {
                _continueRute(statusSupportId);
                Navigator.of(context).pop();
              },
              child: const Text('Continuar ruta'),
            ),
          ],
        );
      },
    );
  }

  //check list
  // ignore: non_constant_identifier_names
  List<CheckList> service_list = [];

  final List<bool> _isChecked = [];
  bool canUpload = false;

  Map<dynamic, dynamic> sumMap = {};
  //check list

  Future<void> _dialogCircleCheck(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Check List"),
              content: SizedBox(
                width: 350,
                child: loading == true
                    ? const Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: service_list.length,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                            title: Text(service_list[index].option),
                            value: _isChecked[index],
                            onChanged: (val) {
                              setState(() {
                                _isChecked[index] = val!;
                                canUpload = true;
                                sumMap[service_list[index].id.toString()] =
                                    canUpload;
                              });
                            },
                          );
                        },
                      ),
              ),
              actions: [
                if (listCked == false)
                  ElevatedButton(
                    onPressed: canUpload
                        ? () {
                            confirmationCheckList(context, id);
                          }
                        : null, //addOptionList(id),
                    child: const Text('Registrar'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> confirmationCheckList(BuildContext context, id) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: const Text(''),
          content: const Text('¿Esta seguro de guardar este check list?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Si'),
              onPressed: () {
                addOptionList(id);
              },
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'This is a Modal bottom sheet!',
                  style: Theme.of(context).textTheme.headline4,
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  child: const Text('Close BottomSheet'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget iconStatus(BuildContext context, bool status) {
    if (status == false) {
      return const IconButton(
        icon: Icon(
          FontAwesomeIcons.locationDot,
        ),
        onPressed: null,
      );
    } else {
      return IconButton(
        icon: const Icon(
          FontAwesomeIcons.locationDot,
          color: Colors.red,
        ),
        onPressed: () {},
      );
    }
  }

  Future<void> addStatusSupport({required int value}) async {
    print(value);
    http.Response response = await Detail.addStatusSupport(id, value, 'begin');
    if (response.statusCode == 200) {
      setState(() {
        _loadData();
      });
    }
  }

  Future<void> _continueRute(int statusSupportId) async {
    http.Response response =
        await Detail.addStatusSupport(id, statusSupportId, 'end');
    if (response.statusCode == 200) {
      setState(() {
        _loadData();
      });
    }
  }

  Future<List<CheckList>> getCheckList() async {
    String token;

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    var route = 'index.php';

    var response = await http
        .get(Uri.parse(baseURL + route).replace(queryParameters: {
          'r': 'esegadi/get-puntosrevision',
          'token': token,
        }))
        .timeout(const Duration(seconds: 90));
    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      for (Map<String, dynamic> index in data) {
        service_list.add(CheckList.fromJson(index));
      }
      // ignore: unused_local_variable
      for (var idx in service_list) {
        _isChecked.add(false);
      }

      return service_list;
    } else {
      return service_list;
    }
  }

  addOptionList(int id) async {
    http.Response response = await Detail.addOption(id, sumMap);
    print(response.statusCode);
    if (response.statusCode == 200) {
      setState(() {
        _loadData();
      });
      print('Tu registro se guardo con éxito');
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  sendTravelExpenses(int id) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TravelExpensesScreen(
          id: id,
        ),
      ),
    );
  }
}
