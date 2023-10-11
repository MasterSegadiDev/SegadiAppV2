import 'package:flutter/material.dart';
import 'package:segadi/screens/home/sidebar.dart';

class DetailServicesScreen extends StatelessWidget {
  const DetailServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Material es una hoja de papel conceptual en la que aparece la UI.
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle Servicio'),
        backgroundColor: Colors.green,
      ),
      drawer: const DrawerScreen(),
      //  body: new ListView(children: services.map(_buildItem).toList()));
    );
  }
}
