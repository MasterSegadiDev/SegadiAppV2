import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  // final RegExp _exp = RegExp(r'[A-Z0-9]'); // Solo letras y números en mayúscula

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Filtra solo letras y números
    final filtered = newValue.text.toUpperCase().replaceAllMapped(
          RegExp(r'[^A-Z0-9]'),
          (match) => '',
        );
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({this.decimalRange = 2})
      : assert(decimalRange >= 0);

  final _regExp = RegExp(r'^\d*\.?\d*$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Validar formato general (números y un punto)
    if (!_regExp.hasMatch(text)) {
      return oldValue;
    }

    // Validar cantidad de decimales
    if (text.contains('.')) {
      final parts = text.split('.');
      if (parts.length > 2 || parts[1].length > decimalRange) {
        return oldValue;
      }
    }

    return newValue;
  }
}
