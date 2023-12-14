import 'package:flutter/material.dart';

const String baseURL = 'http://198.251.68.42/DesarrolloSEGADI/web/';

const String REFERRAL_LIST =
    "http://198.251.68.42/DesarrolloSEGADI/web/index.php";

//const String baseURL = 'http://10.0.2.2:8000/api/';
const Map<String, String> headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json'
};

errorSnackBar(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text("Error"),
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
  /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.green,
    content: Text(text),
    duration: const Duration(seconds: 1),
  ));*/
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text("Bienvenido"),
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
