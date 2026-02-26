import 'package:flutter/material.dart';
import 'package:segadi/features/services_assigned/domain/entities/service_entity.dart';

class Body extends StatelessWidget {
  final ServiceEntity item;

  const Body(this.item);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _detail("Origen", item.origin),
        _detail("Destino", item.destination),
        _detail("Escala 1", item.scaleOne),
        _detail("Escala 2", item.scaleTwo),
        _detail("Fecha carga", item.loadDate),
        _detail("Fecha descarga", item.unloadDate),
      ],
    );
  }

  Widget _detail(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

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
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
