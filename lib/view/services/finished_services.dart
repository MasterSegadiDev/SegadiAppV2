import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:segadi/view/home/routes.dart';
import 'package:segadi/view/home/sidebar.dart';
import 'package:segadi/model/services/services_finished.dart';
import 'package:segadi/view/services/detail_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/view_model/globals.dart';
import 'package:http/http.dart' as http;

class FinishServiceList extends StatefulWidget {
  const FinishServiceList({Key? key}) : super(key: key);

  @override
  _FinishServiceList createState() => _FinishServiceList();
}

class _FinishServiceList extends State<FinishServiceList> {
  List<ServicesFinished> services = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();

    getServices().then((value) {
      setState(() {
        //getServices();
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Material es una hoja de papel conceptual en la que aparece la UI.

    return Scaffold(
      appBar: AppBar(
        title: Text('Servicios Terminados'),
        backgroundColor: Colors.green,
      ),
      drawer: const DrawerScreen(),
      body: loading == true
          ? Center(
              child: Container(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(),
              ),
            )
          : ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  borderOnForeground: true,
                  elevation: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: Text('Servicio:' + services[index].service,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        leading: Icon(FontAwesomeIcons.truck),
                        subtitle: Text(
                          "Cliente:" + services[index].client,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5.0),
                        alignment: Alignment.bottomLeft,
                        child: Text('Carga Origen:' +
                            services[index].origin +
                            '    ' +
                            'Carga Destino:' +
                            services[index].destination),
                      ),
                      Container(
                        padding: EdgeInsets.all(5.0),
                        alignment: Alignment.bottomLeft,
                        child: Text('Fecha Carga:2023-09-29 16:00:32' +
                            ' ' +
                            'Fecha Descarga:2023-09-30 16:00:32'),
                      ),
                      Container(
                        padding: EdgeInsets.all(5.0),
                        alignment: Alignment.bottomLeft,
                        child:
                            Text('Documentador:' + services[index].documenter),
                      ),
                      ButtonBar(
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailServicesFinishedScreen(
                                      id: services[index].id,
                                      detailFinished: true,
                                      response: {},
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Ver Detalle Servicio'))
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.phone),
        onPressed: () {
          // FlutterPhoneDirectCaller.callNumber('+523311364928');
        },
      ),
    );
  }

  Future<List<ServicesFinished>> getServices() async {
    int _id = 0;
    String _token = "";

    final prefs = await SharedPreferences.getInstance();
    _id = prefs.getInt('id') ?? 0;
    _token = prefs.getString('token') ?? '';
    var route = 'index.php';

    var response = await http
        .get(Uri.parse(baseURL + route).replace(queryParameters: {
          'r': 'esegadi/getterminadas',
          'id': _id.toString(),
          'token': _token,
        }))
        .timeout(const Duration(seconds: 90));

    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      for (Map<String, dynamic> index in data) {
        services.add(ServicesFinished.fromJson(index));
      }

      return services;
    } else {
      return services;
    }
  }
}
