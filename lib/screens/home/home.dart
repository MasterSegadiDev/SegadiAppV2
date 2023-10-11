import 'package:flutter/material.dart';
import 'package:segadi/screens/home/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _MainListHomePage createState() => _MainListHomePage();
}

class _MainListHomePage extends State<HomeScreen> {
  String _username = "";
  String _password = "";
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ??
          'No hay un usuario en shared preferences';
      _password =
          prefs.getString('password') ?? 'No hay un password del usuario';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
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
            child: Card(
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
            onTap: () => null,
            child: Card(
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
            onTap: () => null,
            child: Card(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
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
