import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/services_assigned/presentation/pages/service_list_page.dart';
import 'package:segadi/features/services_finished/presentation/views/finish_service_list.dart';
import 'package:segadi/models/user/UserInformation.dart';
import 'package:segadi/viewmodels/login/user_login.dart';
import 'package:segadi/views/home/routes.dart';
import 'package:segadi/viewmodels/user/user_information.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key? key}) : super(key: key);
  @override
  _DrawerScreen createState() => _DrawerScreen();
}

class _DrawerScreen extends State<DrawerScreen> {
  var name = "";
  var username = "";
  Future<Photo>? detail;

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Usuario';
      username = prefs.getString('username') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    // Tu lógica original de carga de foto
    detail = context.read<User>().getUserPhot();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white, // Fondo blanco profesional
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(), // Encabezado verde con datos de usuario
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: FontAwesomeIcons.house,
                      title: 'Inicio',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Perfil',
                      onTap: () {
                        Navigator.pop(context);
                        // Navegación a perfil si existe
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(color: Colors.black12, height: 30),
                    ),
                    _buildExpansionServices(), // Sección de Servicios corregida
                    _buildMenuItem(
                      icon: Icons.folder_open_outlined,
                      title: 'Expediente',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildMenuItem(
                      icon: FontAwesomeIcons.screwdriverWrench,
                      title: 'Mantenimiento',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildLogoutButton(), // Botón de salir al final
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF2C522A),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
                color: Colors.white24, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white,
              child: FutureBuilder<Photo>(
                future: detail,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ClipOval(
                      child: Image.network(
                        snapshot.data!.url.toString(),
                        fit: BoxFit.cover,
                        width: 76,
                        height: 76,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return ClipOval(
                      child: Image.asset(
                        "assets/images/user_not_found.png",
                        fit: BoxFit.cover,
                        width: 76,
                        height: 76,
                      ),
                    );
                  }
                  return const CircularProgressIndicator(
                    color: Color(0xFF2C522A),
                    strokeWidth: 2,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            username,
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2C522A), size: 20),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF333333),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildExpansionServices() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: const Icon(Icons.file_copy_outlined,
            color: Color(0xFF2C522A), size: 22),
        title: const Text(
          "Servicios",
          style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 15,
              fontWeight: FontWeight.w500),
        ),
        iconColor: const Color(0xFF2C522A),
        childrenPadding: const EdgeInsets.only(left: 15),
        children: [
          _buildMenuItem(
            icon: FontAwesomeIcons.fileSignature,
            title: "Servicios Asignados",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ServicesAssignedPage()),
              );
            },
          ),
          _buildMenuItem(
            icon: FontAwesomeIcons.circleCheck,
            title: "Servicios Realizados",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FinishServiceList()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      child: InkWell(
        onTap: () => logout(context),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 10),
              Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
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
