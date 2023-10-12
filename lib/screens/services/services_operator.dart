import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:segadi/screens/home/sidebar.dart';
import 'package:segadi/models/services/services.dart';
import 'package:segadi/services/services_operator/assigned_services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/services/globals.dart';
import 'package:http/http.dart' as http;
import 'package:segadi/models/services/services.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  _ServicesScreen createState() => _ServicesScreen();
}

class _ServicesScreen extends State<ServicesScreen> {
  List<Services> services = [];

  @override
  void initState() {
    super.initState();
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
      //body: ListView(children: services(getList()).toList()),
      body: ListView.builder(
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
                  title: Text('Servicio' + services[index].service,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
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
                  child:
                      Text('Fecha Carga:' + '           ' + 'Fecha Descarga:'),
                ),
                Container(
                  padding: EdgeInsets.all(5.0),
                  alignment: Alignment.bottomLeft,
                  child: Text('Documentador:' + services[index].documenter),
                ),
                ButtonBar(
                  children: [
                    TextButton(
                        onPressed: () {},
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
    int _id = 0;
    String _token = "";

    final prefs = await SharedPreferences.getInstance();
    _id = prefs.getInt('id') ?? 0;
    _token = prefs.getString('token') ?? '';
    var route = 'index.php';

    /*var url = Uri.parse(baseURL + route).replace(queryParameters: {
      'r': 'esegadi/getactivas',
      'id': _id.toString(),
      'token': _token,
    });*/

    var response =
        await http.get(Uri.parse(baseURL + route).replace(queryParameters: {
      'r': 'esegadi/getactivas',
      'id': _id.toString(),
      'token': _token,
    }));
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
