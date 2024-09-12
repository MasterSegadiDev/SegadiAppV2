import 'package:flutter/material.dart';
import 'package:segadi/model/user/UserInformation.dart';
import 'package:segadi/view/home/home.dart';
import 'package:segadi/view_model/user/user_information.dart';
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
  var username = "";
  late Future<Photo>? detail;

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
    detail = User().getUserPhot();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: 300,
        child: Drawer(
          backgroundColor: const Color(0xFF2C522A),
          //#84A756
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
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
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
                accountEmail: null,
              ),
              ListTile(
                leading: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                title: const Text(
                  'Perfil',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(
                  FontAwesomeIcons.house,
                  color: Colors.white,
                ),
                title: const Text(
                  'Home',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                },
              ),
              ExpansionTile(
                title: const Text(
                  'Servicios',
                  style: TextStyle(color: Colors.white),
                ),
                leading: const Icon(
                  Icons.file_open,
                  color: Colors.white,
                ),
                childrenPadding: const EdgeInsets.only(left: 60),
                children: [
                  ListTile(
                    leading: const Icon(
                      FontAwesomeIcons.file,
                      color: Colors.white,
                    ),
                    title: const Text(
                      "Servicios Asignados",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const ServicesScreen(),
                      //   ),
                      // );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      FontAwesomeIcons.circleCheck,
                      color: Colors.white,
                    ),
                    title: const Text(
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
                leading: const Icon(
                  Icons.folder,
                  color: Colors.white,
                ),
                title: const Text(
                  'Expendiente',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Navigator.pushNamed(context, '/user');
                },
              ),
              const ListTile(
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
              const Divider(),
              ListTile(
                title: const Text(
                  'Salir',
                  style: TextStyle(color: Colors.white),
                ),
                leading: const Icon(
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

  logout(context) async {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
}
