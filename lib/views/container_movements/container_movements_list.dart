import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:segadi/views/home/sidebar.dart';

class ContainerMovementsListView extends StatelessWidget {
  ContainerMovementsListView({super.key});

  @override
  Widget build(BuildContext context) {
    //final serviceViewModel = Provider.of<ServicesViewModel>(context);

    // Future _handleRefresh() async {
    //   serviceViewModel.items.clear();
    //   await serviceViewModel.fetchItems();
    // }

    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Movimientos Asignados',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xFF2C522A)),
      backgroundColor: Colors.white,
      drawer: DrawerScreen(),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(
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
