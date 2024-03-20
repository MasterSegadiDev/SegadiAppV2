import 'dart:convert';

import 'package:segadi/view_model/globals.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<http.Response> alert() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    var token = prefs.getString('token') ?? '';

    Map data = {"id": userId, "token": token, "latitude": 0, "longitude": 0};

    var body = json.encode(data);
    var url = Uri.parse('${baseURL}index.php?r=esegadi/panicopost');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    return response;
  }
}
