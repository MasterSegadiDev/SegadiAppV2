import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_list_view_model.dart';
import 'package:segadi/views/container_movements/containers_map.dart';
import 'package:segadi/views/home/sidebar.dart';

class MovimientoView extends StatelessWidget {
  const MovimientoView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ContainerMovementListViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movimiento de contenedores',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 33, 150, 91),
      ),
      backgroundColor: Colors.white,
      drawer: DrawerScreen(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: viewModel.loadMovimientos,
          child: Builder(
            builder: (_) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.error != null) {
                return Center(
                  child: Text("Error: ${viewModel.error}",
                      style: const TextStyle(color: Colors.red)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: viewModel.movimientos.length,
                itemBuilder: (context, index) {
                  final m = viewModel.movimientos[index];
                  return GestureDetector(
                    onTap: () {
                      // final detailServiceModel = DetailService(id: item.id);
                      // Provider.of<DetailViewModel>(context, listen: false)
                      //     .setNewDetail(detailServiceModel);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ContainersMapScreen(
                                  areaDestino: 'A',
                                  espacioDestino: '1',
                                  nivelDestino: '1',
                                  status: 'Lleno',
                                )),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.service ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 33, 150, 91),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                                icon: LucideIcons.type,
                                label: "Tipo",
                                value: m.movementType ?? 'N/A'),
                            _buildInfoRow(
                                icon: LucideIcons.fileText,
                                label: "Remisión",
                                value: m.service ?? 'N/A'),
                            _buildInfoRow(
                                icon: LucideIcons.package,
                                label: "Contenedor a mover",
                                value: m.status ?? 'Sin estatus'),
                            _buildInfoRow(
                                icon: LucideIcons.hash,
                                label: "Contenedor A",
                                value: m.containerNumberA ?? 'Sin contenedor'),
                            _buildInfoRow(
                                icon: LucideIcons.hash,
                                label: "Contenedor B",
                                value: m.containerNumberB ?? 'Sin contenedor'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
