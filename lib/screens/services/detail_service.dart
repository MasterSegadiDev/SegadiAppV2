import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:segadi/screens/home/sidebar.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/services/globals.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:segadi/models/services/detail_service.dart';

import 'package:fancy_button_flutter/fancy_button_flutter.dart';

class DetailServicesScreen extends StatefulWidget {
  final int id;
  DetailServicesScreen({super.key, required this.id});

  @override
  _DetailServicesScreen createState() => _DetailServicesScreen();
}

class _DetailServicesScreen extends State<DetailServicesScreen> {
  Future<DetailService>? detail;
  bool loading = true;

  Future<DetailService> getService() async {
    int user_id;
    String _token = "";

    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getInt('id') ?? 0;
    _token = prefs.getString('token') ?? '';
    var route = 'index.php';

    var response = await http
        .get(Uri.parse(baseURL + route).replace(queryParameters: {
          'r': 'esegadi/getdetalle',
          'id_remision': "24008",
          'token': _token,
          'id': user_id.toString(),
        }))
        .timeout(const Duration(seconds: 90));

    if (response.statusCode == 200) {
      return DetailService.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load detail');
    }
  }

  void initState() {
    super.initState();
    detail = getService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del servcio'),
        backgroundColor: Colors.green,
      ),
      drawer: const DrawerScreen(),
      body: Container(
        //height: 500,
        //width: double.infinity,
        //color: Colors.purple,

        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.only(top: 50),
        /* decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 3),
        ),*/
        child: FutureBuilder<DetailService>(
          future: detail,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: <Widget>[
                  Row(children: [
                    Text('Servicio:'),
                    Text(
                      snapshot.data!.service,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ]),
                  Divider(
                    color: Colors.white,
                  ),
                  Row(children: [Text('Remitente')]),
                  Divider(
                    color: Colors.black,
                  ),
                  Row(
                    children: [
                      Text('Razon Social: '),
                      Text(snapshot.data!.senderBusinessName)
                    ],
                  ),
                  Row(
                    children: [
                      Text('Telefono:'),
                      Text(snapshot.data!.senderPhoneNumber)
                    ],
                  ),
                  Row(
                    children: [
                      Text('Contacto:'),
                      Text('Sin nombre de contacto')
                    ],
                  ),
                  Row(
                    children: [
                      Text('Domicilio:'),
                      Text(snapshot.data!.senderStreet +
                          ' ' +
                          snapshot.data!.senderOutdoorNumber +
                          ' ' +
                          snapshot.data!.senderInteriorNumber +
                          ' ' +
                          snapshot.data!.senderZipCode +
                          ' ' +
                          snapshot.data!.senderState)
                    ],
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Row(children: [Text('Destinatario')]),
                  Divider(
                    color: Colors.black,
                  ),
                  Row(
                    children: [
                      Text('Razon Social:'),
                      Text(snapshot.data!.recipientBusinessName)
                    ],
                  ),
                  Row(
                    children: [
                      Text('Telefono:'),
                      Text(snapshot.data!.recipientPhoneNumber)
                    ],
                  ),
                  Row(
                    children: [
                      Text('Contacto:'),
                      Text('Sin nombre del contacto')
                    ],
                  ),
                  Row(
                    children: [
                      Text('Domicilio:'),
                      Text(snapshot.data!.recipientStreet +
                          ' ' +
                          snapshot.data!.recipientOutdoorNumber +
                          ' ' +
                          snapshot.data!.senderInteriorNumber +
                          ' ' +
                          snapshot.data!.recipientZipCode +
                          ' ' +
                          snapshot.data!.recipientState)
                    ],
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 30),
                      Column(
                        children: [Icon(FontAwesomeIcons.clipboardList)],
                      ),
                      SizedBox(width: 30),
                      Column(
                        children: [Icon(FontAwesomeIcons.locationDot)],
                      ),
                      SizedBox(width: 30),
                      Column(
                        children: [Icon(FontAwesomeIcons.mapLocationDot)],
                      ),
                      SizedBox(width: 30),
                      Column(
                        children: [Icon(FontAwesomeIcons.circleCheck)],
                      ),
                      SizedBox(width: 30),
                      Column(
                        children: [Icon(FontAwesomeIcons.fileInvoiceDollar)],
                      ),
                      SizedBox(width: 30),
                      Column(
                        children: [Icon(FontAwesomeIcons.solidFilePdf)],
                      )
                    ],
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Row(
                    children: <Widget>[
                      FancyButton(
                          button_text: "Iniciar Viaje ",
                          button_height: 40,
                          button_width: 350,
                          button_radius: 0,
                          button_color: Colors.green,
                          button_outline_color: Colors.green,
                          button_outline_width: 1,
                          button_text_color: Colors.white,
                          button_icon_color: Colors.white,
                          icon_size: 22,
                          button_text_size: 15,
                          onClick: () {
                            print("Button clicked");
                          })
                    ],
                  )
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
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
}
