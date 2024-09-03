import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:segadi/view_model/globals.dart';

class UserLogin {
  String? username;
  final String password;
  final String token;

  UserLogin(
      {required this.username, required this.password, required this.token});
}

class AuthService {
   Future<http.Response> login(String username, String password) async {
    Map data = {"usuario": username, "password": password, "apptoken": "prueba"};

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
