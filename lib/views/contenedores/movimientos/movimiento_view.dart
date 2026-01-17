import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/contenedores/movimientosContenedoresListadoViewModel.dart';
import 'package:segadi/views/contenedores/mapas_contenedor/mapas_contenedor.dart';
import 'package:segadi/views/contenedores/movimientos/widgets/movimiento_card.dart';

class MovimientoView extends StatefulWidget {
  const MovimientoView({super.key});

  @override
  State<MovimientoView> createState() => _MovimientoViewState();
}

class _MovimientoViewState extends State<MovimientoView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final vm = context.read<movimientosContenedoresListadoViewModel>();
      vm.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<movimientosContenedoresListadoViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimiento de contenedores'),
        backgroundColor: const Color(0xFF2C522A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: _buildFloatingButtons(vm),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText:
                      'Buscar por numero de contenedor, tipo de movimiento o número de movimiento...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: vm.setSearchQuery,
              ),
            ),

            // -------------------------
            // LISTA + REFRESH
            // -------------------------
            Expanded(
              child: RefreshIndicator(
                onRefresh: vm.refresh,
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.movimientosFiltrados.isEmpty
                        ? const Center(
                            child: Text(
                              "No hay movimientos asignados",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: vm.movimientosFiltrados.length,
                            itemBuilder: (_, index) {
                              final m = vm.movimientosFiltrados[index];

                              // Determinar contenedor mover
                              String? mover = m.containerToMove?.toLowerCase();
                              String? contenedorMover;

                              if (mover != null) {
                                if (mover.contains("a"))
                                  contenedorMover = m.containerNumberA;
                                if (mover.contains("b"))
                                  contenedorMover = m.containerNumberB;
                              }

                              return MovimientoCard(
                                movimiento: m,
                                contenedorMover: contenedorMover,
                                onTap: () async {
                                  vm.setSelectedMovement(
                                    m: m,
                                    siteId: vm.selectedSiteId ?? "2",
                                    contenedorMover: contenedorMover,
                                  );

                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ContainersMapScreen()),
                                  );

                                  if (result == "recargar") vm.refresh();
                                },
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------
  // BOTONES FLOTANTES (REACOMODO / PESAJE)
  // ----------------------------------------
  Widget _buildFloatingButtons(movimientosContenedoresListadoViewModel vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          heroTag: 'reacomodo',
          onPressed: () {
            vm.setManualMovement(type: "Reacomodo");

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ContainersMapScreen(),
              ),
            );
          },
          label: const Text("Reacomodo"),
          icon: const Icon(Icons.swap_horiz),
          backgroundColor: Colors.teal,
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: 'pesaje',
          onPressed: () {
            vm.setManualMovement(type: "Pesaje");

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => const ContainersMapScreen(),
            //   ),
            // );
          },
          label: const Text("Pesaje"),
          icon: const Icon(Icons.scale),
          backgroundColor: Colors.deepOrange,
        ),
      ],
    );
  }
}
