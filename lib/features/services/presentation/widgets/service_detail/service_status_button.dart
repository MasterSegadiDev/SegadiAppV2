import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/services/presentation/viewmodels/service_detail_viewmodel.dart';

class ServiceStatusButton extends StatelessWidget {
  final String status;
  final VoidCallback? onPressed;

  const ServiceStatusButton({
    super.key,
    required this.status,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServiceDetailViewModel>();
    final config = _buttonConfig(status);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      child: ElevatedButton.icon(
        onPressed: config.enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: config.color,
          foregroundColor: Colors.white,
          minimumSize: const Size(
            double.infinity,
            56,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              16,
            ),
          ),
        ),
        icon: Icon(
          config.icon,
        ),
        label: Text(
          config.text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  _ButtonConfig _buttonConfig(
    String value,
  ) {
    switch (value.toLowerCase()) {
      case 'captured':
        return const _ButtonConfig(
          color: Colors.green,
          icon: Icons.play_arrow_rounded,
          text: 'INICIAR SERVICIO',
          enabled: true,
        );

      case 'started':
        return const _ButtonConfig(
          color: Colors.orange,
          icon: Icons.local_shipping,
          text: 'SERVICIO EN PROCESO',
          enabled: true,
        );

      case 'finished':
        return const _ButtonConfig(
          color: Colors.blueGrey,
          icon: Icons.check_circle,
          text: 'SERVICIO FINALIZADO',
          enabled: false,
        );

      case 'cancelled':
        return const _ButtonConfig(
          color: Colors.red,
          icon: Icons.cancel,
          text: 'SERVICIO CANCELADO',
          enabled: false,
        );

      default:
        return const _ButtonConfig(
          color: Colors.grey,
          icon: Icons.help_outline,
          text: 'SIN ESTATUS',
          enabled: false,
        );
    }
  }
}

class _ButtonConfig {
  final Color color;
  final IconData icon;
  final String text;
  final bool enabled;

  const _ButtonConfig({
    required this.color,
    required this.icon,
    required this.text,
    required this.enabled,
  });
}
