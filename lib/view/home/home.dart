import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:segadi/view/home/sidebar.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              onTap: () {
                Navigator.popAndPushNamed(context, '/user');
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
          FlutterPhoneDirectCaller.callNumber('+523311364928');
        },
      ),
    );
  }

}
