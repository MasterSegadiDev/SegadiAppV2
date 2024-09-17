import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:segadi/model/services/trip_closure.dart';
import 'package:segadi/view/services/modals/check_list_service.dart';
import 'package:segadi/view/services/modals/status_support.dart';
import 'package:segadi/view/services/travel_expenses.dart';
import 'package:segadi/view/services/trip_closure.dart';
import 'package:segadi/view_model/services_operator/detail_service.dart';
import 'package:segadi/view_model/services_operator/travel_expenses.dart';
import 'package:segadi/view_model/services_operator/trip_closure.dart';

class DetailServiceScreen extends StatefulWidget {
  const DetailServiceScreen({Key? key}) : super(key: key);

  @override
  _DetailServiceScreen createState() => _DetailServiceScreen();
}

class _DetailServiceScreen extends State<DetailServiceScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DetailViewModel>(context);

    // Usar viewModel...
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle Remision',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      backgroundColor: Colors.white,
      body: viewModel.item == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      //height: 530,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF84A756),
                        ),
                        color: const Color(0xFF84A756),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Servicio: ${viewModel.item!.service}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              const Row(children: [
                                Text(
                                  'Remitente',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                )
                              ]),
                              const Divider(
                                height: 15.0,
                                color: Colors.white,
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Razon Social:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    viewModel.item!.senderBusinessName
                                        .toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  )
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Télefono:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    viewModel.item!.senderPhoneNumber
                                        .toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  )
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Contacto:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    viewModel.item!.senderName.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  )
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Domicilio:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${viewModel.item!.senderStreet} ${viewModel.item!.senderOutdoorNumber} ',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${viewModel.item!.senderZipCode}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  )
                                ],
                              ),
                              const Divider(
                                color: Colors.transparent,
                                height: 15.0,
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Destinatario',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                              const Divider(
                                color: Colors.white,
                                height: 15.0,
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Razon Social:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    viewModel.item!.recipientBusinessName
                                        .toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  )
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Télefono:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    viewModel.item!.recipientPhoneNumber
                                        .toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  )
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Contacto:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    viewModel.item!.recipientName.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  )
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Domicilio:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        '${viewModel.item!.recipientStreet} ${viewModel.item!.recipientOutdoorNumber}',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${viewModel.item!.recipientZipCode} ${viewModel.item!.recipientState}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      //height: 100,
                      width: 380,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: checkListF(
                                    viewModel.item!.isEnableCheckList),
                              ),
                              Expanded(
                                child: iconStatus(
                                    viewModel.item!.isEnableStatusSupport,
                                    viewModel.item!.isEnableContinueRute,
                                    viewModel),
                              ),
                              const Expanded(
                                child: Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(
                                        FontAwesomeIcons.mapLocationDot,
                                        color: Colors.grey,
                                      ),
                                      iconSize: 25.5,
                                      onPressed: null,
                                    ),
                                    Text(
                                      'Ruta Sugerida',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: iconTripClosure(
                                    viewModel.item!.serviceClosed,
                                    viewModel.item!.id,
                                    viewModel.item!.service),
                              ),
                              Expanded(
                                child: iconTravelExpenses(
                                    viewModel.item!.pendingMoneyChecks,
                                    viewModel.item!.id!),
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    IconButton(
                                        icon: const Icon(
                                          FontAwesomeIcons.solidFilePdf,
                                          color: Colors.red,
                                        ),
                                        iconSize: 25.5,
                                        onPressed: () => {} // getPdf(id),
                                        ),
                                    const Text(
                                      'Descargar Servicio',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      height: 40,
                      width: 380,
                      child: Column(
                        children: [
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        fixedSize:
                                            const Size(1000, double.infinity)),
                                    onPressed: viewModel.item!.isEnableButton!
                                        ? () async {
                                            await viewModel.changeStatusService(
                                                viewModel
                                                    .item!.mandatoryStatusId!);
                                          }
                                        : null,
                                    child:
                                        Text(viewModel.item!.mandatoryStatus!),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  checkListF(status) {
    if (status == true) {
      return Column(
        children: <Widget>[
          IconButton(
              icon: const Icon(
                FontAwesomeIcons.clipboardList,
                color: Colors.blue,
              ),
              iconSize: 25.5,
              onPressed: () => {
                    print('click en checklist'),
                    _openIconButtonPressed(),
                  } //_dialogCircleCheck((context)),
              ),
          const Text(
            'Check List',
            style: TextStyle(fontSize: 12, color: Colors.black),
          )
        ],
      );
    } else {
      return const Column(
        children: <Widget>[
          IconButton(
            icon: Icon(
              FontAwesomeIcons.clipboardList,
            ),
            iconSize: 25.5,
            onPressed: null,
          ),
          Text(
            'Check List',
            style: TextStyle(fontSize: 12, color: Colors.black),
          )
        ],
      );
    }
  }

  iconStatus(status, buttonStatus, viewModel) {
    if (status == true) {
      return Column(
        children: <Widget>[
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.locationDot,
              color: Colors.red,
            ),
            iconSize: 25.5,
            onPressed: status
                ? () {
                    _openModalStatusSupport();
                  }
                : null,
          ),
           Text(
            'Estatus de Soporte',
            style: TextStyle(fontSize: 12, color: Colors.black),
          )
        ],
      );
    } else {
      return const Column(
        children: <Widget>[
          IconButton(
            icon: Icon(
              FontAwesomeIcons.locationDot,
            ),
            iconSize: 27.5,
            onPressed: null,
          ),
          Text(
            'Estatus de Soporte',
            style: TextStyle(fontSize: 12, color: Colors.black),
          )
        ],
      );
    }
  }

  iconTripClosure(status, id, service) {
    if (status == true) {
      return Column(
        children: <Widget>[
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.circleCheck,
              color: Colors.green,
            ),
            iconSize: 25.5,
            onPressed: status
                ? () {
                    final tripClosure = TripClosure(id: id, serviceId: service);
                    Provider.of<TripClosureViewModel>(context, listen: false)
                        .setNewDetail(tripClosure);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripClosureScreen(),
                      ),
                    );
                  }
                : null,
          ),
          const Text(
            'Cierre de viaje',
            style: TextStyle(fontSize: 12, color: Colors.black),
          )
        ],
      );
    } else {
      return const Column(
        children: <Widget>[
          IconButton(
            icon: Icon(
              FontAwesomeIcons.circleCheck,
            ),
            iconSize: 25.5,
            onPressed: null,
          ),
          Text(
            'Cierre de viaje',
            style: TextStyle(fontSize: 12, color: Colors.black),
          )
        ],
      );
    }
  }

  iconTravelExpenses(status, int id) {
    if (status == true) {
      return Column(
        children: <Widget>[
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.fileInvoiceDollar,
              color: Colors.green,
            ),
            iconSize: 25.5,
            onPressed: status
                ? () {
                    //TripClosure(id: id);
                    Provider.of<TravelExpensesViewModel>(context, listen: false)
                        .setNewDetail(id);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TravelExpensesScreen(),
                      ),
                    );
                  }
                : null,
          ),
          const Text(
            ' Viáticos',
            style: TextStyle(fontSize: 12, color: Colors.black),
          )
        ],
      );
    } else {
      return const Column(
        children: <Widget>[
          IconButton(
            icon: Icon(
              FontAwesomeIcons.fileInvoiceDollar,
            ),
            iconSize: 25.5,
            // onPressed: () => sendTravelExpenses(id),
            onPressed: null,
          ),
          Text(
            ' Viaticos',
            style: TextStyle(fontSize: 12, color: Colors.black),
          )
        ],
      );
    }
  }

  void _openIconButtonPressed() {
    showModalBottomSheet(
      isScrollControlled: false,
      context: context,
      builder: (ctx) => CheckListView(),
    );
  }

  void _openModalStatusSupport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Estatus de soporte'),
          content: StatusSupport(),
        );
      },
    );
  }
}
