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

scaffoldMessengerSuccessEvidentia(BuildContext context, String message) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.green,
      content: Text('${message}'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

scaffoldMessengerWarning(BuildContext context, String message) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.yellow,
      content: Text('${message}'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

scaffoldMessengerError(BuildContext context, String message) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.red,
      content: Text('${message}'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

errorSnackBar(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      //title: const Text("Ha ocurrido un error inesperado"),
      content: Text(text),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: const Text("OK"),
          ),
        ),
      ],
    ),
  );
}

warningSnackBar(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Hay un problema"),
      content: Text(text),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: const Text("OK"),
          ),
        ),
      ],
    ),
  );
}

successSnackBar(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Bienvenido"),
      content: Text(text),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: const Text("OK"),
          ),
        ),
      ],
    ),
  );
}
