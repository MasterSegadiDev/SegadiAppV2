import 'dart:convert';

import 'package:segadi/services/globals.dart';
import 'package:http/http.dart' as http;

class AuthServices {
  static Future<http.Response> login(String user, String password) async {
    Map data = {
      "email": user,
      "remember_token": password,
    };

    var body = json.encode(data);
    var url = Uri.parse(baseURL + 'auth/login');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    print(response.body);
    return response;
  }
}
