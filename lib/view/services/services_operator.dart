import 'package:flutter/material.dart';
//import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:segadi/model/services/detail_service.dart';

import 'package:segadi/view/home/sidebar.dart';
import 'package:segadi/view/services/detail_service.dart';
import 'package:segadi/view_model/services_operator/assigned_services.dart';
import 'package:segadi/view_model/services_operator/detail_service.dart';

class ServiceListView extends StatelessWidget {
  const ServiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceViewModel = Provider.of<ServicesViewModel>(context);

    Future _handleRefresh() async {
      serviceViewModel.items.clear();
      await serviceViewModel.fetchItems();
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Remisiones Asignadas',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color(0xFF2C522A)),
      backgroundColor: Colors.white,
      drawer: const DrawerScreen(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: serviceViewModel.items.length,
          itemBuilder: (context, index) {
            final item = serviceViewModel.items[index];

            return GestureDetector(
              onTap: () {
                final detailServiceModel = DetailService(id: item.id);
                Provider.of<DetailViewModel>(context, listen: false)
                    .setUser(detailServiceModel);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetailServiceScreen(),
                  ),
                );
              },
              child: Card(
                color: const Color(0xFF84A756),
                borderOnForeground: true,
                elevation: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ListTile(
                      title: Text('Remision No:  ${item.service}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      leading: const Icon(
                        FontAwesomeIcons.truck,
                        color: Colors.white,
                        size: 20,
                      ),
                      subtitle: Text(
                        "Cliente: ${item.client}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 8.0,
                          backgroundColor: Colors.white,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        onPressed: null,
                        child: Text(
                          item.status!,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.white),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          '   Carga Origen :  ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          item.origin,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          '   Fecha Carga :  ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          item.loadDate,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.transparent,
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        const Text(
                          '   Carga Destino :  ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          item.destination,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          '   Fecha Descarga :  ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          item.unloadDate,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.transparent,
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        const Text(
                          '   Documentador :  ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          item.documenter,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.transparent,
                      height: 10.0,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  //FutureBuilder(
  //  future: serviceViewModel.fetchItems(),
  //  builder: (context, snapshot) {

  //      return ListView.builder(
  //       padding: const EdgeInsets.all(10),
  //       itemCount: serviceViewModel.items.length,
  //       itemBuilder: (context, index) {
  //         final item = serviceViewModel.items[index];
  //         return GestureDetector(
  //           onTap: () {
  //             sendScreenWidget(item.id);
  //           },
  //           child: Card(
  //             color: const Color(0xFF84A756),
  //             borderOnForeground: true,
  //             elevation: 10,
  //             child: Column(
  //               mainAxisSize: MainAxisSize.max,
  //               children: <Widget>[
  //                 ListTile(
  //                   title: Text('Remision No:  ${item.service}',
  //                       style: const TextStyle(
  //                           color: Colors.white,
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 14)),
  //                   leading: const Icon(
  //                     FontAwesomeIcons.truck,
  //                     color: Colors.white,
  //                     size: 20,
  //                   ),
  //                   subtitle: Text(
  //                     "Cliente: ${item.client}",
  //                     style: const TextStyle(color: Colors.white),
  //                   ),
  //                   trailing: ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                       elevation: 8.0,
  //                       backgroundColor: Colors.white,
  //                       side: BorderSide.none,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(25.0),
  //                       ),
  //                     ),
  //                     onPressed: null,
  //                     child: Text(
  //                       item.status!,
  //                       style: const TextStyle(
  //                           fontSize: 13, color: Colors.white),
  //                     ),
  //                   ),
  //                 ),
  //                 Row(
  //                   children: [
  //                     const Text(
  //                       '   Carga Origen :  ',
  //                       style: TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.white),
  //                     ),
  //                     Text(
  //                       item.origin,
  //                       style: const TextStyle(
  //                           fontSize: 14, color: Colors.white),
  //                     ),
  //                   ],
  //                 ),
  //                 Row(
  //                   children: [
  //                     const Text(
  //                       '   Fecha Carga :  ',
  //                       style: TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.white),
  //                     ),
  //                     Text(
  //                       item.loadDate,
  //                       style: const TextStyle(
  //                           fontSize: 14, color: Colors.white),
  //                     ),
  //                   ],
  //                 ),
  //                 const Divider(
  //                   color: Colors.transparent,
  //                   height: 10.0,
  //                 ),
  //                 Row(
  //                   children: [
  //                     const Text(
  //                       '   Carga Destino :  ',
  //                       style: TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.white),
  //                     ),
  //                     Text(
  //                       item.destination,
  //                       style: const TextStyle(
  //                           fontSize: 14, color: Colors.white),
  //                     ),
  //                   ],
  //                 ),
  //                 Row(
  //                   children: [
  //                     const Text(
  //                       '   Fecha Descarga :  ',
  //                       style: TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.white),
  //                     ),
  //                     Text(
  //                       item.unloadDate,
  //                       style: const TextStyle(
  //                           fontSize: 14, color: Colors.white),
  //                     ),
  //                   ],
  //                 ),
  //                 const Divider(
  //                   color: Colors.transparent,
  //                   height: 10.0,
  //                 ),
  //                 Row(
  //                   children: [
  //                     const Text(
  //                       '   Documentador :  ',
  //                       style: TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.white),
  //                     ),
  //                     Text(
  //                       item.documenter,
  //                       style: const TextStyle(
  //                           fontSize: 14, color: Colors.white),
  //                     ),
  //                   ],
  //                 ),
  //                 const Divider(
  //                   color: Colors.transparent,
  //                   height: 10.0,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   },
  // ),

  //);
  //  }
}
