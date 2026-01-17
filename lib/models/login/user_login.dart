import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:segadi/utils/global_variables.dart';

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
}
