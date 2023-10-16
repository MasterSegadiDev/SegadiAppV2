import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key? key}) : super(key: key);
  _DrawerScreen createState() => _DrawerScreen();
}

class _DrawerScreen extends State<DrawerScreen> {
  var name = "";
  var email = "";
  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      email = prefs.getString('email') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: 280,
        child: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                accountName: Text(name),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.network(
                      'http://198.251.68.42/DesarrolloSEGADI/web/uploads/FotoPlantilla.jpeg',
                      fit: BoxFit.cover,
                      width: 90,
                      height: 90,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Perfil'),
                onTap: () => null,
              ),
              ExpansionTile(
                title: Text('Servicios'),
                leading: Icon(Icons.file_open),
                childrenPadding: EdgeInsets.only(left: 60),
                children: [
                  ListTile(
                    title: Text("Servicios Asignados"),
                    onTap: () {
                      Navigator.pushNamed(context, '/services');
                    },
                  ),
                  ListTile(
                    title: Text("Servicios Realizados"),
                    onTap: () {
                      Navigator.pushNamed(context, '/services_finished');
                    },
                  )
                ],
              ),
              ListTile(
                leading: Icon(Icons.folder),
                title: Text('Expendiente'),
                onTap: () => null,
              ),
              ListTile(
                leading: Icon(Icons.train),
                title: Text('Mantenimiento'),
              ),
              Divider(),
              ListTile(
                title: Text('Salir'),
                leading: Icon(Icons.exit_to_app),
                onTap: () {
                  Navigator.pushNamed(context, '/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
