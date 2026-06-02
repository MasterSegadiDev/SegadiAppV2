import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/services_finished/presentation/viewmodels/finished_service_view_model.dart';
import 'package:segadi/features/services_finished/presentation/views/detail_services_finished_screen.dart';
import 'package:segadi/features/services_finished/presentation/widgets/finish_service_card.dart';

class FinishServiceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinishedServicesViewModel>().fetchServices();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Remisiones Finalizadas',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      body: Column(
        children: [
          // --- BARRA DE BÚSQUEDA ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => context
                  .read<FinishedServicesViewModel>()
                  .updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Buscar por remisión, cliente o estatus...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2C522A)),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- LISTADO ---
          Expanded(
            child: Consumer<FinishedServicesViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading)
                  return const Center(child: CircularProgressIndicator());

                if (vm.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: Colors.red),
                        Text(vm.errorMessage!),
                        ElevatedButton(
                          onPressed: vm.fetchServices,
                          child: const Text("Reintentar"),
                        )
                      ],
                    ),
                  );
                }

                // Usamos la lista filtrada del ViewModel
                final listToShow = vm.filteredServices;

                if (listToShow.isEmpty) {
                  return const Center(
                      child: Text("No se encontraron resultados"));
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: listToShow.length,
                  itemBuilder: (context, index) {
                    final service = listToShow[index];
                    return FinishServiceCard(
                      item: service,
                      onTap: () {
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
          ),
        ],
      ),
    );
  }
}
