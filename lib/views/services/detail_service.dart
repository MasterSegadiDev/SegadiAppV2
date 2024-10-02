import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:segadi/helper/messages.dart';
import 'package:segadi/models/services/pdf_service.dart';

import 'package:segadi/models/services/trip_closure.dart';
import 'package:segadi/views/services/modals/check_list_service.dart';
import 'package:segadi/views/services/modals/status_support.dart';
import 'package:segadi/views/services/travel_expenses.dart';
import 'package:segadi/views/services/trip_closure.dart';
import 'package:segadi/viewmodels/services_operator/detail_service.dart';
import 'package:segadi/viewmodels/services_operator/travel_expenses.dart';
import 'package:segadi/viewmodels/services_operator/trip_closure.dart';

class DetailServiceScreen extends StatefulWidget {
  DetailServiceScreen({Key? key}) : super(key: key);

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
        title: Text(
          'Detalle Remisión',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF2C522A),
      ),
      backgroundColor: Colors.white,
      body: viewModel.item == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                      //height: 530,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF84A756),
                        ),
                        color: Color(0xFF84A756),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: AutoSizeText(
                                  'REMISIÓN NÚMERO: ${viewModel.item!.service}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  minFontSize: 14,
                                  maxFontSize: 17,
                                ),
                              ),
                              Row(children: [
                                AutoSizeText(
                                  'REMITENTE',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  minFontSize: 14,
                                  maxFontSize: 17,
                                )
                              ]),
                              Divider(
                                height: 15.0,
                                color: Colors.white,
                              ),
                              Row(
                                children: [
                                  AutoSizeText(
                                    'Razon Social:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    minFontSize: 13,
                                    maxFontSize: 16,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  AutoSizeText(
                                    viewModel.item!.senderBusinessName
                                        .toString(),
                                    style: TextStyle(color: Colors.white),
                                    minFontSize: 13,
                                    maxFontSize: 16,
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  AutoSizeText(
                                    'Télefono:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    minFontSize: 13,
                                    maxFontSize: 16,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  AutoSizeText(
                                    viewModel.item!.senderPhoneNumber
                                        .toString(),
                                    style: TextStyle(color: Colors.white),
                                    minFontSize: 13,
                                    maxFontSize: 16,
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  AutoSizeText(
                                    'Contacto:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    minFontSize: 13,
                                    maxFontSize: 16,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  AutoSizeText(
                                    viewModel.item!.senderName.toString(),
                                    style: TextStyle(color: Colors.white),
                                    minFontSize: 13,
                                    maxFontSize: 16,
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Domicilio:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 350,
                                    child: AutoSizeText(
                                      '${viewModel.item!.senderStreet} ${viewModel.item!.senderOutdoorNumber} ${viewModel.item!.senderZipCode}',
                                      style: TextStyle(color: Colors.white),
                                      minFontSize: 13,
                                      maxFontSize: 16,
                                      maxLines: 3,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.transparent,
                                height: 15.0,
                              ),
                              Row(
                                children: [
                                  AutoSizeText(
                                    'DESTINATARIO',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    minFontSize: 14,
                                    maxFontSize: 17,
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.white,
                                height: 15.0,
                              ),
                              Row(
                                children: [
                                  AutoSizeText(
                                    'Razon Social:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    minFontSize: 13,
                                    maxFontSize: 16,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    viewModel.item!.recipientBusinessName
                                        .toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  AutoSizeText(
                                    'Télefono:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    minFontSize: 13,
                                    maxFontSize: 16,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    viewModel.item!.recipientPhoneNumber
                                        .toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  AutoSizeText(
                                    'Contacto:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    minFontSize: 13,
                                    maxFontSize: 16,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  AutoSizeText(
                                    viewModel.item!.recipientName.toString(),
                                    style: TextStyle(color: Colors.white),
                                    minFontSize: 13,
                                    maxFontSize: 16,
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  AutoSizeText(
                                    'Domicilio:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    minFontSize: 13,
                                    maxFontSize: 16,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 350,
                                    child: AutoSizeText(
                                      '${viewModel.item!.recipientStreet} ${viewModel.item!.recipientOutdoorNumber} ${viewModel.item!.recipientZipCode} ${viewModel.item!.recipientState}',
                                      style: TextStyle(color: Colors.white),
                                      minFontSize: 13,
                                      maxFontSize: 16,
                                      maxLines: 3,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                      width: double.infinity,
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
                                child: iatus(
                                    viewModel.item!.isEnableStatusSupport,
                                    viewModel.item!.isEnableContinueRute,
                                    viewModel),
                              ),
                              Expanded(
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
                                      icon: Icon(
                                        FontAwesomeIcons.solidFilePdf,
                                        color: Colors.red,
                                      ),
                                      iconSize: 25.5,
                                      onPressed: () => getPdf(
                                          viewModel.detail.id!,
                                          viewModel.item!.service!),
                                    ),
                                    Text(
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
                    padding: EdgeInsets.all(10.0),
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
                                        backgroundColor: Color(0xFF2C522A),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        fixedSize: Size(1000, double.infinity)),
                                    onPressed: viewModel.item!.isEnableButton!
                                        ? () async {
                                            await viewModel.changeStatusService(
                                                viewModel
                                                    .item!.mandatoryStatusId!);
                                            if (viewModel.errorMessage !=
                                                null) {
                                              if (viewModel.errorMessage !=
                                                  null) {
                                                scaffoldMessengerError(context,
                                                    viewModel.errorMessage!);
                                              }
                                            }
                                          }
                                        : null,
                                    child: Text(
                                      viewModel.item!.mandatoryStatus!,
                                      style: TextStyle(color: Colors.white),
                                    ),
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

  checkListF(status) {
    if (status == true) {
      return Column(
        children: <Widget>[
          IconButton(
              icon: Icon(
                FontAwesomeIcons.clipboardList,
                color: Colors.blue,
              ),
              iconSize: 25.5,
              onPressed: () => {
                    _openIconButtonPressed(),
                  } //_dialogCircleCheck((context)),
              ),
          Text(
            'Check List',
            style: TextStyle(fontSize: 12, color: Colors.black),
          )
        ],
      );
    } else {
      return Column(
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

  iatus(status, buttonStatus, viewModel) {
    if (status == true) {
      return Column(
        children: <Widget>[
          IconButton(
            icon: Icon(
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
      return Column(
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
            icon: Icon(
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
          Text(
            'Cierre de viaje',
            style: TextStyle(fontSize: 12, color: Colors.black),
          )
        ],
      );
    } else {
      return Column(
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
            icon: Icon(
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
          Text(
            ' Viáticos',
            style: TextStyle(fontSize: 12, color: Colors.black),
          )
        ],
      );
    } else {
      return Column(
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

  getPdf(int id, String serviceId) async {
  
    var res = await PdfService().getPdf(id);

    if (res == null) {
      scaffoldMessengerError(context,
          'La remisión: ${serviceId} aun no cuenta con un CFDI timbrado');
    } else {
      String rest = res["url"];

      String name = "CFDI Remision: ${serviceId}";
      FileDownloader.downloadFile(
        url: rest,
        name: name,
        notificationType: NotificationType.all,
      );
    }
  }
}
