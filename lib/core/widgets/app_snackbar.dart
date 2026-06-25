import 'package:flutter/material.dart';

class AppSnackbar {
  /// Muestra un Snackbar de Éxito
  static void success(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: const Color(0xFFE8F5E9), // Verde claro sutil
      borderColor: const Color(0xFF4CAF50), // Verde principal
      iconColor: const Color(0xFF2E7D32), // Verde oscuro para texto/icono
    );
  }

  /// Muestra un Snackbar de Error
  static void error(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: const Color(0xFFFFEBEE), // Rojo claro sutil
      borderColor: const Color(0xFFF44336), // Rojo principal
      iconColor: const Color(0xFFC62828), // Rojo oscuro para texto/icono
    );
  }

  /// Muestra un Snackbar de Advertencia (Warning)
  static void warning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.warning_rounded,
      backgroundColor: const Color(0xFFFFF8E1), // Amarillo/Ámbar claro
      borderColor: const Color(0xFFFFB300), // Ámbar principal
      iconColor: const Color(0xFFB7791F), // Ámbar oscuro para texto/icono
    );
  }

  /// Muestra un Snackbar de Información
  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: const Color(0xFFE3F2FD), // Azul claro sutil
      borderColor: const Color(0xFF2196F3), // Azul principal
      iconColor: const Color(0xFF1565C0), // Azul oscuro para texto/icono
    );
  }

  /// Método privado base para construir el Snackbar flotante y moderno
  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required Color iconColor,
  }) {
    // Limpia los snackbars activos antes de mostrar uno nuevo (evita acumulación)
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 3,
        behavior:
            SnackBarBehavior.floating, // Hace que flote sobre el contenido
        backgroundColor: Colors
            .transparent, // Dejamos el fondo transparente para usar nuestro Container
        padding:
            EdgeInsets.zero, // Quitamos el padding por defecto del snackbar
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius:
                BorderRadius.circular(12), // Bordes redondeados modernos
            border: Border.all(color: borderColor.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color:
                        iconColor, // El texto combina con el tono oscuro del tipo
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
