import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/services_finished/presentation/viewmodels/finished_service_view_model.dart';
import 'package:segadi/features/services_finished/presentation/views/detail_services_finished_screen.dart';
import 'package:segadi/features/services_finished/presentation/widgets/finish_service_card.dart';

class FinishServiceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Iniciamos la carga al construir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinishedServicesViewModel>().fetchServices();
    });

    return Scaffold(
      backgroundColor: Colors.grey[50], // Fondo sutil
      appBar: AppBar(
        title: const Text('Remisiones Finalizadas',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C522A),
        elevation: 0,
      ),
      body: Consumer<FinishedServicesViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading)
            return const Center(child: CircularProgressIndicator());

          if (vm.errorMessage != null) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                Text(vm.errorMessage!),
                ElevatedButton(
                    onPressed: vm.fetchServices,
                    child: const Text("Reintentar"))
              ],
            ));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // Agregamos física de rebote para una sensación más premium en iOS/Android
            physics: const BouncingScrollPhysics(),
            itemCount: vm.services.length,
            itemBuilder: (context, index) {
              final service = vm.services[index];

              return FinishServiceCard(
                item: service,
                onTap: () {
                  // Navegación profesional al detalle
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailServicesFinishedScreen(id: service.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
