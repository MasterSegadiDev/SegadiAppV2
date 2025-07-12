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

    Future<void> _handleRefresh() async {
      await viewModel.loadMovimientos(forceReload: true); // Si es posible
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Movimiento de contenedores',
            style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF2C522A),
      ),
      backgroundColor: Colors.white,
      drawer: DrawerScreen(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Builder(
            builder: (_) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.error != null) {
                return Center(
                  child: Text(
                    " ${viewModel.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: viewModel.movimientos.length,
                itemBuilder: (context, index) {
                  final m = viewModel.movimientos[index];

                  // Determinar qué contenedor se va a mover
                  String? containerToMove = m.containerToMove?.toLowerCase();
                  String? contenedorMover;

                  if (containerToMove != null) {
                    if (containerToMove.contains('a')) {
                      contenedorMover = m.containerNumberA;
                      print('CONTENEDOR A MOVER: ${contenedorMover}');
                    } else if (containerToMove.contains('b')) {
                      contenedorMover = m.containerNumberB;
                      print('CONTENEDOR B MOVER: ${contenedorMover}');
                    }
                  }

                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContainersMapScreen(
                            status: m.status,
                            movementId: m.id,
                            initialArea: m.area,
                            initialEspacio: m.space,
                            initialNivel: m.level,
                            movementType: m.movementType!,
                            containerNumber: contenedorMover,
                          ),
                        ),
                      );

                      if (result == 'recargar') {
                        // _recargarListado(); // Aquí refrescas tu lista
                        _handleRefresh();
                        print('RECARGAR LISTA ...');
                      }
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   m.service ?? 'N/A',
                            //   style: const TextStyle(
                            //     fontSize: 18,
                            //     fontWeight: FontWeight.bold,
                            //     color: Color.fromARGB(255, 33, 150, 91),
                            //   ),
                            // ),

                            _buildInfoRow(
                              icon: LucideIcons.frame,
                              label: "Movimiento de grua",
                              value: m.craneMovement ?? 'S/N',
                            ),
                            _buildInfoRow(
                              icon: LucideIcons.type,
                              label: "Tipo de movimiento",
                              value: m.movementType ?? 'N/A',
                            ),
                            _buildInfoRow(
                              icon: LucideIcons.fileText,
                              label: "Remisión",
                              value: m.service ?? 'N/A',
                            ),
                            _buildInfoRow(
                              icon: LucideIcons.user,
                              label: "Operador",
                              value: m.craneOperator ?? 'Sin operador',
                            ),
                            _buildInfoRow(
                              icon: LucideIcons.truck,
                              label: "Unidad",
                              value: m.unit ?? 'No hay unidad',
                            ),

                            _buildInfoRow(
                              icon: LucideIcons.truck,
                              label: "Unidad Mov. Local",
                              value:
                                  m.localUnit ?? 'No hay unidad local asignada',
                            ),
                            _buildInfoRow(
                              icon: LucideIcons.container,
                              label: "Numero de contenedor",
                              value: contenedorMover ?? 'S/N',
                            ),
                            _buildInfoRow(
                              icon: LucideIcons.container,
                              label: "Estado del contenedor",
                              value: m.containerStatus ?? 'S/E',
                            ),
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'reacomodo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContainersMapScreen(
                    status: '',
                    movementId: 0,
                    initialArea: '',
                    initialEspacio: '',
                    initialNivel: '',
                    //tipoMovimiento: 'Movimiento',
                    movementType: 'Reacomodo',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.swap_horiz,
              color: Colors.white,
            ),
            label: const Text(
              'Reacomodo',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.teal,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'pesaje',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContainersMapScreen(
                    status: '',
                    movementId: 0,
                    initialArea: '',
                    initialEspacio: '',
                    initialNivel: '',
                    //tipoMovimiento: 'Movimiento',
                    movementType: 'Pesaje',
                    containerNumber: '',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.scale,
              color: Colors.white,
            ),
            label: const Text(
              'Pesaje',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.deepOrange,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
