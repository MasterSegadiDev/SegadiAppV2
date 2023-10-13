import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:segadi/screens/home/routes.dart';
import 'package:segadi/screens/home/sidebar.dart';
import 'package:segadi/models/services/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/services/globals.dart';
import 'package:http/http.dart' as http;

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  _ServicesScreen createState() => _ServicesScreen();
}

class _ServicesScreen extends State<ServicesScreen> {
  List<Services> services = [];
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
        title: Text('Servicios Asignados'),
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
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailServicesScreen(
                                      id: services[index].id,
                                    ),
                                  )),
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

  Future<List<Services>> getServices() async {
    int _id;
    String _token;

    final prefs = await SharedPreferences.getInstance();
    _id = prefs.getInt('id') ?? 0;
    _token = prefs.getString('token') ?? '';
    var route = 'index.php';

    var response = await http
        .get(Uri.parse(baseURL + route).replace(queryParameters: {
          'r': 'esegadi/getactivas',
          'id': _id.toString(),
          'token': _token,
        }))
        .timeout(const Duration(seconds: 90));
    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      for (Map<String, dynamic> index in data) {
        services.add(Services.fromJson(index));
      }

      return services;
    } else {
      return services;
    }
  }
}

/*
Widget _buildItem(Services services) {
  return Card(
    color: Colors.white,
    borderOnForeground: true,
    elevation: 10,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          title: Text('Servicio:',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          leading: Icon(FontAwesomeIcons.truck),
          subtitle: Text(
            "Cliente:",
            style: TextStyle(color: Colors.black),
          ),
        ),
        Container(
          padding: EdgeInsets.all(5.0),
          alignment: Alignment.bottomLeft,
          child: Text('Carga Origen:' + '           ' + 'Carga Destino:'),
        ),
        Container(
          padding: EdgeInsets.all(5.0),
          alignment: Alignment.bottomLeft,
          child: Text('Fecha Carga:' + '           ' + 'Fecha Descarga:'),
        ),
        Container(
          padding: EdgeInsets.all(5.0),
          alignment: Alignment.bottomLeft,
          child: Text('Documentador:'),
        ),
        ButtonBar(
          children: [
            TextButton(
                onPressed: () {}, child: const Text('Ver Detalle Servicio'))
          ],
        ),
      ],
    ),
  );
}
*/
