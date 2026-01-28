import 'package:flutter/material.dart';
import 'package:segadi/models/contenedores/movimientos_contenedor.dart';

class Body extends StatelessWidget {
  final ContainerMovement movimiento;

  const Body(this.movimiento);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _detail("Operador XD", movimiento.craneOperator ?? "Sin operador"),
        _detail("Unidad", movimiento.unit ?? "No asignada"),
        _detail("Unidad local", movimiento.localUnit ?? "Sin unidad"),
        _detail(
          "Estado contenedor",
          movimiento.containerStatus ?? "S/E",
        ),
      ],
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
