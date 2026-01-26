import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:segadi/utils/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLogin {
  String? username;
  final String password;
  final String token;

  UserLogin(
      {required this.username, required this.password, required this.token});
}

class AuthService {
  final String baseUrl = GlobalVariables.baseUrl;
  final Map<String, String> headers = GlobalVariables.headers;

  Future<http.Response> login(String username, String password) async {
    Map data = {
      "usuario": username,
      "password": password,
      "apptoken": "prueba"
    };

    var body = json.encode(data);
    var url = Uri.parse('${baseUrl}index.php?r=esegadi/autenticapost');
    print('URL LOGIN:' + url.toString());
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    print('object login: ' + response.statusCode.toString());
    print(response.body);
    return response;
  }

  Future<http.Response> getTokenWithFirebaseBeforeLogin(
      int id, String token, String firebaseToken) async {
    Map data = {"user_id": id, "token": token, "token_firebase": firebaseToken};

    var body = json.encode(data);
    print('payload a enviar: ${body}');
    var url = Uri.parse('${baseUrl}index.php?r=esegadi/tokenfirebasepost');

    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    print('respuesta de token con firebase : ${response.statusCode}');
    if (response.statusCode != 200 || response.body.isEmpty) {
      throw Exception('Error al iniciar sesión. Inténtalo nuevamente.');
    }

    print('body del endpoint tokenfirebasepost: ${response.body}');
    return response;
  }
}
