import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:segadi/screens/home/sidebar.dart';
import 'package:segadi/services/services_operator/assigned_services.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Material es una hoja de papel conceptual en la que aparece la UI.
    return Scaffold(
      appBar: AppBar(
        title: Text('Servicios Asignados'),
        backgroundColor: Colors.green,
      ),
      drawer: const DrawerScreen(),
      body: new ListView(children: services.map(_buildItem).toList()),
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

Widget _buildItem(Service service) {
  return Card(
    color: Colors.white,
    borderOnForeground: true,
    elevation: 10,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          title: Text('Servicio:${service.service}',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          leading: Icon(FontAwesomeIcons.truck),
          subtitle: Text(
            "Cliente:${service.client}",
            style: TextStyle(color: Colors.black),
          ),
        ),
        Container(
          padding: EdgeInsets.all(5.0),
          alignment: Alignment.bottomLeft,
          child: Text('Carga Origen:${service.loadOrigen}' +
              '           ' +
              'Carga Destino:${service.loadSource}'),
        ),
        Container(
          padding: EdgeInsets.all(5.0),
          alignment: Alignment.bottomLeft,
          child: Text('Fecha Carga:${service.loadDate}' +
              '           ' +
              'Fecha Descarga:${service.sourceDate}'),
        ),
        Container(
          padding: EdgeInsets.all(5.0),
          alignment: Alignment.bottomLeft,
          child: Text('Documentador:${service.documentator}'),
        ),
        ButtonBar(
          children: [
            TextButton(
                onPressed: () {
                  print(service.id);
                },
                child: const Text('Ver Detalle Servicio'))
          ],
        ),
      ],
    ),
  );
}
