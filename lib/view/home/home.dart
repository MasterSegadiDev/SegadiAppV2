import 'package:flutter/material.dart';
import 'package:segadi/view/home/sidebar.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MainListHomePage createState() => _MainListHomePage();
}

class _MainListHomePage extends State<HomeScreen> {
  var name = "";
  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      var name = prefs.getString('name') ?? '';
      var email = prefs.getString('email') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      backgroundColor: Colors.white,
      drawer: const DrawerScreen(),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(10.0),
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.popAndPushNamed(context, '/services');
              },
              child: const Card(
                color: Color(0xFF84A756),
                shadowColor: Colors.transparent,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.truck,
                            color: Colors.white,
                            size: 50.0,
                          ),
                          Text('Servicio',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  height: 4,
                                  color: Colors.white)),
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
                color: Color(0xFF84A756),
                shadowColor: Colors.transparent,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.folder,
                            color: Colors.white,
                            size: 50.0,
                          ),
                          Text('Expediente',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  height: 4,
                                  color: Colors.white)),
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
                color: Color(0xFF84A756),
                shadowColor: Colors.transparent,
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
                            color: Colors.white,
                            size: 40.0,
                          ),
                          Text('Mantenimiento',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  height: 4,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(
          Icons.phone,
          color: Colors.white,
        ),
        onPressed: () {
          // FlutterPhoneDirectCaller.callNumber('+523311364928');
        },
      ),
    );
  }
}
