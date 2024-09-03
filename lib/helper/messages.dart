import 'package:flutter/material.dart';

scaffoldMessengerSuccess(BuildContext context) {
  return ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      backgroundColor: Colors.green,
      content: Text('Bienvenido a SEGADI Operador'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

scaffoldMessengerWarning(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.yellow,
      content: Text(text),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

scaffoldMessengerError(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.red,
      content: Text(text),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
