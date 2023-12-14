import 'package:flutter/material.dart';
import 'package:segadi/view/home/sidebar.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MainListHomePage createState() => _MainListHomePage();
}

class _MainListHomePage extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Colors.green,
      ),
      drawer: const DrawerScreen(),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        childAspectRatio: 8.0 / 9.0,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.popAndPushNamed(context, '/services');
            },
            child: const Card(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.truck,
                          color: Colors.green,
                          size: 50.0,
                        ),
                        Text('Servicio',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, height: 4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Card(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.folder,
                          color: Colors.green,
                          size: 50.0,
                        ),
                        Text('Expediente',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, height: 4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Card(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          // ignore: deprecated_member_use
                          FontAwesomeIcons.tools,
                          color: Colors.green,
                          size: 40.0,
                        ),
                        Text('Mantenimiento',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, height: 4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
