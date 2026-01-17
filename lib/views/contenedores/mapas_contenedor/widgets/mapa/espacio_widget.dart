import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/contenedores/ubicacionesViewModel.dart';

import 'niveles_modal.dart';

class EspacioWidget extends StatelessWidget {
  final String area;
  final String espacio;
  final String tipoMovimiento;
  final String? movementId;

  final String? areaInicial;
  final String? espacioInicial;
  final String? nivelInicial;

  const EspacioWidget({
    super.key,
    required this.area,
    required this.espacio,
    required this.tipoMovimiento,
    required this.movementId,
    this.areaInicial,
    this.espacioInicial,
    this.nivelInicial,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UbicacionesViewModel>();

    final niveles = vm.getUbicacionesPorAreaEspacioYNivel(area, espacio);
    final ocupados =
        niveles.where((n) => n.numberSerie?.isNotEmpty == true).length;
    final disponibles = niveles.length - ocupados;

    Color color = Colors.blue;
    if (ocupados == 1) color = Colors.green;
    if (ocupados == 2) color = Colors.yellow.shade700;
    if (ocupados == 3) color = Colors.red;

    final esOrigen = (areaInicial == area && espacioInicial == espacio);

    return GestureDetector(
      onTap: () => showNivelesModal(
        context,
        area: area,
        espacio: espacio,
        tipoMovimiento: tipoMovimiento,
        movementId: movementId,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: esOrigen ? 3 : 1,
            color: esOrigen ? Colors.blueAccent : Colors.black26,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$area-$espacio",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Disponibles: $disponibles",
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
