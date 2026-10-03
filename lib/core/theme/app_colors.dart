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
  static const disabled = Color(0xFFBDBDBD);

  static const background = Color(0xFFF7F8F6);
  static const surfaceDark = Color(0xFF101812);
  static const primaryGreen = Color(0xFF1E7A3C);
  static const primaryGreenSoft = Color(0xFFE1F0E3);
  static const textPrimary = Color(0xFF101812);
  static const textSecondary = Color(0xFF6B6B66);
  static const textMuted = Color(0xFF9A9A94);
  static const border = Color(0xFFE0E0DA);
  static const errorRed = Color(0xFFB23A3A);
}
