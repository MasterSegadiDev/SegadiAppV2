import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

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
  //static const Color background = Color(0xFFF5F5F5);
  static const Color cardBorder = Color(0xFFE0E0E0);

  // ==========================
  // Colores principales
  // ==========================

  static const primary = Color(0xFF2C522A);
  static const primaryDark = Color(0xFF1B321A);
  static const primaryLight = Color(0xFFDDE8D0);

  // ==========================
  // Estados
  // ==========================

  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFD32F2F);
  static const warning = Color(0xFFF9A825);
  static const info = Color(0xFF1976D2);

  // ==========================
  // Escala de grises
  // ==========================

  static const white = Colors.white;
  static const black = Colors.black;
  static const background = Color(0xFFF5F5F5);
  static const border = Color(0xFFE0E0E0);
  static const disabled = Color(0xFFBDBDBD);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}
