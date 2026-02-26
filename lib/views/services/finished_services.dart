// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:segadi/utils/global_variables.dart';
// import 'package:segadi/views/home/routes.dart';
// import 'package:segadi/views/home/sidebar.dart';
// import 'package:segadi/models/services/services_finished.dart';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

// class FinishServiceList extends StatefulWidget {
//   @override
//   _FinishedServiceListScreenState createState() =>
//       _FinishedServiceListScreenState();
// }

// class _FinishedServiceListScreenState extends State<FinishServiceList> {
//   List<ServicesFinished> services = [];
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     getServices();
//   }

//   Future<void> getServices() async {
//     final prefs = await SharedPreferences.getInstance();
//     final id = prefs.getInt('id') ?? 0;
//     final token = prefs.getString('token') ?? '';
//     final route = 'index.php';

//     final String baseUrl = GlobalVariables.baseUrl;

//     final response = await http
//         .get(Uri.parse(baseUrl + route).replace(queryParameters: {
//           'r': 'esegadi/getterminadas',
//           'id': id.toString(),
//           'token': token,
//         }))
//         .timeout(const Duration(seconds: 90));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       setState(() {
//         services = List<ServicesFinished>.from(
//           data.map((item) => ServicesFinished.fromJson(item)),
//         );
//         loading = false;
//       });
//     } else {
//       setState(() => loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Remisiones Finalizadas',
//             style: TextStyle(color: Colors.white)),
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xFF2C522A),
//       ),
//       drawer: DrawerScreen(),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : services.isEmpty
//               ? const Center(child: Text("No hay servicios finalizados"))
//               : ListView.builder(
//                   padding: const EdgeInsets.all(10),
//                   itemCount: services.length,
//                   itemBuilder: (context, index) {
//                     final item = services[index];
//                     return FinishServiceCard(
//                       item: item,
//                       onTap: () {
//                         sendScreenWidget(context, item.id);
//                       },
//                     );
//                   },
//                 ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.red,
//         child: const Icon(Icons.phone, color: Colors.white),
//         onPressed: () {
//           FlutterPhoneDirectCaller.callNumber('+523311364928');
//         },
//       ),
//     );
//   }
// }

// class FinishServiceCard extends StatelessWidget {
//   final ServicesFinished item;
//   final VoidCallback onTap;

//   const FinishServiceCard({
//     Key? key,
//     required this.item,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         elevation: 8,
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//           side: const BorderSide(color: Color(0xFF84A756), width: 1),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading:
//                     const Icon(FontAwesomeIcons.truck, color: Colors.green),
//                 title: Text(
//                   'Remisión numero: ${item.service}',
//                   style: const TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16),
//                 ),
//                 subtitle: Text(
//                   'Cliente: ${item.client}',
//                   style: const TextStyle(color: Colors.black),
//                 ),
//               ),
//               const Divider(color: Colors.grey),
//               _buildSection('Origen de Carga', Icons.location_on, [
//                 _infoRow('Origen:', item.origin),
//                 _infoRow('Fecha:', item.loadDate)
//               ]),
//               const SizedBox(height: 8),
//               _buildSection('Destino de Carga', Icons.flag, [
//                 _infoRow('Destino:', item.destination),
//                 _infoRow('Fecha:', item.unloadDate)
//               ]),
//               const SizedBox(height: 8),
//               _infoRow('Documentador:', item.documenter),
//               const SizedBox(height: 12),
//               _statusButton("FINALIZADO"),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSection(String title, IconData icon, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(children: [
//           Icon(icon, size: 18, color: Colors.grey[700]),
//           const SizedBox(width: 6),
//           Text(title,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                   fontSize: 15)),
//         ]),
//         const SizedBox(height: 4),
//         ...children
//       ],
//     );
//   }

//   Widget _infoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 2, bottom: 2),
//       child: Row(
//         children: [
//           Text('$label ',
//               style: const TextStyle(color: Colors.black, fontSize: 13)),
//           Expanded(
//             child: Text(value,
//                 style: const TextStyle(color: Colors.black, fontSize: 13),
//                 overflow: TextOverflow.ellipsis),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _statusButton(String status) {
//     return ElevatedButton(
//       onPressed: null,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xFF2C522A),
//         disabledForegroundColor: Colors.green,
//         disabledBackgroundColor: Colors.green,
//         elevation: 0,
//         minimumSize: const Size.fromHeight(40),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
//       ),
//       child: Text(
//         status,
//         style: const TextStyle(fontSize: 13, color: Colors.white),
//       ),
//     );
//   }
// }

// void sendScreenWidget(BuildContext context, int id) {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => DetailServicesFinishedScreen(id: id),
//     ),
//   );
// }
