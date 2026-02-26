import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorMessageView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorMessageView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Lógica para detectar el tipo de icono
    final bool isNoInternet = message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('conexión');

    return Container(
      width: double.infinity,
      color: Colors.white, // O el color de fondo de tu app
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono dinámico basado en el mensaje
          Icon(
            isNoInternet ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
            size: 100,
            color: isNoInternet
                ? Colors.red.withOpacity(0.5)
                : Colors.red.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            isNoInternet
                ? "Ha orcurrido un error de conexión"
                : "Ha ocurrido un error al cargar el detalle de la remisión",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Reintentar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C522A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}
