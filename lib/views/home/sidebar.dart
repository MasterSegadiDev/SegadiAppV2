import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/services_assigned/presentation/pages/service_list_page.dart';
import 'package:segadi/models/user/UserInformation.dart';
import 'package:segadi/viewmodels/login/user_login.dart';
import 'package:segadi/views/home/routes.dart';
import 'package:segadi/viewmodels/user/user_information.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrawerScreen extends StatefulWidget {
  DrawerScreen({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _DrawerScreen createState() => _DrawerScreen();
}

class _DrawerScreen extends State<DrawerScreen> {
  var name = "";
  var username = "";
  Future<Photo>? detail;

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      username = prefs.getString('username') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();

    detail = context.read<User>().getUserPhot();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: 300,
        child: Drawer(
          backgroundColor: Color(0xFF2C522A),
          //#84A756
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF2C522A),
                ),
                accountName: Text(name),
                // accountName: Text(username),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: FutureBuilder<Photo>(
                    future: detail,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ClipOval(
                          child: Image.network(
                            snapshot.data!.url.toString(),
                            fit: BoxFit.cover,
                            width: 90,
                            height: 90,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return ClipOval(
                          child: Image.asset(
                            "assets/images/user_not_found.png",
                            fit: BoxFit.cover,
                            width: 90,
                            height: 90,
                          ),
                        );
                      }
                      return CircularProgressIndicator();
                    },
                  ),
                ),
                accountEmail: null,
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                title: Text(
                  'Perfil',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.house,
                  color: Colors.white,
                ),
                title: Text(
                  'Home',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                  );
                },
              ),
              ExpansionTile(
                title: Text(
                  'Servicios',
                  style: TextStyle(color: Colors.white),
                ),
                leading: Icon(
                  Icons.file_open,
                  color: Colors.white,
                ),
                childrenPadding: EdgeInsets.only(left: 60),
                children: [
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.file,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Servicios Asignados",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ServicesAssignedPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.circleCheck,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Servicios Realizados",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/services_finished');
                    },
                  )
                ],
              ),
              ListTile(
                leading: Icon(
                  Icons.folder,
                  color: Colors.white,
                ),
                title: Text(
                  'Expendiente',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(
                  // ignore: deprecated_member_use
                  FontAwesomeIcons.tools,
                  color: Colors.white,
                ),
                title: Text(
                  'Mantenimiento',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Salir',
                  style: TextStyle(color: Colors.white),
                ),
                leading: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
                onTap: () {
                  logout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await context.read<LoginViewModel>().removeAllPrefs();
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
}
