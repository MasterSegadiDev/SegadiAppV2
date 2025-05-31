import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:segadi/utils/user_session.dart';
import 'package:segadi/views/home/sidebar.dart';
import 'package:segadi/views/services/services_operator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> filteredMenuItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    final session = UserSession();
    await session.loadFromPrefs();

    final String tipoUsuario = session.userRollApp ?? '';
    //final String tipoUsuario = 'Operador';
    final allItems = [
      {
        'icon': FontAwesomeIcons.truck,
        'label': 'Servicio',
        'onTap': (BuildContext context) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => ServiceListView()));
        },
        'tipo': 'Operador'
      },
      // {
      //   'icon': Icons.folder,
      //   'label': 'Expediente',
      //   'onTap': (BuildContext context) {},
      //   'tipo': 'Operador',
      // },
      // {
      //   'icon': FontAwesomeIcons.tools,
      //   'label': 'Mantenimiento',
      //   'onTap': (BuildContext context) {},
      //   'tipo': 'Operador',
      // },
      {
        'icon': FontAwesomeIcons.box,
        'label': 'Movimiento de contenedores',
        'onTap': (BuildContext context) {
          Navigator.pushNamed(context, '/container_map');
        },
        'tipo': 'Operador Grua'
        //'tipo': 'Operador'
      },
    ];

    setState(() {
      filteredMenuItems =
          allItems.where((item) => item['tipo'] == tipoUsuario).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      backgroundColor: Colors.white,
      drawer: DrawerScreen(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: filteredMenuItems.length,
                    itemBuilder: (context, index) {
                      return MenuItemCard(
                        icon: filteredMenuItems[index]['icon'],
                        label: filteredMenuItems[index]['label'],
                        onTap: () => filteredMenuItems[index]['onTap'](context),
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.phone, color: Colors.white),
        onPressed: () {
          FlutterPhoneDirectCaller.callNumber('+523311364928');
        },
      ),
    );
  }
}

class MenuItemCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuItemCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.95);
  void _onTapUp(_) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Card(
          color: const Color(0xFFDDE8D0), // Verde muy claro
          elevation: 8,
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: Color(0xFF84A756), width: 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            splashColor: Colors.green.withOpacity(0.2),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.green,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
