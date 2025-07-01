import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:segadi/helper/messages.dart';
import 'package:segadi/models/services/detail_service.dart';
import 'package:segadi/models/services/pdf_service.dart';

import 'package:segadi/utils/user_session.dart';
import 'package:segadi/views/services/modals/check_list_service.dart';
import 'package:segadi/views/services/modals/status_support.dart';
import 'package:segadi/views/services/travel_expenses.dart';
import 'package:segadi/views/services/trip_closure.dart';
import 'package:segadi/viewmodels/services_operator/detail_service.dart';
import 'package:segadi/viewmodels/services_operator/travel_expenses.dart';

class DetailServiceScreen extends StatefulWidget {
  DetailServiceScreen({Key? key}) : super(key: key);

  @override
  _DetailServiceScreen createState() => _DetailServiceScreen();
}

class _DetailServiceScreen extends State<DetailServiceScreen> {
  @override
  Widget build(BuildContext context) {
    final user = UserSession();
    print('Nombre de usuario: ${UserSession().name}');
    print('TIPO DE USUARIO: ${user.userRollApp}');

    final viewModel = Provider.of<DetailViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle Remisión', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF2C522A),
      ),
      backgroundColor: Colors.white,
      body: viewModel.item == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Text(
                      'REMISIÓN NÚMERO: ${viewModel.item!.service}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87),
                    ),
                    SizedBox(height: 10),
                    dataCard(
                      title: 'Remitente',
                      icon: Icons.send,
                      content: [
                        infoRow(Icons.business, 'Razón Social',
                            viewModel.item?.senderBusinessName ?? 'Sin datos'),
                        infoRow(Icons.phone, 'Teléfono',
                            viewModel.item?.senderPhoneNumber ?? 'Sin datos'),
                        infoRow(Icons.person, 'Contacto',
                            viewModel.item?.senderName ?? 'Sin datos'),
                        infoRow(Icons.home, 'Domicilio',
                            '${viewModel.item?.senderStreet ?? ''} ${viewModel.item?.senderOutdoorNumber ?? ''} CP ${viewModel.item?.senderZipCode ?? ''}'),
                      ],
                    ),
                    dataCard(
                      title: 'Destinatario',
                      icon: Icons.location_on,
                      content: [
                        infoRow(
                            Icons.business,
                            'Razón Social',
                            viewModel.item?.recipientBusinessName ??
                                'Sin datos'),
                        infoRow(
                            Icons.phone,
                            'Teléfono',
                            viewModel.item?.recipientPhoneNumber ??
                                'Sin datos'),
                        infoRow(Icons.person, 'Contacto',
                            viewModel.item?.recipientName ?? 'Sin datos'),
                        infoRow(Icons.home, 'Domicilio',
                            '${viewModel.item!.recipientStreet ?? ''} ${viewModel.item!.recipientOutdoorNumber ?? ''}, CP ${viewModel.item!.recipientZipCode ?? ''}, ${viewModel.item!.recipientState ?? ''}'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
                            color: Color(0xFF84A756), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _ActionButton(
                                  icon: FontAwesomeIcons.clipboardList,
                                  label: 'Lista de chequeo',
                                  color: Colors.blue,
                                  enabled: viewModel.item!.isEnableCheckList!,
                                  onPressed: () => showChecklistModal(context),
                                ),
                                _ActionButton(
                                  icon: FontAwesomeIcons.locationDot,
                                  label: 'Estatus de soporte',
                                  color: Colors.red,
                                  enabled:
                                      viewModel.item!.isEnableStatusSupport!,
                                  onPressed: viewModel
                                          .item!.isEnableStatusSupport!
                                      ? () => _openModalStatusSupport(context)
                                      : null,
                                ),
                                _ActionButton(
                                  icon: FontAwesomeIcons.mapLocationDot,
                                  label: 'Ruta Sugerida',
                                  color: Colors.grey,
                                  enabled: false,
                                  onPressed: null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Divider(),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _ActionButton(
                                  icon: FontAwesomeIcons.circleCheck,
                                  label: 'Cierre de viaje',
                                  color: Colors.green,
                                  enabled: viewModel.item!.serviceClosed!,
                                  onPressed: viewModel.item!.serviceClosed!
                                      ? () => handleTripClosure(
                                            context,
                                            viewModel.item!.id!,
                                            viewModel.item!.service.toString(),
                                          )
                                      : null,
                                ),
                                if (user.userRoll == 'No')
                                  _ActionButton(
                                    icon: FontAwesomeIcons.moneyBillTransfer,
                                    label: 'Viáticos',
                                    color: Colors.teal,
                                    enabled:
                                        viewModel.item!.pendingMoneyChecks!,
                                    onPressed:
                                        viewModel.item!.pendingMoneyChecks!
                                            ? () => handleTravelExpenses(
                                                context, viewModel.item!.id!)
                                            : null,
                                  ),
                                _ActionButton(
                                  icon: FontAwesomeIcons.solidFilePdf,
                                  label: 'Descargar CCP',
                                  color: Colors.red,
                                  enabled: true,
                                  onPressed: () => getPdf(
                                    viewModel.item!.id!,
                                    viewModel.item!.service!,
                                    context,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      //height: 40,
                      width: 380,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2C522A),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        // onPressed: viewModel.item!.isEnableButton!
                        //     ? () async {
                        //         final statusId =
                        //             viewModel.item!.mandatoryStatusId;
                        //         if (statusId == null) {
                        //           scaffoldMessengerError(context,
                        //               'No se puede cambiar el estatus');
                        //           return;
                        //         }
                        //         await viewModel.changeStatusService(statusId);
                        //         if (viewModel.errorMessage != null) {
                        //           scaffoldMessengerError(
                        //               context, viewModel.errorMessage!);
                        //         }
                        //       }
                        //     : null,
                        onPressed: viewModel.item!.isEnableButton!
                            ? () async {
                                final statusId =
                                    viewModel.item!.mandatoryStatusId;

                                if (statusId == null) {
                                  scaffoldMessengerError(context,
                                      'No se puede cambiar el estatus porque falta el ID de estatus obligatorio.');
                                  return;
                                }

                                await viewModel.changeStatusService(statusId);

                                if (viewModel.errorMessage != null) {
                                  scaffoldMessengerError(
                                      context, viewModel.errorMessage!);
                                } else {
                                  scaffoldMessengerSuccessStatus(context,
                                      'Estatus actualizado correctamente.');
                                  // También puedes usar showDialog si prefieres
                                }
                              }
                            : null,
                        child: Text(viewModel.item!.mandatoryStatus!,
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.phone, color: Colors.white),
        onPressed: () {
          FlutterPhoneDirectCaller.callNumber('+523311364928');
        },
      ),
    );
  }

  Widget infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                      text: '$label: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dataCard(
      {required String title,
      required IconData icon,
      required List<Widget> content}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF84A756), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green),
                SizedBox(width: 8),
                Text(title,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(),
            ...content,
          ],
        ),
      ),
    );
  }

  void showChecklistModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => CheckListView(),
    );
  }

  void _openModalStatusSupport(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatusSupport(),
        );
      },
    );
  }

  void handleTripClosure(BuildContext context, int id, String serviceId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripClosureScreen(id: id, serviceId: serviceId),
      ),
    );
    if (result == true) {
      // Aquí actualizas el ViewModel del detalle
      final detailServiceModel = DetailService(id: id);
      Provider.of<DetailViewModel>(context, listen: false)
          .setNewDetail(detailServiceModel);
    }
  }

  void handleTravelExpenses(BuildContext context, int id) {
    Provider.of<TravelExpensesViewModel>(context, listen: false)
        .setNewDetail(id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TravelExpensesScreen()),
    );
  }

  void getPdf(int id, String serviceId, BuildContext context) async {
    var res = await PdfService().getPdf(id);
    if (res == null) {
      scaffoldMessengerError(context,
          'La remisión: $serviceId aun no cuenta con un CFDI timbrado');
    } else {
      FileDownloader.downloadFile(
        url: res["url"],
        name: "CFDI Remision: $serviceId",
        notificationType: NotificationType.all,
      );
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback? onPressed;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = enabled ? color : Colors.grey.shade400;
    final textColor = enabled ? Colors.black : Colors.grey;

    return Expanded(
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: textColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
