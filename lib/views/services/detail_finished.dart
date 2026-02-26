// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

// import 'package:segadi/models/services/detail_finished.dart';
// import 'package:segadi/utils/user_session.dart';
// import 'package:segadi/views/home/sidebar.dart';

// import 'package:segadi/viewmodels/services_operator/detail_finished.dart';

// class DetailServicesFinishedScreen extends StatefulWidget {
//   final int id;

//   const DetailServicesFinishedScreen({Key? key, required this.id})
//       : super(key: key);

//   @override
//   _DetailServicesFinishedScreen createState() =>
//       _DetailServicesFinishedScreen(id);
// }

// class _DetailServicesFinishedScreen
//     extends State<DetailServicesFinishedScreen> {
//   final int id;
//   Future<DetailFinished>? detailFinished;
//   _DetailServicesFinishedScreen(this.id);

//   @override
//   void initState() {
//     super.initState();
//     detailFinished = Detail().getService(id);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = UserSession();
//     print('Nombre de usuario: ${UserSession().name}');
//     print('el usuario es permisionario: ${user.userRoll}');
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Detalle Remisión',
//             style: TextStyle(color: Colors.white)),
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xFF2C522A),
//       ),
//       drawer: DrawerScreen(),
//       body: FutureBuilder<DetailFinished>(
//         future: detailFinished,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } else if (!snapshot.hasData) {
//             return const Center(child: Text("No hay información disponible."));
//           }

//           final data = snapshot.data!;
//           final textStyle =
//               const TextStyle(fontSize: 14, color: Colors.black87);
//           final titleStyle = const TextStyle(
//               fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87);

//           Widget buildInfoItem(String label, String value, {IconData? icon}) {
//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 4),
//               child: Row(
//                 children: [
//                   if (icon != null)
//                     Icon(icon, size: 16, color: Colors.grey[600]),
//                   if (icon != null) const SizedBox(width: 6),
//                   Text("$label: ", style: titleStyle),
//                   Expanded(
//                       child:
//                           AutoSizeText(value, style: textStyle, maxLines: 2)),
//                 ],
//               ),
//             );
//           }

//           Widget buildSection(
//               String title, List<Widget> children, IconData sectionIcon) {
//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               color: Colors.white,
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(sectionIcon, color: const Color(0xFF2C522A)),
//                         const SizedBox(width: 8),
//                         Text(title,
//                             style: const TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                     const Divider(height: 20, thickness: 1),
//                     ...children,
//                   ],
//                 ),
//               ),
//             );
//           }

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               children: [
//                 Text(
//                   'REMISIÓN NÚMERO: ${data.service}',
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       color: Colors.black87),
//                 ),
//                 SizedBox(height: 10),
//                 dataCard(
//                   title: 'Remitente',
//                   icon: Icons.send,
//                   content: [
//                     infoRow(Icons.business, 'Razón Social',
//                         data.senderBusinessName),
//                     infoRow(Icons.phone, 'Teléfono', data.senderPhoneNumber),
//                     infoRow(Icons.person, 'Contacto', data.senderName),
//                     infoRow(Icons.home, 'Domicilio',
//                         '${data.senderStreet} ${data.senderOutdoorNumber} CP ${data.senderZipCode}'),
//                   ],
//                 ),
//                 dataCard(
//                   title: "Destinatario",
//                   icon: Icons.location_on,
//                   content: [
//                     buildInfoItem("Razón Social", data.recipientBusinessName,
//                         icon: Icons.business),
//                     buildInfoItem("Teléfono", data.recipientPhoneNumber,
//                         icon: Icons.phone),
//                     buildInfoItem("Contacto", data.recipientName,
//                         icon: Icons.person),
//                     buildInfoItem("Domicilio",
//                         '${data.recipientStreet} ${data.recipientOutdoorNumber} ${data.recipientZipCode} ${data.recipientState}',
//                         icon: Icons.location_on),
//                   ],
//                 ),
//                 if (user.userRoll == "No")
//                   dataCard(
//                     title: "Comisiones",
//                     icon: Icons.paid,
//                     content: [
//                       buildInfoItem("Comisión Total", '\$${data.paymentTotal}',
//                           icon: Icons.attach_money),
//                       buildInfoItem(
//                           "Total Asignado", '\$${data.allowanceChecked}',
//                           icon: Icons.assignment_turned_in),
//                       buildInfoItem(
//                           "Viáticos Comprobados", '\$${data.allowanceChecked}',
//                           icon: Icons.check_circle),
//                       buildInfoItem("Diferencia de Viáticos",
//                           '\$${data.allowanceDifference}',
//                           icon: Icons.compare_arrows),
//                     ],
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.red,
//         elevation: 10,
//         child: const Icon(Icons.phone, color: Colors.white),
//         onPressed: () {
//           FlutterPhoneDirectCaller.callNumber('+523311364928');
//         },
//       ),
//     );
//   }
// }

// extension on String? {
//   // toStringAsFixed(int i) {}
// }

// Widget dataCard(
//     {required String title,
//     required IconData icon,
//     required List<Widget> content}) {
//   return Card(
//     margin: EdgeInsets.symmetric(vertical: 10),
//     elevation: 8,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(20),
//       side: const BorderSide(color: Color(0xFF84A756), width: 1),
//     ),
//     child: Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: Colors.green),
//               SizedBox(width: 8),
//               Text(title,
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           Divider(),
//           ...content,
//         ],
//       ),
//     ),
//   );
// }

// Widget infoRow(IconData icon, String label, String value) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 6),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 18, color: Colors.grey[700]),
//         SizedBox(width: 8),
//         Expanded(
//           child: RichText(
//             text: TextSpan(
//               style: TextStyle(color: Colors.black, fontSize: 14),
//               children: [
//                 TextSpan(
//                     text: '$label: ',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 TextSpan(text: value),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
