import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/contenedores/movimientosContenedoresListadoViewModel.dart';
import 'package:segadi/viewmodels/contenedores/ubicacionesViewModel.dart';

import 'area_card_widget.dart';

class MapaUbicacionesWidget extends StatelessWidget {
  final String tipoMovimiento;
  final String? movementId;

  final String? areaInicial;
  final String? espacioInicial;
  final String? nivelInicial;

  const MapaUbicacionesWidget({
    super.key,
    required this.tipoMovimiento,
    required this.movementId,
    this.areaInicial,
    this.espacioInicial,
    this.nivelInicial,
    required UbicacionesViewModel vm,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UbicacionesViewModel>();

    if (vm.isLoading) return const Center(child: CircularProgressIndicator());
    if (vm.error != null) return Center(child: Text(vm.error!));

    print('tipo de movimiento: ${tipoMovimiento}');

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: vm.getAreas().map((area) {
                  return AreaCardWidget(
                    area: area,
                    tipoMovimiento: tipoMovimiento,
                    movementId: movementId,
                    areaInicial: areaInicial,
                    espacioInicial: espacioInicial,
                    nivelInicial: nivelInicial,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isPisoCamion = tipoMovimiento == "pisocamion";

    print('TIPO MOVIMIENTO EN _BUILDHEADER: ${isPisoCamion}');

    if (!isPisoCamion) return const SizedBox();

    final origenCompleto =
        areaInicial != null && espacioInicial != null && nivelInicial != null;

    final vm = context.watch<UbicacionesViewModel>();
    final movementVm = Provider.of<movimientosContenedoresListadoViewModel>(
        context,
        listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "📦 Movimiento Piso → Camión",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        if (origenCompleto)
          Text(
            "Origen: Área $areaInicial – Espacio $espacioInicial – Nivel $nivelInicial",
            style: const TextStyle(fontSize: 15),
          ),

        const SizedBox(height: 10),

        // ------------------------------------------------------
        // BOTÓN SOLO PARA PISO → CAMIÓN
        // ------------------------------------------------------
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: origenCompleto ? Colors.green : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          ),
          onPressed: origenCompleto
              ? () async {
                  final serie = movementVm.selectedContainerNumber;

                  if (serie == null || serie.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Número de contenedor no disponible."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Confirmar movimiento"),
                      content: Text(
                        "¿Confirma mover el contenedor $serie "
                        "del área $areaInicial – espacio $espacioInicial – nivel $nivelInicial "
                        "al camión?",
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancelar")),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Mover")),
                      ],
                    ),
                  );

                  // if (confirm == true) {
                  //   await vm.ejecutarMovimiento(
                  //     context: context,
                  //     tipoMovimiento: "piso-camion",
                  //     serieAsignada: serie,
                  //     area: areaInicial!,
                  //     espacio: espacioInicial!,
                  //     nivel: nivelInicial!,
                  //     movementId: movementId,
                  //   );
                  // }
                }
              : null,
          child: const Text(
            "Confirmar Movimiento",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
