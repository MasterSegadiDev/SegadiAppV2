import 'package:flutter/material.dart';

class AppColors {
  // Colores de Disponibilidad (Regla de Niveles)
  static const Color disponibilidad3 = Color(0xFFBBDEFB); // Azul (3 Libres)
  static const Color disponibilidad2 = Color(0xFFC8E6C9); // Verde (2 Libres)
  static const Color disponibilidad1 = Color(0xFFFFF9C4); // Amarillo (1 Libre)
  static const Color disponibilidad0 = Color(0xFFFFCDD2); // Rojo (Lleno)

  // Colores de Selección y Estado
  static const Color origenHighlight = Colors.blue;
  static const Color destinoHighlight = Colors.orange;
  static const Color bolitaOcupada = Colors.red;
  static const Color bolitaLibre = Colors.green;
  static const Color nivelBloqueado =
      Color(0xFFBDBDBD); // Gris para física de patio

  // Colores Base
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBorder = Color(0xFFE0E0E0);
}
