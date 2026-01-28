import 'package:flutter/material.dart';
import 'package:segadi/models/contenedores/movimientos_contenedor.dart';

class MovimientoCard extends StatelessWidget {
  final ContainerMovement movimiento;
  final String? contenedorMover;
  final VoidCallback? onTap;

  const MovimientoCard({
    super.key,
    required this.movimiento,
    required this.contenedorMover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENCABEZADO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "MOV ${movimiento.craneMovement ?? 'S/N'}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: Text(
                    "Contenedor: ${contenedorMover ?? 'S/N'}",
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // CHIPS
            Wrap(
              spacing: 8,
              children: [
                _chipPremium(movimiento.movementType ?? "N/A", Colors.green),
                _chipPremium(
                    "Remisión ${movimiento.service ?? 'S/N'}", Colors.green),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 16),

            // DETALLES
            _detallePremium(
                "Operador   Xd", movimiento.craneOperator ?? "Sin operador"),
            _detallePremium("Unidad", movimiento.unit ?? "No asignada"),
            _detallePremium(
                "Unidad Local", movimiento.localUnit ?? "Sin unidad"),
            _detallePremium(
                "Estado del contenedor", movimiento.containerStatus ?? "S/E"),
          ],
        ),
      ),
    );
  }

  Widget _chipPremium(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _detallePremium(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
