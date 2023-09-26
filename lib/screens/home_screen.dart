import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Menu'),
        backgroundColor: Colors.black,
      ),
      drawer: Drawer(
          child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: 200,
              height: 150,
              margin: const EdgeInsets.only(top: 10, bottom: 0),
              child: Image.network(
                  "https://segadi.com.mx/wp-content/uploads/Logo-Segadi.png"),
            ),
            const Text(
              'Brian Alejandro Castañeda Martinez',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.only(top: 30),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              color: Colors.grey,
              child: const Text(
                'Inicio',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              color: Colors.grey,
              child: const Text('Pefil',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            ExpansionTile(
              title: Text('Servicios'),
              leading: Icon(Icons.file_open),
              childrenPadding: EdgeInsets.only(left: 60),
              children: [
                ListTile(
                  title: Text("Servicios Asignados"),
                  onTap: () {},
                ),
                ListTile(
                  title: Text("Servicios Realizados"),
                  onTap: () {},
                )
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              color: Colors.grey,
              child: const Text('Expedientes',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              color: Colors.grey,
              child: const Text('Mantenimiento',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: Container()),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              color: Colors.black,
              alignment: Alignment.center,
              child: const Text('Cerrar Sesión',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      )),
      body: Center(),
    );
  }
}
