import 'package:flutter/services.dart';

class DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    final regex = RegExp(r'^[0-9]*\.?[0-9]*$');
    if (!regex.hasMatch(text)) return oldValue;

    if ('.'.allMatches(text).length > 1) return oldValue;

    // máximo 2 decimales
    if (text.contains('.')) {
      final decimals = text.split('.')[1];
      if (decimals.length > 2) return oldValue;
    }

    return newValue;
  }
}
