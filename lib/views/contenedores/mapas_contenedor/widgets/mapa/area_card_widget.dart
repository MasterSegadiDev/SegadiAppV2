import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/contenedores/ubicacionesViewModel.dart';

import 'espacio_widget.dart';

class AreaCardWidget extends StatelessWidget {
  final String area;
  final String tipoMovimiento;
  final String? movementId;

  final String? areaInicial;
  final String? espacioInicial;
  final String? nivelInicial;

  const AreaCardWidget({
    super.key,
    required this.area,
    required this.tipoMovimiento,
    required this.movementId,
    this.areaInicial,
    this.espacioInicial,
    this.nivelInicial,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UbicacionesViewModel>();

    final espacios = vm
        .getEspaciosPorArea(area)
        .where((e) => e != null && e.trim().isNotEmpty) // limpiar basura
        .toList()
      ..sort((a, b) {
        final na = int.tryParse(a);
        final nb = int.tryParse(b);

        // Si ambos son números → comparar como números
        if (na != null && nb != null) {
          return na.compareTo(nb);
        }

        // Si solo uno es número → primero los números
        if (na != null) return -1;
        if (nb != null) return 1;

        // Ninguno es número → comparar por texto
        return a.compareTo(b);
      });
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth * 0.25;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text("Área $area",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                children: [
                  for (final espacio in espacios)
                    EspacioWidget(
                      area: area,
                      espacio: espacio,
                      tipoMovimiento: tipoMovimiento,
                      movementId: movementId,
                      areaInicial: areaInicial,
                      espacioInicial: espacioInicial,
                      nivelInicial: nivelInicial,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
