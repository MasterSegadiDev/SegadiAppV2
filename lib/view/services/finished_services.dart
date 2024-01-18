import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:segadi/view/home/routes.dart';
import 'package:segadi/view/home/sidebar.dart';
import 'package:segadi/model/services/services_finished.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/view_model/globals.dart';
import 'package:http/http.dart' as http;

class FinishServiceList extends StatefulWidget {
  const FinishServiceList({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
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
        title: const Text('Remisiones Finalizadas'),
        backgroundColor: const Color(0xFF2C522A),
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
              padding: const EdgeInsets.all(10),
              itemCount: services.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    sendScreenWidget(services[index].id);
                  },
                  child: Card(
                    color: const Color(0xFF84A756),
                    borderOnForeground: true,
                    elevation: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                              'Remision No:  ${services[index].service}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          leading: const Icon(
                            FontAwesomeIcons.truck,
                            color: Colors.white,
                          ),
                          subtitle: Text(
                            "Cliente: ${services[index].client}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              '   Carga Origen:  ',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              services[index].origin,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              '   Fecha Carga:  ',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              services[index].loadDate,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
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
                              '   Carga Destino:  ',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              services[index].destination,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              '   Fecha Descarga:  ',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              services[index].unloadDate,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
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
                              '   Documentador:  ',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              services[index].documenter,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
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
        builder: (context) => DetailServicesFinishedScreen(
          id: id,
        ),
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
