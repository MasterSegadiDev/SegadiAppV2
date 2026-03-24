import 'package:flutter/material.dart';

final appTheme = ThemeData(
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Color(0xFFF5F5F5),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  // Aquí puedes definir estilos de texto globales
  textTheme: const TextTheme(
    displayLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
  ),
);
