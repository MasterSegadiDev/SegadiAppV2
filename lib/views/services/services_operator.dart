import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
//import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:segadi/models/services/detail_service.dart';

import 'package:segadi/views/home/sidebar.dart';
import 'package:segadi/views/services/detail_service.dart';
import 'package:segadi/viewmodels/services_operator/assigned_services.dart';
import 'package:segadi/viewmodels/services_operator/detail_service.dart';

class ServiceListView extends StatelessWidget {
  ServiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceViewModel = Provider.of<ServicesViewModel>(context);

    Future _handleRefresh() async {
      serviceViewModel.items.clear();
      await serviceViewModel.fetchItems();
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Remisiones Asignadas',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xFF2C522A)),
      backgroundColor: Colors.white,
      drawer: DrawerScreen(),
      body: Consumer<ServicesViewModel>(
        builder: (context, serviceViewModel, child) {
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: serviceViewModel.items.length,
              itemBuilder: (context, index) {
                final item = serviceViewModel.items[index];

                return GestureDetector(
                  onTap: () {
                    final detailServiceModel = DetailService(id: item.id);
                    Provider.of<DetailViewModel>(context, listen: false)
                        .setNewDetail(detailServiceModel);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailServiceScreen(),
                      ),
                    );
                  },
                  child: Card(
                    color: Color(0xFF84A756),
                    //borderOnForeground: true,
                    elevation: 10,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        ListTile(
                          title: AutoSizeText(
                            'REMISIÓN NÚMERO:  ${item.service}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            minFontSize: 14,
                            maxFontSize: 17,
                          ),
                          leading: Icon(
                            FontAwesomeIcons.truck,
                            color: Colors.white,
                          ),
                          subtitle: AutoSizeText(
                            'CLIENTE: ${item.client}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Row(
                            children: [
                              AutoSizeText(
                                'ORIGEN DE CARGA',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                minFontSize: 14,
                                maxFontSize: 17,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, bottom: 2.0),
                          child: Row(
                            children: [
                              const AutoSizeText(
                                'Origen:  ',
                                style: TextStyle(color: Colors.white),
                                minFontSize: 13,
                                maxFontSize: 16,
                              ),
                              AutoSizeText(
                                item.origin!,
                                style: const TextStyle(color: Colors.white),
                                minFontSize: 13,
                                maxFontSize: 16,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, bottom: 2.0),
                          child: Row(
                            children: [
                              const AutoSizeText(
                                'Fecha: ',
                                style: TextStyle(color: Colors.white),
                                minFontSize: 13,
                                maxFontSize: 16,
                              ),
                              AutoSizeText(
                                item.loadDate!,
                                style: const TextStyle(color: Colors.white),
                                minFontSize: 13,
                                maxFontSize: 16,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, top: 8.0),
                          child: Row(
                            children: [
                              AutoSizeText(
                                'DESTINO DE CARGA',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                minFontSize: 14,
                                maxFontSize: 17,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, bottom: 2.0),
                          child: Row(
                            children: [
                              const AutoSizeText(
                                'Destino:  ',
                                style: TextStyle(color: Colors.white),
                                minFontSize: 13,
                                maxFontSize: 16,
                              ),
                              AutoSizeText(
                                item.destination!,
                                style: const TextStyle(color: Colors.white),
                                minFontSize: 13,
                                maxFontSize: 16,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, bottom: 2.0),
                          child: Row(
                            children: [
                              const AutoSizeText(
                                'Fecha: ',
                                style: TextStyle(color: Colors.white),
                                minFontSize: 13,
                                maxFontSize: 16,
                              ),
                              AutoSizeText(
                                item.unloadDate!,
                                style: const TextStyle(color: Colors.white),
                                minFontSize: 13,
                                maxFontSize: 16,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
                          child: Row(
                            children: [
                              AutoSizeText(
                                'DOCUMENTADOR:  ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                minFontSize: 13,
                                maxFontSize: 16,
                              ),
                              AutoSizeText(
                                '${item.documenter!}',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                minFontSize: 13,
                                maxFontSize: 16,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 16.0, right: 16, top: 8, bottom: 8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              //elevation: 0.0,
                              backgroundColor: Colors.white,
                              side: BorderSide.none,
                              fixedSize: Size(1000, double.infinity),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
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
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
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
