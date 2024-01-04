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
        title: const Text('Detalle del servicio'),
        backgroundColor: Colors.black,
      ),
      drawer: const DrawerScreen(),
      body: _body(),
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

  _body() {
    return Column(children: <Widget>[
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
                  if (snapshot.data!.statusSupportId > 0) {
                    statusSupportId = snapshot.data!.statusSupportId;
                  }
                  if (snapshot.data!.list != null) {
                    listCked = true;
                  }
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
                      Row(
                        children: [Text(snapshot.data!.senderName)],
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
                        children: [Text(snapshot.data!.recipientBusinessName)],
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
                      Row(
                        children: [Text(snapshot.data!.recipientName)],
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
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(
                                    FontAwesomeIcons.clipboardList,
                                  ),
                                  iconSize: 40,
                                  onPressed: () =>
                                      _dialogCircleCheck((context)),
                                ),
                                const Text('Check List')
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(
                                    FontAwesomeIcons.locationDot,
                                  ),
                                  iconSize: 40,
                                  onPressed:
                                      snapshot.data!.isEnableStatusSupport
                                          ? () {
                                              _dialogBuilderEnbled(context);
                                            }
                                          : null,
                                ),
                                const Text('Status de Soporte')
                              ],
                            ),
                          ),
                          const Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.mapLocationDot,
                                  ),
                                  iconSize: 40,
                                  onPressed: null,
                                ),
                                Text('Ruta Sugerida')
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Colors.transparent,
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(
                                    FontAwesomeIcons.circleCheck,
                                  ),
                                  iconSize: 40,
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
                                const Text('Cierre de viaje')
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(
                                    FontAwesomeIcons.fileInvoiceDollar,
                                  ),
                                  iconSize: 40,
                                  // onPressed: () => sendTravelExpenses(id),
                                  onPressed: snapshot.data!.pendingMoneyChecks
                                      ? () {
                                          sendTravelExpenses(id);
                                        }
                                      : null,
                                ),
                                const Text(' Viaticos')
                              ],
                            ),
                          ),
                          const Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.solidFilePdf,
                                  ),
                                  iconSize: 40,
                                  onPressed: null,
                                ),
                                Text('Descargar Servicio')
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Colors.transparent,
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: snapshot.data!.isEnableButton
                                    ? () {
                                        addStatus(
                                            snapshot.data!.mandatoryStatusId!);
                                      }
                                    : null,
                                child: Text(snapshot.data!.mandatoryStatus!),
                              ),
                            ),
                          )
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
    ]);
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
          /* actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Continuar ruta'),
              onPressed: () {
                _continueRute(statusSupportId);
                Navigator.of(context).pop();
              },
            ),
          ],*/
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
      print(inspect(service_list));
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
