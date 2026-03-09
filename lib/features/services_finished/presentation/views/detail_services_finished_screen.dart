import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:segadi/features/services_finished/presentation/viewmodels/detail_finished_view_model.dart';

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
    // Cargamos los datos al iniciar usando el ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetailFinishedViewModel>().fetchServiceDetail(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalle de Remisión',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C522A),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<DetailFinishedViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2C522A)));
          }

          if (vm.errorMessage != null) {
            return _buildErrorState(vm);
          }

          final data = vm.detail;
          if (data == null) return const Center(child: Text("No hay datos"));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(data.service),
                const SizedBox(height: 20),
                _buildInfoCard(
                  title: "Remitente",
                  icon: Icons.upload_file_outlined,
                  children: [
                    _infoItem(Icons.business, "Razón Social",
                        data.senderBusinessName),
                    _infoItem(Icons.phone_android, "Teléfono",
                        data.senderPhoneNumber),
                    _infoItem(
                        Icons.person_outline, "Contacto", data.senderName),
                    _infoItem(Icons.map_outlined, "Dirección",
                        "${data.senderStreet} #${data.senderOutdoorNumber}"),
                  ],
                ),
                const SizedBox(height: 15),
                _buildInfoCard(
                  title: "Destinatario",
                  icon: Icons.download_done_outlined,
                  children: [
                    _infoItem(Icons.business, "Razón Social",
                        data.recipientBusinessName),
                    _infoItem(Icons.phone_android, "Teléfono",
                        data.recipientPhoneNumber),
                    _infoItem(Icons.location_on_outlined, "Ubicación",
                        "${data.recipientStreet}, ${data.recipientState}"),
                  ],
                ),
                // Solo mostrar si el usuario tiene permiso (Lógica de negocio en ViewModel)
                if (vm.canShowCommissions) ...[
                  const SizedBox(height: 15),
                  _buildInfoCard(
                    title: "Resumen Financiero",
                    icon: Icons.account_balance_wallet_outlined,
                    children: [
                      _infoItem(Icons.attach_money, "Pago Total",
                          "\$${data.paymentTotal}",
                          isBold: true),
                      _infoItem(Icons.check_circle_outline, "Viáticos",
                          "\$${data.allowanceChecked}"),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS DE APOYO ESTILIZADOS ---

  Widget _buildHeader(String serviceNumber) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2C522A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(FontAwesomeIcons.fileInvoice, color: Color(0xFF2C522A)),
          const SizedBox(width: 15),
          Text("Folio: $serviceNumber",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C522A))),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2C522A)),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 25),
          ...children,
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                        color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(DetailFinishedViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(vm.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
            TextButton(
                onPressed: () => vm.fetchServiceDetail(widget.id),
                child: const Text("Reintentar")),
          ],
        ),
      ),
    );
  }
}
