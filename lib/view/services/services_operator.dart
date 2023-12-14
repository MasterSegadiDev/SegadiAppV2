import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:segadi/view/services/detail_service.dart';

import 'package:segadi/view/home/sidebar.dart';
import 'package:segadi/model/services/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/view_model/globals.dart';
import 'package:http/http.dart' as http;

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ServicesScreen createState() => _ServicesScreen();
}

class _ServicesScreen extends State<ServicesScreen> {
  List<Services> services = [];
  bool loading = true;

  int? id;

  @override
  void initState() {
    super.initState();

    getServices().then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Material es una hoja de papel conceptual en la que aparece la UI.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Remisiones Asignadas'),
        backgroundColor: Colors.black,
      ),
      drawer: const DrawerScreen(),
      body: loading == true
          ? const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(),
              ),
            )
          : ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    sendScreenWidget(services[index].id);
                  },
                  child: Card(
                    color: Colors.white,
                    borderOnForeground: true,
                    elevation: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                              'Remision No:  ${services[index].service}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          leading: const Icon(
                            FontAwesomeIcons.truck,
                            color: Colors.green,
                          ),
                          subtitle: Text(
                            "Cliente: ${services[index].client}",
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              'Carga Origen:  ',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              services[index].origin,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Fecha Carga:  ',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              services[index].loadDate,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.transparent,
                          height: 10.0,
                        ),
                        Row(
                          children: [
                            const Text(
                              'Carga Destino:  ',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              services[index].destination,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Fecha Descarga:  ',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              services[index].unloadDate,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.transparent,
                          height: 10.0,
                        ),
                        Row(
                          children: [
                            const Text(
                              'Documentador:  ',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              services[index].documenter,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.transparent,
                          height: 10.0,
                        ),
                      ],
                    ),
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

  sendScreenWidget(id) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailServicesScreen(
          id: id,
        ),
      ),
    );
  }

  Future<List<Services>> getServices() async {
    int id;
    String token;

    final prefs = await SharedPreferences.getInstance();
    id = prefs.getInt('id') ?? 0;
    token = prefs.getString('token') ?? '';
    var route = 'index.php';

    var response = await http
        .get(Uri.parse(baseURL + route).replace(queryParameters: {
          'r': 'esegadi/getactivas',
          'id': id.toString(),
          'token': token,
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
