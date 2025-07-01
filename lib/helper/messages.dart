import 'package:flutter/material.dart';

void scaffoldMessengerSuccess(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Bienvenido a SEGADI app'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ),
  );
}

void scaffoldMessengerSuccessStatus(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${message}'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
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

void scaffoldMessengerError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
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
