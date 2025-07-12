import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:segadi/models/services/detail_service.dart';
import 'package:segadi/models/services/services.dart';
import 'package:segadi/views/home/sidebar.dart';
import 'package:segadi/views/services/detail_service.dart';
import 'package:segadi/viewmodels/services_operator/assigned_services.dart';
import 'package:segadi/viewmodels/services_operator/detail_service.dart';

class ServiceListView extends StatelessWidget {
  const ServiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceViewModel = Provider.of<ServicesViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Remisiones Asignadas',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      backgroundColor: Colors.white,
      drawer: DrawerScreen(),
      body: RefreshIndicator(
        onRefresh: serviceViewModel.onRefresh,
        child: _buildBody(context, serviceViewModel),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.phone, color: Colors.white),
        onPressed: () => FlutterPhoneDirectCaller.callNumber('+523311364928'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ServicesViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
          child: Text(viewModel.errorMessage!,
              style: const TextStyle(color: Colors.red)));
    }

    if (viewModel.items.isEmpty) {
      return const Center(child: Text('No hay servicios disponibles.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: viewModel.items.length,
      itemBuilder: (context, index) {
        final item = viewModel.items[index];
        return _buildServiceCard(context, item);
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, Services item) {
    return GestureDetector(
      onTap: () {
        final detailServiceModel = DetailService(id: item.id);
        Provider.of<DetailViewModel>(context, listen: false)
            .setNewDetail(detailServiceModel);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailServiceScreen()),
        );
      },
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF84A756), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleRow(item),
              const Divider(color: Colors.grey),
              _buildSection('Origen de Carga', Icons.location_on, [
                _infoRow('Origen:', item.origin ?? '-'),
                _infoRow('Fecha:', item.loadDate ?? '-'),
              ]),
              const SizedBox(height: 8),
              _buildSection('Destino de Carga', Icons.flag, [
                _infoRow('Destino:', item.destination ?? '-'),
                _infoRow('Fecha:', item.unloadDate ?? '-'),
              ]),
              const SizedBox(height: 8),
              _buildSection('Escalas', Icons.map, [
                _infoRow('Primera Escala:', item.scaleOne ?? '-'),
                _infoRow('Segunda Escala:', item.scaleTwo ?? '-'),
              ]),
              const SizedBox(height: 8),
              _infoRow('Documentador:', item.documenter ?? '-'),
              const SizedBox(height: 12),
              _statusButton(item.status ?? 'Desconocido'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(Services item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(FontAwesomeIcons.truck, color: Colors.green),
      title: Text(
        'Remisión número: ${item.service}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text('Cliente: ${item.client}',
          style: const TextStyle(color: Colors.black)),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ]),
        const SizedBox(height: 4),
        ...children,
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label ', style: const TextStyle(fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusButton(String status) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2C522A),
        disabledBackgroundColor: Colors.green,
        elevation: 0,
        minimumSize: const Size.fromHeight(40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      child: Text(status,
          style: const TextStyle(fontSize: 13, color: Colors.white)),
    );
  }
}
