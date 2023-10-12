import 'package:flutter/material.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({Key? key}) : super(key: key);

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
                accountName: Text('Brian'),
                accountEmail: Text('segadi@gmail.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.network(
                      'https://oflutter.com/wp-content/uploads/2021/02/girl-profile.png',
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
