// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_file_downloader/flutter_file_downloader.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
// import 'package:segadi/helper/messages.dart';
// import 'package:segadi/models/services/detail_service.dart';
// import 'package:segadi/models/services/pdf_service.dart';
// import 'package:segadi/viewmodels/services_operator/assigned_services.dart';
// import 'package:segadi/viewmodels/services_operator/travel_expenses.dart';

// import 'package:segadi/utils/user_session.dart';
// import 'package:segadi/viewmodels/services_operator/detail_service.dart';
// import 'package:segadi/views/services/modals/check_list_service.dart';
// import 'package:segadi/views/services/modals/status_support.dart';
// import 'package:segadi/views/services/travel_expenses.dart';

// class DetailServiceScreen extends StatefulWidget {
//   const DetailServiceScreen({Key? key}) : super(key: key);

//   @override
//   _DetailServiceScreenState createState() => _DetailServiceScreenState();
// }

// class _DetailServiceScreenState extends State<DetailServiceScreen>
//     with WidgetsBindingObserver {
//   Timer? _refreshTimer;

//   @override
//   void initState() {
//     super.initState();

//     // Se ejecuta después del primer frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _checkAndRedirect();
//     });

//     // Refrescar cada 5 minutos
//     _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
//       _checkAndRedirect();
//     });
//   }

//   Future<void> _checkAndRedirect() async {
//     final vm = context.read<DetailViewModelOld>();
//     await vm.updateDetail();

//     // Mientras statusId sea 10 → redirigir
//     while (vm.item?.mandatoryStatusId == 10 && mounted) {
//       await Future.delayed(const Duration(milliseconds: 200));

//       final result = await Navigator.pushNamed(
//         context,
//         '/send_evidence',
//         arguments: {
//           'id': vm.item!.id!,
//           'serviceId': vm.item!.service!.toString(),
//         },
//       );

//       // Al volver, refrescar detalle
//       await vm.updateDetail();
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _refreshTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       final vm = context.read<DetailViewModelOld>();
//       vm.updateDetail().then((_) {
//         if (vm.item?.mandatoryStatusId == 10) {
//           Navigator.popAndPushNamed(context, '/send_evidence', arguments: {
//             'id': vm.item!.id!,
//             'serviceId': vm.item!.service!.toString(),
//           });
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = context.watch<DetailViewModelOld>();
//     //print('ESTATUS ID ${viewModel.item?.mandatoryStatusId}');
//     final user = UserSession();

//     if (viewModel.item == null) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Detalle Remisión',
//             style: TextStyle(color: Colors.white)),
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xFF2C522A),
//       ),
//       backgroundColor: Colors.white,
//       body: DetailServiceContent(
//         serviceDetail: viewModel.item!,
//         userSession: user,
//         onRefresh: viewModel.updateDetail,
//         onChangeStatus: viewModel.changeStatusService,
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.red,
//         child: const Icon(Icons.phone, color: Colors.white),
//         onPressed: () => FlutterPhoneDirectCaller.callNumber('+523311364928'),
//       ),
//     );
//   }
// }

// class DetailServiceContent extends StatelessWidget {
//   final DetailService serviceDetail;
//   final UserSession userSession;
//   final Future<void> Function(int statusId) onChangeStatus;
//   final VoidCallback onRefresh;

//   const DetailServiceContent({
//     Key? key,
//     required this.serviceDetail,
//     required this.userSession,
//     required this.onChangeStatus,
//     required this.onRefresh,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(10),
//       child: Column(
//         children: [
//           Text(
//             'REMISIÓN NÚMERO: ${serviceDetail.service}',
//             style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: Colors.black87),
//           ),
//           SenderInfoCard(serviceDetail: serviceDetail),
//           RecipientInfoCard(serviceDetail: serviceDetail),
//           const SizedBox(height: 10),
//           ActionsCard(
//               serviceDetail: serviceDetail,
//               userSession: userSession,
//               onRefresh: onRefresh),
//           const SizedBox(height: 15),
//           StatusButton(
//             serviceDetail: serviceDetail,
//             onChangeStatus: onChangeStatus,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class SenderInfoCard extends StatelessWidget {
//   final DetailService serviceDetail;
//   const SenderInfoCard({Key? key, required this.serviceDetail})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return _InfoCard(
//       title: 'Remitente',
//       icon: Icons.send,
//       children: [
//         _InfoRow(
//             icon: Icons.business,
//             label: 'Razón Social',
//             value: serviceDetail.senderBusinessName ?? 'Sin datos'),
//         _InfoRow(
//             icon: Icons.phone,
//             label: 'Teléfono',
//             value: serviceDetail.senderPhoneNumber ?? 'Sin datos'),
//         _InfoRow(
//             icon: Icons.person,
//             label: 'Contacto',
//             value: serviceDetail.senderName ?? 'Sin datos'),
//         _InfoRow(
//           icon: Icons.home,
//           label: 'Domicilio',
//           value:
//               '${serviceDetail.senderStreet ?? ''} ${serviceDetail.senderOutdoorNumber ?? ''} CP ${serviceDetail.senderZipCode ?? ''}',
//         ),
//       ],
//     );
//   }
// }

// class RecipientInfoCard extends StatelessWidget {
//   final DetailService serviceDetail;
//   const RecipientInfoCard({Key? key, required this.serviceDetail})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return _InfoCard(
//       title: 'Destinatario',
//       icon: Icons.location_on,
//       children: [
//         _InfoRow(
//             icon: Icons.business,
//             label: 'Razón Social',
//             value: serviceDetail.recipientBusinessName ?? 'Sin datos'),
//         _InfoRow(
//             icon: Icons.phone,
//             label: 'Teléfono',
//             value: serviceDetail.recipientPhoneNumber ?? 'Sin datos'),
//         _InfoRow(
//             icon: Icons.person,
//             label: 'Contacto',
//             value: serviceDetail.recipientName ?? 'Sin datos'),
//         _InfoRow(
//           icon: Icons.home,
//           label: 'Domicilio',
//           value:
//               '${serviceDetail.recipientStreet ?? ''} ${serviceDetail.recipientOutdoorNumber ?? ''}, CP ${serviceDetail.recipientZipCode ?? ''}, ${serviceDetail.recipientState ?? ''}',
//         ),
//       ],
//     );
//   }
// }

// class ActionsCard extends StatelessWidget {
//   final DetailService serviceDetail;
//   final UserSession userSession;
//   final VoidCallback onRefresh;

//   const ActionsCard({
//     Key? key,
//     required this.serviceDetail,
//     required this.userSession,
//     required this.onRefresh,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final enabledCheckList = serviceDetail.isEnableCheckList ?? false;
//     final enabledStatusSupport = serviceDetail.isEnableStatusSupport ?? false;
//     final serviceClosed = serviceDetail.serviceClosed ?? false;
//     final pendingMoneyChecks = serviceDetail.pendingMoneyChecks ?? false;

//     return Card(
//       elevation: 8,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//         side: const BorderSide(color: Color(0xFF84A756), width: 1),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//         child: Column(
//           children: [
//             // Primera fila de acciones
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ActionButton(
//                   icon: FontAwesomeIcons.clipboardList,
//                   label: 'Lista de chequeo',
//                   color: Colors.blue,
//                   enabled: enabledCheckList,
//                   onPressed: enabledCheckList
//                       ? () => showModalBottomSheet(
//                             context: context,
//                             builder: (_) => const CheckListView(),
//                           )
//                       : null,
//                 ),
//                 ActionButton(
//                   icon: FontAwesomeIcons.locationDot,
//                   label: 'Estatus de soporte',
//                   color: Colors.red,
//                   enabled: enabledStatusSupport,
//                   onPressed: enabledStatusSupport
//                       ? () => showDialog(
//                             context: context,
//                             barrierDismissible: true,
//                             builder: (_) => Dialog(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(20))),
//                               child: StatusSupport(),
//                             ),
//                           )
//                       : null,
//                 ),
//                 ActionButton(
//                   icon: FontAwesomeIcons.mapLocationDot,
//                   label: 'Geocerca',
//                   color: Colors.blue,
//                   enabled: false,
//                   // onPressed: () => Navigator.push(
//                   //   context,
//                   //   MaterialPageRoute(builder: (_) => const MapaGooglePage()),
//                   // ),
//                   onPressed: null,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             const Divider(),
//             const SizedBox(height: 10),
//             // Segunda fila de acciones
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 // Botón Cierre de viaje (solo visible si el servicio es Contenedor)
//                 if (serviceDetail.serviceType == 'Contenedor')
//                   ActionButton(
//                     icon: FontAwesomeIcons.circleCheck,
//                     label: 'Cierre de viaje',
//                     color: Colors.green,
//                     enabled: serviceClosed,
//                     onPressed: serviceClosed
//                         ? () async {
//                             final detailVM = context.read<DetailViewModelOld>();

//                             final result = await Navigator.pushNamed(
//                               context,
//                               '/trip_closure',
//                               arguments: {
//                                 'id': serviceDetail.id!,
//                                 'serviceId':
//                                     serviceDetail.service?.toString() ?? '',
//                               },
//                             );

//                             // Cuando regresas de trip_closure
//                             if (result == true) {
//                               final detailServiceModel =
//                                   DetailService(id: serviceDetail.id!);
//                               detailVM.setNewDetail(detailServiceModel);

//                               final pending =
//                                   detailVM.item?.pendingMoneyChecks ?? false;
//                               if (!pending) {
//                                 final serviceVm =
//                                     context.read<ServicesViewModel>();
//                                 await serviceVm.onRefresh();

//                                 // Ahora sí puedes volver a la lista de servicios
//                                 Navigator.of(context).pop();
//                               }
//                             }
//                           }
//                         : null,
//                   ),

//                 // Botón Viáticos (solo visible si el usuario lo permite)
//                 //if (userSession.userRoll == 'No')
//                 ActionButton(
//                   icon: FontAwesomeIcons.moneyBillTransfer,
//                   label: 'Viáticos',
//                   color: Colors.teal,
//                   enabled: pendingMoneyChecks,
//                   onPressed: pendingMoneyChecks
//                       ? () async {
//                           final vm = context.read<TravelExpensesViewModel>();
//                           vm.setNewDetail(serviceDetail.id!);

//                           final result = await Navigator.push<bool>(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => TravelExpensesScreen()),
//                           );

//                           if (result == true) {
//                             // final detailVm = context.read<DetailViewModel>();
//                             // await detailVm.updateDetail();
//                             final serviceVm = context.read<ServicesViewModel>();
//                             await serviceVm.onRefresh();
//                             return Navigator.of(context).pop();
//                           }
//                         }
//                       : null,
//                 ),

//                 // Botón Descargar CCP (siempre visible)
//                 ActionButton(
//                   icon: FontAwesomeIcons.solidFilePdf,
//                   label: 'Descargar CCP',
//                   color: Colors.red,
//                   enabled: true,
//                   onPressed: () async {
//                     final res = await PdfService().getPdf(serviceDetail.id!);
//                     if (res == null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             'La remisión: ${serviceDetail.service} aun no cuenta con un CFDI timbrado',
//                           ),
//                         ),
//                       );
//                     } else {
//                       FileDownloader.downloadFile(
//                         url: res["url"],
//                         name: "CFDI Remision: ${serviceDetail.service}",
//                         notificationType: NotificationType.all,
//                       );
//                     }
//                   },
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class StatusButton extends StatelessWidget {
//   final DetailService serviceDetail;
//   final Future<void> Function(int statusId) onChangeStatus;

//   const StatusButton({
//     Key? key,
//     required this.serviceDetail,
//     required this.onChangeStatus,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<DetailViewModelOld>(context);
//     final statusId = viewModel.item?.mandatoryStatusId;
//     print('estatus actual $statusId');

//     // Validación personalizada: si el statusId == 9 y no hay evidencia → botón deshabilitado
//     final shouldDisableButton = (viewModel.item?.mandatoryStatusId == 10 &&
//         viewModel.item?.isEvidence == false);

//     // Determinar si el botón está habilitado
//     final isEnabled = (viewModel.item?.isEnableButton ?? false) &&
//         !viewModel.isLoading &&
//         !shouldDisableButton;

//     return SizedBox(
//       width: 380,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: isEnabled
//               ? Colors.green
//               : const Color(0xFF9E9E9E), // gris cuando está desactivado
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(100),
//           ),
//           minimumSize: const Size.fromHeight(50),
//         ),
//         onPressed: isEnabled
//             ? () async {
//                 final statusId = viewModel.item?.mandatoryStatusId;
//                 print('estatus actual $statusId');

//                 if (statusId == null) {
//                   scaffoldMessengerError(
//                     context,
//                     'No se puede cambiar el estatus porque falta el ID de estatus obligatorio.',
//                   );
//                   return;
//                 }

//                 await viewModel.changeStatusService(statusId);

//                 if (viewModel.item?.mandatoryStatusId == 10) {
//                   final result = await Navigator.pushNamed(
//                     context,
//                     '/send_evidence',
//                     arguments: {
//                       'id': viewModel.item!.id!,
//                       'serviceId': viewModel.item!.service!.toString(),
//                     },
//                   );
//                   if (result == true) {
//                     await viewModel.updateDetail();
//                   }
//                 } else if (statusId == 23 &&
//                     viewModel.item?.pendingMoneyChecks == false &&
//                     viewModel.item?.serviceType == "CajaSeca") {
//                   final result = await viewModel.closeTrip(viewModel.item!.id!);
//                   if (result.success) {
//                     scaffoldMessengerSuccessStatus(
//                       context,
//                       'El servicio se cerró correctamente.',
//                     );
//                   } else {
//                     scaffoldMessengerError(
//                         context, result.message ?? 'Error desconocido');
//                   }
//                 }
//               }
//             : null,
//         child: viewModel.isLoading
//             ? const SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2.5,
//                   color: Colors.white,
//                 ),
//               )
//             : Text(
//                 viewModel.item!.mandatoryStatus.toString(),
//                 style: const TextStyle(color: Colors.white),
//               ),
//       ),
//     );
//   }
// }

// class _InfoCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final List<Widget> children;

//   const _InfoCard(
//       {Key? key,
//       required this.title,
//       required this.icon,
//       required this.children})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       elevation: 8,
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//           side: const BorderSide(color: Color(0xFF84A756), width: 1)),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(children: [
//               Icon(icon, color: Colors.green),
//               const SizedBox(width: 8),
//               Text(title,
//                   style: const TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.bold)),
//             ]),
//             const Divider(),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;

//   const _InfoRow(
//       {Key? key, required this.icon, required this.label, required this.value})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 18, color: Colors.grey[700]),
//           const SizedBox(width: 8),
//           Expanded(
//             child: RichText(
//               text: TextSpan(
//                 style: const TextStyle(color: Colors.black, fontSize: 14),
//                 children: [
//                   TextSpan(
//                       text: '$label: ',
//                       style: const TextStyle(fontWeight: FontWeight.bold)),
//                   TextSpan(text: value),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ActionButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final bool enabled;
//   final VoidCallback? onPressed;

//   const ActionButton({
//     Key? key,
//     required this.icon,
//     required this.label,
//     required this.color,
//     this.enabled = true,
//     this.onPressed,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Opacity(
//       opacity: enabled ? 1.0 : 0.4,
//       child: GestureDetector(
//         onTap: enabled ? onPressed : null,
//         child: Column(
//           children: [
//             FaIcon(icon, color: color, size: 32),
//             const SizedBox(height: 5),
//             Text(label,
//                 style: TextStyle(
//                     color: enabled ? color : Colors.grey,
//                     fontWeight: FontWeight.w500)),
//           ],
//         ),
//       ),
//     );
//   }
// }
