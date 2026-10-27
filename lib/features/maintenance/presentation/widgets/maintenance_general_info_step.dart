import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MaintenanceGeneralInfoStep extends StatelessWidget {
  const MaintenanceGeneralInfoStep({
    super.key,
    required this.formKey,
    required this.vehicleNumber,
    required this.descriptionController,
    required this.observationController,
    required this.incidentDate,
    required this.isUrgent,
    required this.onIncidentDateChanged,
    required this.onUrgentChanged,
  });

  final GlobalKey<FormState> formKey;
  final String vehicleNumber;
  final TextEditingController descriptionController;
  final TextEditingController observationController;
  final DateTime incidentDate;
  final bool isUrgent;
  final ValueChanged<DateTime> onIncidentDateChanged;
  final ValueChanged<bool> onUrgentChanged;

  static const green = Color(0xFF1E7A3C);
  static const dark = Color(0xFF101812);
  static const secondary = Color(0xFF6B6B66);

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: incidentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(incidentDate),
    );

    if (time == null) return;

    onIncidentDateChanged(
      DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(
            child: Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  color: green,
                  size: 30,
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unidad seleccionada',
                      style: TextStyle(
                        color: secondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Económico $vehicleNumber',
                      style: const TextStyle(
                        color: dark,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Descripción de la falla *',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: _decoration(
                    'Describe qué sucede con la unidad...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa la descripción de la falla.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const Text(
                  'Observaciones',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: observationController,
                  maxLines: 3,
                  decoration: _decoration(
                    'Información adicional (opcional)',
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Fecha y hora del incidente',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _pickDate(context),
                  child: InputDecorator(
                    decoration: _decoration(''),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: green,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(incidentDate),
                          ),
                        ),
                        const Icon(
                          Icons.edit_outlined,
                          color: secondary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: green,
                  value: isUrgent,
                  onChanged: onUrgentChanged,
                  title: const Text(
                    '¿Es urgente?',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'Activa esta opción si la falla '
                    'requiere atención inmediata.',
                    style: TextStyle(
                      color: secondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0DA),
        ),
      ),
      child: child,
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9A9A94),
        fontSize: 13,
      ),
      filled: true,
      fillColor: const Color(0xFFF7F8F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0DA),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0DA),
        ),
      ),
    );
  }
}
