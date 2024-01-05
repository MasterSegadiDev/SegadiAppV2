import 'dart:convert';

import 'package:segadi/view_model/globals.dart';
import 'package:http/http.dart' as http;

class AuthServices {
  static Future<http.Response> login(String user, String password) async {
    Map data = {"usuario": user, "password": password, "apptoken": "prueba"};

    var body = json.encode(data);
    var url = Uri.parse('${baseURL}index.php?r=esegadi/autenticapost');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    return response;
  }
}
