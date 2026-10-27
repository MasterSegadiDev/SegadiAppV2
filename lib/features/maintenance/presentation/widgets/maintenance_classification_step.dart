import 'package:flutter/material.dart';

class MaintenanceClassificationStep extends StatelessWidget {
  const MaintenanceClassificationStep({
    super.key,
    required this.priority,
    required this.classification1,
    required this.classification2,
    required this.onPriorityChanged,
    required this.onClassification1Changed,
    required this.onClassification2Changed,
  });

  final String? priority;
  final String? classification1;
  final String? classification2;

  final ValueChanged<String?> onPriorityChanged;
  final ValueChanged<String?> onClassification1Changed;
  final ValueChanged<String?> onClassification2Changed;

  static const dark = Color(0xFF101812);
  static const secondary = Color(0xFF6B6B66);

  static const priorities = [
    'Crítico urgente',
    'Medio atención no urgente',
    'Normal programado',
  ];

  static const classifications1 = [
    'Correctivo',
    'Preventivo',
    'Rescate',
  ];

  static const classifications2 = [
    'Eléctrico',
    'Llantas',
    'Mecánico arrastre',
    'Mecánico motriz',
    'Siniestro',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0DA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clasifica la solicitud',
            style: TextStyle(
              color: dark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Selecciona el tipo de atención '
            'que requiere la unidad.',
            style: TextStyle(
              color: secondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          _dropdown(
            label: 'Prioridad *',
            hint: 'Seleccionar prioridad',
            value: priority,
            options: priorities,
            onChanged: onPriorityChanged,
          ),
          const SizedBox(height: 20),
          _dropdown(
            label: 'Clasificación 1 *',
            hint: 'Seleccionar clasificación',
            value: classification1,
            options: classifications1,
            onChanged: onClassification1Changed,
          ),
          const SizedBox(height: 20),
          _dropdown(
            label: 'Clasificación 2 *',
            hint: 'Seleccionar especialidad',
            value: classification2,
            options: classifications2,
            onChanged: onClassification2Changed,
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: dark,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF7F8F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0DA),
              ),
            ),
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
