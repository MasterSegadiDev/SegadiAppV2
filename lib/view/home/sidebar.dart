import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
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
                decoration: const BoxDecoration(
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
                leading: const Icon(Icons.person),
                title: const Text('Perfil'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.house),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pushNamed(context, '/home_page');
                },
              ),
              ExpansionTile(
                title: const Text('Servicios'),
                leading: const Icon(Icons.file_open),
                childrenPadding: const EdgeInsets.only(left: 60),
                children: [
                  ListTile(
                    title: const Text("Servicios Asignados"),
                    onTap: () {
                      Navigator.pushNamed(context, '/services');
                    },
                  ),
                  ListTile(
                    title: const Text("Servicios Realizados"),
                    onTap: () {
                      Navigator.pushNamed(context, '/services_finished');
                    },
                  )
                ],
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Expendiente'),
                onTap: () {},
              ),
              const ListTile(
                leading: Icon(FontAwesomeIcons.tools),
                title: Text('Mantenimiento'),
              ),
              const Divider(),
              ListTile(
                title: const Text('Salir'),
                leading: const Icon(Icons.exit_to_app),
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
