import 'dart:convert';
import 'dart:developer';

import 'package:segadi/model/user/UserInformation.dart';
import 'package:segadi/view_model/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class User {
  Future<Photo>? getUserPhot() async {
    print('entrando a cargar la foto del usuario');
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    var token = prefs.getString('token') ?? '';
    var route = 'index.php';

    var response =
        await http.get(Uri.parse(baseURL + route).replace(queryParameters: {
      'r': 'esegadi/getfoto',
      'id': userId.toString(),
      'token': token,
    }));

    var data = jsonDecode(response.body);

    var result = Photo.fromJson(data["photo"] as Map<String, dynamic>);
    inspect(result);

    return result;
  }
}
