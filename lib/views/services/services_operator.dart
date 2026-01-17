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

class ServiceListView extends StatefulWidget {
  const ServiceListView({super.key});

  @override
  State<ServiceListView> createState() => _ServiceListViewState();
}

class _ServiceListViewState extends State<ServiceListView> {
  @override
  void initState() {
    super.initState();
    // Carga inicial segura
    Future.microtask(() {
      context.read<ServicesViewModel>().fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ServicesViewModel>();

    if (viewModel.sessionExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      });
    }

    return Scaffold(
      appBar: _buildAppBar(),
      drawer: DrawerScreen(),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: viewModel.onRefresh,
        child: _buildBody(viewModel),
      ),
      floatingActionButton: _buildCallButton(),
    );
  }

  // ==================== UI STATES ====================

  Widget _buildBody(ServicesViewModel vm) {
    // Loading inicial
    if (vm.isLoading && vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (vm.errorMessage != null) {
      return _buildErrorState(vm);
    }

    // Lista vacía (mantiene scroll para RefreshIndicator)
    if (vm.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(
            child: Text(
              'No hay servicios disponibles',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
    }

    // Lista con datos
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: vm.items.length,
      itemBuilder: (_, index) {
        return _ServiceCard(item: vm.items[index]);
      },
    );
  }

  Widget _buildErrorState(ServicesViewModel vm) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 150),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                vm.errorMessage ?? 'Ocurrió un error inesperado',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: vm.fetchItems,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Reintentar',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C522A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== COMPONENTS ====================

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Remisiones Asignadas',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF2C522A),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  FloatingActionButton _buildCallButton() {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      child: const Icon(Icons.phone, color: Colors.white),
      onPressed: () async {
        try {
          await FlutterPhoneDirectCaller.callNumber('523311364928');
        } catch (e) {
          debugPrint('Error al realizar llamada: $e');
        }
      },
    );
  }
}

// ==================== SERVICE CARD ====================

class _ServiceCard extends StatelessWidget {
  final Services item;

  const _ServiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          '/detail_service',
          arguments: item.id,
        );

        if (result == true) {
          context.read<ServicesViewModel>().onRefresh();
        }
      },
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF84A756)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Title(item),
              const Divider(),
              _Section(
                title: 'Origen de Carga',
                icon: Icons.location_on,
                rows: [
                  _info('Origen', item.origin),
                  _info('Fecha', item.loadDate),
                ],
              ),
              _Section(
                title: 'Destino de Carga',
                icon: Icons.flag,
                rows: [
                  _info('Destino', item.destination),
                  _info('Fecha', item.unloadDate),
                ],
              ),
              _Section(
                title: 'Escalas',
                icon: Icons.map,
                rows: [
                  _info('Primera', item.scaleOne),
                  _info('Segunda', item.scaleTwo),
                ],
              ),
              const SizedBox(height: 12),
              _StatusButton(item.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$label: ${value ?? '-'}',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}

// ==================== SUBCOMPONENTS ====================

class _Title extends StatelessWidget {
  final Services item;

  const _Title(this.item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(FontAwesomeIcons.truck, color: Colors.green),
      title: Text(
        'Remisión: ${item.service ?? '-'}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Cliente: ${item.client ?? '-'}'),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> rows;

  const _Section({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...rows,
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String? status;

  const _StatusButton(this.status);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2C522A),
        disabledBackgroundColor: Colors.green,
        minimumSize: const Size.fromHeight(40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: Text(
        status ?? 'Desconocido',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
