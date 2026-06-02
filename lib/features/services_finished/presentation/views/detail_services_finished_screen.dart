import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:segadi/features/services_finished/presentation/viewmodels/detail_finished_view_model.dart';

// class DetailServicesFinishedScreen extends StatefulWidget {
//   final int id;

//   const DetailServicesFinishedScreen({Key? key, required this.id})
//       : super(key: key);

//   @override
//   State<DetailServicesFinishedScreen> createState() =>
//       _DetailServicesFinishedScreenState();
// }

// class _DetailServicesFinishedScreenState
//     extends State<DetailServicesFinishedScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Cargamos los datos al iniciar usando el ViewModel
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<DetailFinishedViewModel>().fetchServiceDetail(widget.id);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Detalle Remisión',
//           style: TextStyle(color: Colors.white, fontSize: 18),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xFF2C522A),
//       ),
//       body: Consumer<DetailFinishedViewModel>(
//         builder: (context, vm, child) {
//           if (vm.isLoading) {
//             return const Center(
//                 child: CircularProgressIndicator(color: Color(0xFF2C522A)));
//           }

//           if (vm.errorMessage != null) {
//             return _buildErrorState(vm);
//           }

//           final data = vm.detail;
//           if (data == null) return const Center(child: Text("No hay datos"));

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(data.service),
//                 const SizedBox(height: 20),
//                 _buildInfoCard(
//                   title: "Remitente",
//                   icon: Icons.upload_file_outlined,
//                   children: [
//                     _infoItem(Icons.business, "Razón Social",
//                         data.senderBusinessName),
//                     _infoItem(Icons.phone_android, "Teléfono",
//                         data.senderPhoneNumber),
//                     _infoItem(
//                         Icons.person_outline, "Contacto", data.senderName),
//                     _infoItem(Icons.map_outlined, "Dirección",
//                         "${data.senderStreet} #${data.senderOutdoorNumber}"),
//                   ],
//                 ),
//                 const SizedBox(height: 15),
//                 _buildInfoCard(
//                   title: "Destinatario",
//                   icon: Icons.download_done_outlined,
//                   children: [
//                     _infoItem(Icons.business, "Razón Social",
//                         data.recipientBusinessName),
//                     _infoItem(Icons.phone_android, "Teléfono",
//                         data.recipientPhoneNumber),
//                     _infoItem(Icons.location_on_outlined, "Ubicación",
//                         "${data.recipientStreet}, ${data.recipientState}"),
//                   ],
//                 ),
//                 // Solo mostrar si el usuario tiene permiso (Lógica de negocio en ViewModel)
//                 if (vm.canShowCommissions) ...[
//                   const SizedBox(height: 15),
//                   _buildInfoCard(
//                     title: "Resumen Financiero",
//                     icon: Icons.account_balance_wallet_outlined,
//                     children: [
//                       _infoItem(Icons.attach_money, "Pago Total",
//                           "\$${data.paymentTotal}",
//                           isBold: true),
//                       _infoItem(Icons.check_circle_outline, "Viáticos",
//                           "\$${data.allowanceChecked}"),
//                     ],
//                   ),
//                 ],
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // --- WIDGETS DE APOYO ESTILIZADOS ---

//   Widget _buildHeader(String serviceNumber) {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2C522A).withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           const Icon(FontAwesomeIcons.fileInvoice, color: Color(0xFF2C522A)),
//           const SizedBox(width: 15),
//           Text("Folio: $serviceNumber",
//               style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2C522A))),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoCard(
//       {required String title,
//       required IconData icon,
//       required List<Widget> children}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.grey.shade100),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.03),
//               blurRadius: 10,
//               offset: const Offset(0, 5))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 20, color: const Color(0xFF2C522A)),
//               const SizedBox(width: 8),
//               Text(title,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, fontSize: 16)),
//             ],
//           ),
//           const Divider(height: 25),
//           ...children,
//         ],
//       ),
//     );
//   }

//   Widget _infoItem(IconData icon, String label, String value,
//       {bool isBold = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 16, color: Colors.grey),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label,
//                     style:
//                         TextStyle(color: Colors.grey.shade500, fontSize: 12)),
//                 Text(value,
//                     style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
//                         color: Colors.black87)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(DetailFinishedViewModel vm) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
//             const SizedBox(height: 20),
//             Text(vm.errorMessage!,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 16)),
//             TextButton(
//                 onPressed: () => vm.fetchServiceDetail(widget.id),
//                 child: const Text("Reintentar")),
//           ],
//         ),
//       ),
//     );
//   }
// }
class DetailServicesFinishedScreen extends StatefulWidget {
  final int id;

  const DetailServicesFinishedScreen({Key? key, required this.id})
      : super(key: key);

  @override
  State<DetailServicesFinishedScreen> createState() =>
      _DetailServicesFinishedScreenState();
}

class _DetailServicesFinishedScreenState
    extends State<DetailServicesFinishedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetailFinishedViewModel>().fetchServiceDetail(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Detalle Remisión Finalizada',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
        elevation: 0,
      ),
      body: Consumer<DetailFinishedViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2C522A)));
          }

          if (vm.errorMessage != null) return _buildErrorState(vm);

          final data = vm.detail;
          if (data == null) return const Center(child: Text("No hay datos"));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // --- CARD PRINCIPAL CON DISEÑO DE LÍNEA DE TIEMPO ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTopHeader(data.service),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildRouteTimeline(data),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- SECCIÓN FINANCIERA (Si aplica) ---
                if (vm.canShowCommissions) _buildFinancialCard(data),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCCIÓN ---

  Widget _buildTopHeader(String serviceNumber) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C522A).withOpacity(0.08),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF2C522A),
            radius: 18,
            child:
                Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('REMISIÓN FINALIZADA',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C522A),
                      letterSpacing: 1.1)),
              Text(serviceNumber,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteTimeline(dynamic data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(Icons.radio_button_checked,
                size: 20, color: Colors.green),
            Container(width: 2, height: 130, color: Colors.grey[200]),
            const Icon(Icons.location_on, size: 20, color: Colors.redAccent),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _locationDetailBlock(
                'REMITENTE',
                data.senderBusinessName,
                data.senderName,
                data.senderPhoneNumber,
                "${data.senderStreet} #${data.senderOutdoorNumber}",
              ),
              const SizedBox(height: 40),
              _locationDetailBlock(
                'DESTINATARIO',
                data.recipientBusinessName,
                data.recipientName,
                data.recipientPhoneNumber,
                "${data.recipientStreet}, ${data.recipientState}",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _locationDetailBlock(String tag, String? biz, String? contact,
      String? phone, String? address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tag,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(biz ?? '-',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(contact ?? '-',
            style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.phone, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(phone ?? '-',
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          ],
        ),
        Text(address ?? '-',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            maxLines: 2),
      ],
    );
  }

  Widget _buildFinancialCard(dynamic data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C522A).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: Color(0xFF2C522A), size: 20),
              const SizedBox(width: 10),
              const Text("RESUMEN FINANCIERO",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF2C522A))),
            ],
          ),
          const Divider(height: 30),
          _financialItem("Pago Total", "\$${data.paymentTotal}", isBold: true),
          _financialItem("Viáticos", "\$${data.allowanceChecked}"),
        ],
      ),
    );
  }

  Widget _financialItem(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isBold ? Colors.black : Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildErrorState(DetailFinishedViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(vm.errorMessage!),
          ElevatedButton(
            onPressed: () => vm.fetchServiceDetail(widget.id),
            child: const Text("Reintentar"),
          )
        ],
      ),
    );
  }
}
