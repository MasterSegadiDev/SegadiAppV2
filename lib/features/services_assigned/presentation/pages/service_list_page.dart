import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/services_assigned/presentation/viewmodels/service_state.dart';
import 'package:segadi/features/services_assigned/presentation/viewmodels/services_viewmodel.dart';
import 'package:segadi/features/services_assigned/presentation/widgets/service_card.dart';
import 'package:segadi/views/home/sidebar.dart';

class ServiceListView extends StatelessWidget {
  const ServiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServicesViewModel>();

    return Scaffold(
      appBar: _buildAppBar(),
      drawer: DrawerScreen(),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: vm.refresh,
        child: _buildBody(vm),
      ),
      floatingActionButton: _buildCallButton(),
    );
  }

  // ==================== UI STATES ====================

  Widget _buildBody(ServicesViewModel vm) {
    final state = vm.state;

    if (state is ServicesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ServicesError) {
      return _buildErrorState(state.message, vm);
    }

    if (state is ServicesEmpty) {
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

    if (state is ServicesLoaded) {
      return ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: state.items.length,
        itemBuilder: (_, index) {
          return ServiceCard(item: state.items[index]);
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorState(String message, ServicesViewModel vm) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 150),
        Column(
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
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: vm.refresh,
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
