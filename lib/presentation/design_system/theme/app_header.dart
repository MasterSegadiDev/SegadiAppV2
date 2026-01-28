import 'package:flutter/material.dart';
import 'package:segadi/models/contenedores/movimientos_contenedor.dart';

class Header extends StatelessWidget {
  final ContainerMovement movimiento;
  final String? contenedorMover;

  const Header(this.movimiento, this.contenedorMover);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "MOV ${movimiento.craneMovement ?? 'S/N'}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Contenedor: ${contenedorMover ?? 'S/N'}",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _chip(
              movimiento.movementType ?? "N/A",
              Colors.green,
            ),
            _chip(
              "Remisión ${movimiento.service ?? 'S/N'}",
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
